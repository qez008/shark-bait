tool
extends MeshInstance

export (String) var path = "res://src/utils/mesh_generator/polygon_mesh.res"
export (bool) var toggle_to_save setget _save
export (int) var rings = 3 setget _set_rings
export (float) var radius = 1 setget _set_radius


# vectors pointing in all clock directions.
# this is useful as a polygon has six sides.
var v1 = Vector3.FORWARD.rotated(Vector3.UP, -PI/6)
var v2 = Vector3.RIGHT.rotated(Vector3.UP, PI/6)
var v3 = Vector3.RIGHT
var v4 = Vector3.RIGHT.rotated(Vector3.UP, -PI/6)
var v5 = Vector3.BACK.rotated(Vector3.UP, PI/6)
var v6 = Vector3.BACK
var v7 = Vector3.BACK.rotated(Vector3.UP, -PI/6)
var v8 = Vector3.LEFT.rotated(Vector3.UP, PI/6)
var v9 = Vector3.LEFT
var v10 = Vector3.LEFT.rotated(Vector3.UP, -PI/6)
var v11 = Vector3.FORWARD.rotated(Vector3.UP, PI/6)
var v12 = Vector3.FORWARD


func _set_rings(i):
    rings = i
    _ready()

func _set_radius(r):
    radius = r
    _ready()

func _save(b):
    toggle_to_save = b
    ResourceSaver.save(path, self.mesh)


func _ready():
    self.mesh = polygon_mesh(radius / max(rings, 1))



func polygon_mesh(s=0.5) -> Mesh:

    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)

    # fill in center:
    add_vertices_and_uvs((v11 * s), s, "triangle_down", st)
    add_vertices_and_uvs(Vector3.ZERO, s, "triangle_up", st)
    add_vertices_and_uvs(Vector3.ZERO, s, "triangle_down", st)
    add_vertices_and_uvs(v7 * s, s, "triangle_up", st)
    add_vertices_and_uvs(v9 * s, s, "triangle_down", st)
    add_vertices_and_uvs(v9 * s, s, "triangle_up", st)

    for n in rings:
        # top:
        for i in n + 1:
            add_vertices_and_uvs((v11 * (n+1) + v3*i) * s, s, "triangle_up_", st)
            add_vertices_and_uvs((v11 * (n+1) + v3*i) * s, s, "triangle_down", st)

        # buttom:
        for i in n + 1:
            add_vertices_and_uvs((v7 * n + v3*i) * s, s, "triangle_up_", st)
            add_vertices_and_uvs((v7 * n + v3*i) * s, s, "triangle_down", st)

        # add missing corners
        add_vertices_and_uvs((v1 * (n+1)) * s, s, "triangle_up_", st)
        add_vertices_and_uvs((v7 * n + v9) * s, s, "triangle_down", st)

        # sides:
        for i in n:
            # top left:
            add_vertices_and_uvs((v9 * n + v11 + v1 * i) * s, s, "triangle_up_", st)
            add_vertices_and_uvs((v9 * n + v11 + v1 * i) * s, s, "triangle_down", st)
            # buttom left:
            add_vertices_and_uvs((v9 * n + v5 * i) * s, s, "triangle_up_", st)
            add_vertices_and_uvs((v9 * (n+1) + v5 * i) * s, s, "triangle_down", st)
            # top right:
            add_vertices_and_uvs((v3 * n + v1 + v11 * i) * s, s, "triangle_up_", st)
            add_vertices_and_uvs((v3 * (n-1) + v1 + v11 * i) * s, s, "triangle_down", st)
            # top left:
            add_vertices_and_uvs((v3 * n + v7 * i) * s, s, "triangle_up_", st)
            add_vertices_and_uvs((v3 * n + v7 * i) * s, s, "triangle_down", st)

    var m = Mesh.new()
    st.commit(m)

    return m


func add_vertices_and_uvs(anchor: Vector3, scalar: float, triangle_f: String, st: SurfaceTool):

    var vs = call(triangle_f, anchor, scalar)
    var x = Vector2.ONE * radius

    var normals = [Vector3.UP, Vector3.UP, Vector3.UP]
    var uvs = []
    for v in vs:
        var uv = Vector2(v.x, v.z) * (1/radius) * 0.5 + Vector2(0.5, 0.5)
        uvs.push_back(uv)

#    print(uvs)
    st.add_triangle_fan(vs, PoolVector2Array(uvs), PoolColorArray(), PoolVector2Array(), normals)


func triangle_up_(top: Vector3, scalar=1) -> PoolVector3Array:
    var vs = [
            top,
            top + v5 * scalar,
            top + v7 * scalar,
       ]
    return PoolVector3Array(vs)


func triangle_up(bottom_left: Vector3, scalar=1) -> PoolVector3Array:
    var vs = [
            bottom_left,
            bottom_left + Vector3.FORWARD.rotated(Vector3.UP, -PI/6) * scalar,
            bottom_left + Vector3.RIGHT * scalar,
       ]
    return PoolVector3Array(vs)


func triangle_down(top_left: Vector3, scalar=1) -> PoolVector3Array:
    var vs = [
            top_left,
            top_left + Vector3.RIGHT * scalar,
            top_left + Vector3.BACK.rotated(Vector3.UP, PI/6) * scalar,
       ]
    return PoolVector3Array(vs)



func polygon_mesh_old(s=0.5) -> Mesh:

    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)

    # fill in center:
    st.add_triangle_fan(triangle_down(v11 * s, s))
    st.add_triangle_fan(triangle_up(Vector3.ZERO, s))
    st.add_triangle_fan(triangle_down(Vector3.ZERO, s))
    st.add_triangle_fan(triangle_up(v7 * s, s))
    st.add_triangle_fan(triangle_down(v9 * s, s))
    st.add_triangle_fan(triangle_up(v9 * s, s))

    for n in rings:
        # top:
        for i in n + 1:
            st.add_triangle_fan(triangle_up_((v11 * (n+1) + v3*i) * s, s))
            st.add_triangle_fan(triangle_down((v11 * (n+1) + v3*i) * s, s))

        # buttom:
        for i in n + 1:
            st.add_triangle_fan(triangle_up_((v7 * n + v3*i) * s, s))
            st.add_triangle_fan(triangle_down((v7 * n + v3*i) * s, s))

        # add missing corners
        st.add_triangle_fan(triangle_up_((v1 * (n+1)) * s, s))
        st.add_triangle_fan(triangle_down((v7 * n + v9) * s, s))

        # sides:
        for i in n:
            # top left:
            st.add_triangle_fan(triangle_up_((v9 * n + v11 + v1 * i) * s, s))
            st.add_triangle_fan(triangle_down((v9 * n + v11 + v1 * i) * s, s))
            # buttom left:
            st.add_triangle_fan(triangle_up_((v9 * n + v5 * i) * s, s))
            st.add_triangle_fan(triangle_down((v9 * (n+1) + v5 * i) * s, s))
            # top right:
            st.add_triangle_fan(triangle_up_((v3 * n + v1 + v11 * i) * s, s))
            st.add_triangle_fan(triangle_down((v3 * (n-1) + v1 + v11 * i) * s, s))
            # top left:
            st.add_triangle_fan(triangle_up_((v3 * n + v7 * i) * s, s))
            st.add_triangle_fan(triangle_down((v3 * n + v7 * i) * s, s))

    var m = Mesh.new()
    st.commit(m)

    return m
