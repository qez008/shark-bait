extends Node

signal update_wave_config
signal update_wave_offset

# wave configurations:

var quiet_waves = [
		Vector3(1.81, 20.0, 0.1),
		Vector3(1.31, 40.0, 0.1),
		Vector3(0.0, 1.0, 0.0),
		Vector3(0.0, 1.0, 0.0)
   ]

var medium_waves = [
		Vector3(1.61, 74.956, 0.116),
		Vector3(1.994, 36.31, 0.156),
		Vector3(1.226, 21.954, 0.152),
		Vector3(1.508, 12.934, 0.212)
   ]

var extreme_waves = [
		Vector3(1.61, 70.0, 0.4),
		Vector3(1.994, 36.31, 0.2),
		Vector3(1.226, 21.954, 0.1),
		Vector3(1.508, 12.934, 0.15)
   ]

var init_waves: Array



# state:

var _time: float = 0.0

var _wave_A := Vector3(0, 1, 0)
var _wave_B := Vector3(0, 1, 0)
var _wave_C := Vector3(0, 1, 0)
var _wave_D := Vector3(0, 1, 0)

var _general_wave_direction: Vector3

var _wave_offset: Vector3

var _wind: Wind = Wind.new(1.61 + PI, 20)


func _process(delta):
	_time += delta


func _unhandled_input(event):
	if event.is_action_pressed("one"):
		set_wave_config(quiet_waves)

	if event.is_action_pressed("two"):
		set_wave_config(medium_waves)

	if event.is_action_pressed("three"):
		set_wave_config(extreme_waves)

	if event.is_action_pressed("zero"):
		set_wave_config(init_waves)


func wave_function(wave_param: Vector3, time: float, point: Vector3) -> Vector3:
	
	var angle = wave_param.x
	var wave_len = wave_param.y
	var steepness = wave_param.z

	var k: float = 2 * PI / wave_len
	var c: float = sqrt(9.8 / k)
	var d := Vector2(sin(angle), cos(angle))
	var p_xz := Vector2(point.x, point.z)
	var f: float = k * (d.dot(p_xz) - c * time)
	var a: float = steepness / k

	return Vector3(
		d.x *(a*cos(f)),
		a * sin(f),
		d.y * (a * cos(f))
	)


func sample_wave(x: float, z: float) -> Vector3:

	var q = Vector3(x, 0.0, z)
	var xyz = Vector3(x, 0.0, z)

	q += wave_function(_wave_A, _time, xyz)
	q += wave_function(_wave_B, _time, xyz)
	q += wave_function(_wave_C, _time, xyz)
	q += wave_function(_wave_D, _time, xyz)

	return q


func calculate_wave_height(target: Vector3, iterations=5) -> float:
	var p = target

	for _i in range(0, iterations):
		var q = sample_wave(p.x, p.z)
		p += target - q

	return sample_wave(p.x, p.z).y


func calcualte_general_wave_direction(wave_configs) -> Vector3:

	var v = Vector3.ZERO

	for wave in wave_configs:
		var angle = wave.x
		var wave_len = wave.y
		var steepness = wave.z

		v += Vector3(sin(angle), 0, cos(angle)) * wave_len * steepness

	return v.normalized()


func is_object_submerged(object: Node3D) -> bool:
	return y_relative_to_surface(object) < 0


func y_relative_to_surface(object: Node3D) -> float:
	var object_position = object.global_transform.origin
	var wave_y = calculate_wave_height(object_position)

	return object_position.y - wave_y


# SETTERS:

func set_initial_wave_config(config):
	init_waves = config
	set_wave_config(init_waves)


func set_wave_config(config: Array):
	callv("_set_wave_config", config)
	emit_signal("update_wave_config", config)
	_general_wave_direction = calcualte_general_wave_direction(config)

func _set_wave_config(a, b, c, d):
	_wave_A = a
	_wave_B = b
	_wave_C = c
	_wave_D = d


func set_wave_offset(x, z):
	_wave_offset = Vector3(x, 0.0, z)
	emit_signal("update_wave_offset", _wave_offset)


# GETTERS:

func get_wave_time() -> float:
	return _time


func get_wave_direction() -> Vector3:
	return _general_wave_direction


func get_wind() -> Wind:
	return _wind
