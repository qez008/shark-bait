extends MeshInstance

var _shader_mat: ShaderMaterial

func _ready():
    _shader_mat = self.get_active_material(0)
    WaveManager.set_waves(
        _shader_mat.get_shader_param("wave_a"),
        _shader_mat.get_shader_param("wave_b"),
        _shader_mat.get_shader_param("wave_c"),
        _shader_mat.get_shader_param("wave_d")
    )

func _process(delta):
#    if _shader_mat == null:
#        _shader_mat = self.get_active_material(0)

    _shader_mat.set_shader_param("synced_time", WaveManager.get_wave_time())
