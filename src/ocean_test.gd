extends Spatial



onready var detailed_surface := $test_mesh
onready var general_surface := $ocean_surface

var detailed_material: ShaderMaterial
var general_material: ShaderMaterial


func _ready():
    detailed_material = detailed_surface.mesh.surface_get_material(0)
    general_material = general_surface.mesh.surface_get_material(0)
    sync_waves("wave_a")
    sync_waves("wave_b")
    sync_waves("wave_c")
    sync_waves("wave_d")


func sync_waves(param):
    detailed_material.set_shader_param(param, general_material.get_shader_param(param))


func _physics_process(delta):
    var pos = $InterpolatedCamera.global_transform.origin
#    detailed_surface.global_transform.origin.x = pos.x
#    detailed_surface.global_transform.origin.z = pos.z
#    detailed_material.set_shader_param("wave_offset", pos)
    WaveManager.set_wave_offset(pos.x, pos.z)
