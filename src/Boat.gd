class_name Boat
extends RigidBody

# 1 m/s in knots
const MS_TO_KNOTS = 1.94384449

enum { IN_WATER, OUT_OF_WATER }


onready var floaters = $floaters
onready var camera_rotor = $camera_rotor

# Boat variables
export (float) var acceleration = 3.0
export (float) var surf_boost = 5.0
export (float) var steering_rate = 10.0
export (float) var displacement_rate = 1.0
export (float) var max_buoyancy = 30.0



# Camera export variables:
export (float, 0.0, 1.0) var sensitivity = 0.5
export (float, 0.0, 0.999, 0.001) var smoothness = 0.5 setget set_smoothness
export (int, 0, 360) var yaw_limit = 360
export (int, 0, 360) var pitch_limit = 360
export (bool) var camera_yaw = false
export (bool) var camera_pitch = false

export (NodePath) var bow_path
export (NodePath) var stern_path


var bow: Spatial
var stern: Spatial

# Intern camera variables:
var _mouse_offset = Vector2()
var _rotation_offset = Vector2()
var _yaw = 0.0
var _total_yaw = 0.0
var _pitch = 0.0
var _total_pitch = 0.0

var num_floaters: int
var state = IN_WATER

var _is_in_water: bool

func _ready():
    num_floaters = floaters.get_child_count()

    bow = get_node(bow_path)
    stern = get_node(stern_path)

    $camera_rotor/camera_target.transform.origin = $camera_rotor/right_target.transform.origin

    if camera_pitch or camera_yaw:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
    if event is InputEventMouseMotion:
        _mouse_offset = event.relative
    # quit
    if event.is_action_pressed("ui_cancel"):
        get_tree().quit()


func _process(delta):
    _update_rotation(delta)
    update_hud()


func _update_rotation(_delta):
    var offset = _mouse_offset * sensitivity
    _mouse_offset = Vector2()

    if camera_yaw:
        _yaw = _yaw * smoothness + offset.x * (1.0 - smoothness)
        if yaw_limit < 360:
            _yaw = clamp(_yaw, -yaw_limit - _total_yaw, yaw_limit - _total_yaw)
        _total_yaw += _yaw
        camera_rotor.rotate_y(deg2rad(-_yaw))

    if camera_pitch:
        _pitch = _pitch * smoothness + offset.y * (1.0 - smoothness)
        if pitch_limit < 360:
            _pitch = clamp(_pitch, -pitch_limit - _total_pitch, pitch_limit - _total_pitch)
        _total_pitch += _pitch
        camera_rotor.rotate_object_local(Vector3(1,0,0), deg2rad(-_pitch))



func _physics_process(_delta):
    _is_in_water = is_in_water()

    if _is_in_water:
#        angular_damp = 4
        move_in_water()
    else:
#        angular_damp = 1
        move_in_air()


func move_in_water():

    apply_buoyancy()

    var direction = (bow.global_transform.origin - stern.global_transform.origin).normalized()
    var slope = wave_slope()
    # slide with the slope of the waves:
    var flow_with_slope = pow(abs(slope), 2) * sign(slope)
#    add_central_force(global_transform.basis.xform(Vector3.RIGHT * flow_with_slope))
    add_central_force(direction * flow_with_slope)

    # accelerate
    if Input.is_action_pressed("ui_up"):
        add_central_force((direction * acceleration))
        # apply speed boost when going 'downhill' i.e. surfing
        if slope > 0.0:
            var v = Vector3.RIGHT * surf_boost * sqrt(slope * 2.5)
            add_central_force(global_transform.basis.xform(v))

        else:
            var v = Vector3.LEFT * surf_boost * sqrt(-slope * 2.5) * 0.1
            add_central_force(global_transform.basis.xform(v))

    var input_direction = get_input_direction()
    # steer
    if input_direction != 0:
        add_torque(Vector3(0, steering_rate * input_direction, 0))


func move_in_air():
    apply_buoyancy()
    var input_direction = get_input_direction()
    # steer, but in the air:
    if input_direction != 0:
        add_torque(Vector3(0, steering_rate * input_direction * 0.2, 0))


func apply_buoyancy():

    for floater in floaters.get_children():

        var floater_position = (floater as Spatial).global_transform.origin
        var position = floater_position - global_transform.origin
        var force = Vector3.DOWN * 9.8 / num_floaters
        force = Vector3.ZERO
        var wave_y = WaveManager.calculate_wave_height(floater_position)

        var depth = wave_y - floater_position.y

        if depth > 0:
            var submergence_level = clamp(depth * displacement_rate, 0.0, 1.0)
            var buoyancy_force = Vector3.UP * submergence_level * max_buoyancy / num_floaters
            force += buoyancy_force

        add_force(force, position)


func wave_slope() -> float:

    var a = stern.global_transform.origin
    var b = bow.global_transform.origin

    var y1 = WaveManager.calculate_wave_height(a)
    var y2 = WaveManager.calculate_wave_height(b)

    return y1 - y2


func is_in_water() -> bool:
    var floaters_in_water = 0
    for floater in floaters.get_children():
        var floater_position = (floater as Spatial).global_transform.origin
        if floater_position.y - 0.1 < WaveManager.calculate_wave_height(floater_position, 5):
            floaters_in_water += 1
            if floaters_in_water > num_floaters / 4.0:
                return true

    return false


func get_input_direction() -> float:
    return Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")


func update_hud():
    var text = ""
    text += "mspf: %.1f\n" % (1000 / Engine.get_frames_per_second())
    var xyz = [
            global_transform.origin.x,
            global_transform.origin.y,
            global_transform.origin.z
        ]
    text += "x: %.1f, y: %.1f, z: %.1f\n" % xyz
    text += "speed: %.1f\n" % abs(linear_velocity.length())
    text += "SOG: %.1f\n" % abs(Vector2(linear_velocity.x, linear_velocity.z).length())
    text += "slope: %.2f\n" % wave_slope()
    text += "in water: " + str(_is_in_water)

    Hud.get_children()[0].text = text


func set_smoothness(value):
    smoothness = clamp(value, 0.001, 0.999)

