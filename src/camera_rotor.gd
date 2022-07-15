extends Position3D


# Camera export variables:
@export_range(0.0, 1.0) var sensitivity = 0.5
@export_range(0.0, 0.999, 0.001) var smoothness = 0.5 #setget set_smoothness
@export_range(0, 360) var yaw_limit = 360
@export_range(0, 360) var pitch_limit = 360

@export var camera_yaw: bool = false
@export var camera_pitch: bool = false

@export var target_node: Node3D

# Internal camera variables:
var _mouse_offset = Vector2()
var _rotation_offset = Vector2()
var _yaw = 0.0
var _total_yaw = 0.0
var _pitch = 0.0
var _total_pitch = 0.0

var _look_left: bool = false
var _initial_y: float


func _ready():
	toggle_camera_target()
	if camera_pitch or camera_yaw:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	_initial_y = $camera_target.global_transform.origin.y


func _input(event):
	if event is InputEventMouseMotion:
		_mouse_offset = event.relative

	if event.is_action_pressed("shift"):
		toggle_camera_target()


func _process(delta):
	_update_rotation(delta)

	var target_transform = target_node.global_transform
	global_transform.origin = target_transform.origin

	var v = target_transform.basis.x
	v = Vector3(v.x, 0, v.z).normalized().rotated(Vector3.UP, deg2rad(-_total_yaw))
	var u = v.cross(Vector3.UP)
	global_transform.basis = Basis(v, Vector3.UP, u)



func _update_rotation(_delta):
	var offset = _mouse_offset * sensitivity
	_mouse_offset = Vector2()

	if camera_yaw:
		_yaw = _yaw * smoothness + offset.x * (1.0 - smoothness)
		if yaw_limit < 360:
			_yaw = clamp(_yaw, -yaw_limit - _total_yaw, yaw_limit - _total_yaw)
		_total_yaw += _yaw
#        $camera_rotor.rotate_y(deg2rad(-_yaw))

	if camera_pitch:
		_pitch = _pitch * smoothness + offset.y * (1.0 - smoothness)
		if pitch_limit < 360:
			_pitch = clamp(_pitch, -pitch_limit - _total_pitch, pitch_limit - _total_pitch)
		_total_pitch += _pitch
#        $camera_rotor.rotate_object_local(Vector3(1,0,0), deg2rad(-_pitch))



func toggle_camera_target():
	var new_target: Node3D = $left_target if _look_left else $right_target
	$camera_target.global_transform.origin = new_target.global_transform.origin
	_look_left = !_look_left


func set_smoothness(value):
	smoothness = clamp(value, 0.001, 0.999)

