tool
extends MeshInstance

func _ready():
    self.mesh = polygon_mesh()


func polygon_mesh(scalar=1) -> Mesh:

    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)

    # up facing triangles:

    st.add_triangle_fan(triangle_up(Vector3.ZERO))
    st.add_triangle_fan(triangle_up(Vector3.BACK.rotated(Vector3.UP, -PI/6)))
    st.add_triangle_fan(triangle_up(Vector3.LEFT))

     # down facing triangles:

    st.add_triangle_fan(triangle_down(Vector3.ZERO))
    st.add_triangle_fan(triangle_down(Vector3.LEFT))
    st.add_triangle_fan(triangle_down(Vector3.FORWARD.rotated(Vector3.UP, PI/6)))

    var m = Mesh.new()
    st.commit(m)

    return m


func triangle_up(bottom_left: Vector3, scalar=1) -> PoolVector3Array:
    var vs = [
            scalar * (bottom_left),
            scalar * (bottom_left + Vector3.FORWARD.rotated(Vector3.UP, -PI/6)),
            scalar * (bottom_left + Vector3.RIGHT),
       ]
    return PoolVector3Array(vs)


func triangle_down(top_left: Vector3, scalar=1) -> PoolVector3Array:
    var vs = [
            scalar * (top_left),
            scalar * (top_left + Vector3.RIGHT),
            scalar * (top_left + Vector3.BACK.rotated(Vector3.UP, PI/6)),
       ]
    return PoolVector3Array(vs)
