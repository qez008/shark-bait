extends MeshInstance

export var is_master = false

var _shader_mat: ShaderMaterial


func _ready():
    _shader_mat = self.get_active_material(0)

    var _s1 = WaveManager.connect("update_wave_config", self, "set_waves")
    var _s2 = WaveManager.connect("update_wave_offset", self, "set_wave_offset")

    if is_master:
        WaveManager.set_waves(
            _shader_mat.get_shader_param("wave_a"),
            _shader_mat.get_shader_param("wave_b"),
            _shader_mat.get_shader_param("wave_c"),
            _shader_mat.get_shader_param("wave_d")
        )


func _process(_delta):
    _shader_mat.set_shader_param("synced_time", WaveManager.get_wave_time())


func set_waves(wave_config: Array):
    _shader_mat.set_shader_param("wave_a", wave_config[0])
    _shader_mat.set_shader_param("wave_b", wave_config[1])
    _shader_mat.set_shader_param("wave_c", wave_config[2])
    _shader_mat.set_shader_param("wave_d", wave_config[3])


func set_wave_offset(offset: Vector3):
    _shader_mat.set_shader_param("wave_offset", offset)
    self.global_transform.origin = offset
