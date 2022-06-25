extends MeshInstance

var _shader_mat: ShaderMaterial


var quiet_waves = [
        Vector3(0.0, 1.0, 0.0),
        Vector3(0.0, 1.0, 0.0),
        Vector3(0.0, 1.0, 0.0),
        Vector3(0.0, 1.0, 0.0)
   ]

var medium_waves = [
        Vector3(1.61, 74.956, 0.116),
        Vector3(1.994, 36.31, 0.156),
        Vector3(1.226, 21.954, 0.152),
        Vector3(1.508, 12.934, 0.212)
   ]


func set_waves(wave_config: Array):
    _shader_mat.set_shader_param("wave_a", wave_config[0])
    _shader_mat.set_shader_param("wave_b", wave_config[1])
    _shader_mat.set_shader_param("wave_c", wave_config[2])
    _shader_mat.set_shader_param("wave_d", wave_config[3])
    WaveManager.set_waves(
        wave_config[0],
        wave_config[1],
        wave_config[2],
        wave_config[3]
    )


func _ready():
    _shader_mat = self.get_active_material(0)
    WaveManager.set_waves(
        _shader_mat.get_shader_param("wave_a"),
        _shader_mat.get_shader_param("wave_b"),
        _shader_mat.get_shader_param("wave_c"),
        _shader_mat.get_shader_param("wave_d")
    )

func _process(_delta):
#    if _shader_mat == null:
#        _shader_mat = self.get_active_material(0)

    _shader_mat.set_shader_param("synced_time", WaveManager.get_wave_time())


func _unhandled_input(event):
    if event.is_action_pressed("one"):
        call_deferred("set_waves", quiet_waves)
    if event.is_action_pressed("two"):
        call_deferred("set_waves", medium_waves)
