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

    WaveManager.connect("update_wave_config", self, "set_waves")


func _process(_delta):
    _shader_mat.set_shader_param("synced_time", WaveManager.get_wave_time())


func set_waves(wave_config: Array):
    _shader_mat.set_shader_param("wave_a", wave_config[0])
    _shader_mat.set_shader_param("wave_b", wave_config[1])
    _shader_mat.set_shader_param("wave_c", wave_config[2])
    _shader_mat.set_shader_param("wave_d", wave_config[3])
