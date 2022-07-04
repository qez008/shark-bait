extends Spatial

export (NodePath) var general_surface

var general_material: ShaderMaterial


func _ready():
    print(general_surface)
    general_material = get_node(general_surface).mesh.surface_get_material(0)
    WaveManager.set_wave_config([
            general_material.get_shader_param("wave_a"),
            general_material.get_shader_param("wave_b"),
            general_material.get_shader_param("wave_c"),
            general_material.get_shader_param("wave_d")
        ])


func _physics_process(delta):
    var pos = $InterpolatedCamera.global_transform.origin
    WaveManager.set_wave_offset(pos.x, pos.z)
