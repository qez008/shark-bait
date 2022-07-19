extends MeshInstance

export var is_master = false

var _shader_mat: ShaderMaterial


func _ready():
    _shader_mat = self.get_active_material(0)

    var _s1 = WaveManager.connect("update_wave_config", self, "set_waves")
    var _s2 = WaveManager.connect("update_wave_offset", self, "set_wave_offset")

    if is_master:
        WaveManager.set_initial_wave_config([
            _shader_mat.get_shader_param("wave_b"),
            _shader_mat.get_shader_param("wave_a"),
            _shader_mat.get_shader_param("wave_c"),
            _shader_mat.get_shader_param("wave_d")
        ])


func _process(_delta):
    _shader_mat.set_shader_param("synced_time", WaveManager.get_wave_time())


func set_waves(wave_config: Array):
    _shader_mat.set_shader_param("wave_a", wave_config[0])
    _shader_mat.set_shader_param("wave_b", wave_config[1])
    _shader_mat.set_shader_param("wave_c", wave_config[2])
    _shader_mat.set_shader_param("wave_d", wave_config[3])


func set_wave_offset(offset: Vector3):

    # snap positions to hexagon grid:
    var size = 200 / 50.0   # polygon mesh size / polygon mesh rings
    var w = size * 2
    var h = sqrt(3) * w

    var x1 = fmod(offset.x, w)
    var z1 = fmod(offset.z, h)

    var modulated_offset = offset - Vector3(x1, 0, z1)

    _shader_mat.set_shader_param("wave_offset", modulated_offset)
    self.global_transform.origin = modulated_offset
