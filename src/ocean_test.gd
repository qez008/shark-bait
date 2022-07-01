extends Spatial


onready var general_surface := $ocean_surface

var general_material: ShaderMaterial


func _ready():
    general_material = general_surface.mesh.surface_get_material(0)
    WaveManager.set_wave_config([
            general_material.get_shader_param("wave_a"),
            general_material.get_shader_param("wave_b"),
            general_material.get_shader_param("wave_c"),
            general_material.get_shader_param("wave_d")
        ])


func _physics_process(delta):
    var pos = $InterpolatedCamera.global_transform.origin
    WaveManager.set_wave_offset(pos.x, pos.z)
