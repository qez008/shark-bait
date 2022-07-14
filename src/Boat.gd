class_name Boat
extends RigidBody

# 1 m/s in knots
const MS_TO_KNOTS = 1.94384449

enum { IN_WATER, OUT_OF_WATER }


onready var floaters = $floaters
onready var camera_rotor = $camera_rotor

# Boat variables
export (float) var acceleration = 6.0
export (float) var surf_boost = 5.0
export (float) var steering_rate = 12.0

export (float) var displacement_rate = 0.8
export (float) var max_buoyancy = 70.0
export (float) var slamming_force = 0.7
export (float) var linear_water_resistance = 4.0
export (float) var angular_water_resistance = 10.0


# Camera export variables:
export (float, 0.0, 1.0) var sensitivity = 0.5
export (float, 0.0, 0.999, 0.001) var smoothness = 0.5 setget set_smoothness
export (int, 0, 360) var yaw_limit = 360
export (int, 0, 360) var pitch_limit = 360
export (bool) var camera_yaw = false
export (bool) var camera_pitch = false

export (NodePath) var bow_path
export (NodePath) var stern_path

export (Curve) var heel_curve: Curve


var bow: Spatial
var stern: Spatial

# Internal camera variables:
var _mouse_offset = Vector2()
var _rotation_offset = Vector2()
var _yaw = 0.0
var _total_yaw = 0.0
var _pitch = 0.0
var _total_pitch = 0.0

var num_floaters: int
var state = IN_WATER


# Internal state variables:
var _is_in_water: bool
var _was_in_water: bool
var _sub_lvl: float
var _floaters_in_water = []
var splashers_submerged: bool

# Sailing variables:
var _sail_preasure: float
var _keel_preasure: float
var _heel: float


func _ready():
    num_floaters = floaters.get_child_count()
    for _i in num_floaters:
        _floaters_in_water.append(false)

    bow = get_node(bow_path)
    stern = get_node(stern_path)

    $camera_rotor/camera_target.transform.origin = $camera_rotor/right_target.transform.origin

    if camera_pitch or camera_yaw:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
    if event is InputEventMouseMotion:
        _mouse_offset = event.relative

    if event.is_action_pressed("flip"):
        transform.origin.y = 10
        var q = Quat(transform.basis)
        q.x = 0
        q.z = 0
        transform.basis = Basis(q)

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



func _physics_process(delta):

    _is_in_water = is_in_water()
    _sub_lvl = calculate_sub_lvl()

    angular_damp = max(2, _sub_lvl * angular_water_resistance)
    linear_damp = max(1, 1 + _sub_lvl * linear_water_resistance)


    if _is_in_water:
        sail_vs_keel(delta)
        move_in_water()
    else:
        move_in_air()

    _was_in_water = _is_in_water

    var b = WaveManager.is_object_submerged($splashers)
    if not splashers_submerged and b:
        $splashers/l.emitting = true
        $splashers/r.emitting = true

    splashers_submerged = b


func sail_vs_keel(delta):
    _heel = Quat(transform.basis).x

    var keel_angle = _heel
    _keel_preasure = heel_curve.interpolate(abs(_heel)) * -sign(_heel) * 100
    var keel_force = Vector3.RIGHT * _keel_preasure
    add_torque(global_transform.basis.xform(keel_force))

    # temporary fix preventing flips..
    if not is_upright(0.3):
        return

    var wind = WaveManager.get_wind()
    # when mast is up right all wind force is applied,
    # and when mast is sideways no wind force is applied:
    var x = 1 - abs(_heel)
    _sail_preasure = x * wind.angle
    var sail_force = wind.vector * x
    add_torque(sail_force)


func move_in_water():

    apply_buoyancy()

    var direction = global_transform.basis.xform(Vector3.RIGHT)
    var slope = wave_slope()

    # accelerate
    if Input.is_action_pressed("ui_up"):
        add_central_force(direction * acceleration)
        # apply speed boost when going 'downhill' i.e. surfing
        if slope > 0.0:
            var v = Vector3.RIGHT * surf_boost * sqrt(slope * 2.5)
            add_central_force(global_transform.basis.xform(v))
        # .. and reduce speed when going uphill
        else:
            var v = Vector3.LEFT * pow(abs(slope/2), 4)
            add_central_force(global_transform.basis.xform(v))

    var input_direction = get_input_direction()
    # steer
    if input_direction != 0:
        var rot = Vector3(0, steering_rate * input_direction * _sub_lvl, 0)
        add_torque(global_transform.basis.xform(rot))


func move_in_air():
    apply_buoyancy()
    var input_direction = get_input_direction()
    # steer, but in the air:
    if input_direction != 0:
        var rot = Vector3(0, steering_rate * input_direction * 0.2, 0)
        add_torque(global_transform.basis.xform(rot))


func apply_buoyancy():

    for i in num_floaters:
        var floater_position = floaters.get_child(i).global_transform.origin
        var position = floater_position - global_transform.origin
        var force = Vector3.DOWN * 16 / num_floaters
        var wave_y = WaveManager.calculate_wave_height(floater_position)

        var depth = wave_y - floater_position.y

        if depth > 0:
            var submergence_level = clamp(depth * displacement_rate, 0.0, 1.0)
            var buoyancy_force = Vector3.UP * pow(submergence_level, 1.2) * max_buoyancy / num_floaters
            force += buoyancy_force
            # floater makes impact with water:
            if not _floaters_in_water[i]:
                var impact_force = Vector3.UP * abs(linear_velocity.y) * slamming_force
                apply_impulse(position, impact_force / num_floaters)

            _floaters_in_water[i] = true

        else:
            _floaters_in_water[i] = false

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


func is_upright(treshold=0.5) -> bool:
    var transform_up = global_transform.basis.y
    return transform_up.y > treshold



func calculate_sub_lvl() -> float:
    var sl = 0.0
    for floater in floaters.get_children():
        var floater_position = (floater as Spatial).global_transform.origin
        var wave_y = WaveManager.calculate_wave_height(floater_position, 5)
        var depth = wave_y - floater_position.y
        if depth > 0:
            sl += clamp(depth * 0.7, 0.0, 1.0)

    return sl / num_floaters


func get_input_direction() -> float:
    return Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")


func update_hud():
    var text = ""
    text += "mspf: %.1f\n" % (1000 / Engine.get_frames_per_second())
#    var xyz = [
#            global_transform.origin.x,
#            global_transform.origin.y,
#            global_transform.origin.z
#        ]
#    text += "x: %.1f, y: %.1f, z: %.1f\n" % xyz
    text += "x: %.1f\n" % global_transform.origin.x
    text += "y: %.1f\n" % global_transform.origin.y
    text += "z: %.1f\n" % global_transform.origin.z
    text += "speed: %.1f\n" % abs(linear_velocity.length())
    text += "slope: %.2f\n" % wave_slope()
    text += "in water: " + str(_is_in_water) + "\n"
    text += "sub lvl: %.2f\n" % _sub_lvl
    text += "linear damp: %.2f\n" % linear_damp
    text += "angular damp: %.2f\n" % angular_damp
    text += "sail preasure: %.2f\n" % _sail_preasure
    text += "keel preasure: %.2f\n" % _keel_preasure
    text += "heel: %.2f\n" % _heel

    Hud.get_children()[0].text = text


func set_smoothness(value):
    smoothness = clamp(value, 0.001, 0.999)

