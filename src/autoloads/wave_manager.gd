extends Node

signal update_wave_config
signal update_wave_offset

# wave configurations:

var quiet_waves = [
#        Vector3(PI / 2.1, 42.0, 0.08),
#        Vector3(PI / 2.4, 60.0, 0.07),
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


# state:

var _time: float = 0.0

var _wave_A: Vector3
var _wave_B: Vector3
var _wave_C: Vector3
var _wave_D: Vector3

var _wave_offset: Vector3



func _process(delta):
    _time += delta


func _unhandled_input(event):
    if event.is_action_pressed("one"):
        set_wave_config(quiet_waves)
    if event.is_action_pressed("two"):
        set_wave_config(medium_waves)


func set_wave_config(config):
    callv("set_waves", config)
    emit_signal("update_wave_config", config)


func set_waves(a, b, c, d):
    _wave_A = a
    _wave_B = b
    _wave_C = c
    _wave_D = d


func set_wave_offset(x, z):
    var cell_size = 15
#    _wave_offset = Vector3(x - (x % cell_size), 0.0, z - (z % cell_size))
    _wave_offset = Vector3(x, 0.0, z)
    emit_signal("update_wave_offset", _wave_offset)


func get_wave_time() -> float:
    return _time


func get_wave_height(target):
    var p = target

    for _i in range(0, 3):
        p = _get_wave_height(p.x, p.z)
        var diff = p - target
        diff.y = 0
        p = p - diff

    return p.y


func _get_wave_height(x, z):

    var q = Vector3(x, 0.0, z)
    var xyz = q

    q += wave(_wave_A, _time, xyz)
    q += wave(_wave_B, _time, xyz)
    q += wave(_wave_C, _time, xyz)
    q += wave(_wave_D, _time, xyz)

    return q


func wave(w: Vector3, time, p: Vector3) -> Vector3:
    var angle = w.x
    var wave_len = w.y
    var steepness = w.z

    var k: float = 2 * PI / wave_len
    var c: float = sqrt(9.8/k)
    var d := Vector2(sin(angle), cos(angle))
    var p_xz := Vector2(p.x, p.z)
    var f: float = k * (d.dot(p_xz) - c * time)
    var a: float = steepness / k

    return Vector3(
        d.x * (a * cos(f)),
        a * sin(f),
        d.y * (a * cos(f))
    )

