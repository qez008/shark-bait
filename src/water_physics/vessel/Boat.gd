class_name Boat
extends RigidBody

# 1 m/s in knots
const MS_TO_KNOTS = 1.94384449

enum { IN_WATER, OUT_OF_WATER }

# Boat variables
export (float) var acceleration = 6.0
export (float) var surf_boost = 5.0
export (float) var steering_rate = 12.0

export (float) var displacement_rate = 0.8
export (float) var max_buoyancy = 70.0
export (float) var slamming_force = 0.7
export (float) var linear_water_resistance = 4.0
export (float) var angular_water_resistance = 10.0


export (NodePath) var bow_path
export (NodePath) var stern_path

export (Curve) var heel_curve: Curve

onready var floaters = $floaters


var bow: Spatial
var stern: Spatial

var num_floaters: int
var state = IN_WATER


# Internal state variables:
var _is_in_water: bool
var _was_in_water: bool
var _sub_lvl: float
var _floaters_in_water = []

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


func _input(event):
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
    update_hud()


func _physics_process(delta):

    _is_in_water = is_in_water()
    _sub_lvl = calculate_sub_lvl()
    _heel = Quat(transform.basis).x

    angular_damp = max(2, _sub_lvl * angular_water_resistance)
    linear_damp = max(1, 1 + _sub_lvl * linear_water_resistance)

    apply_buoyancy()
    apply_keel_torque(global_transform.basis.y, global_transform.basis.z)
    apply_sail_torque(global_transform.basis.y, WaveManager.get_wind())


    if _is_in_water:
        move_in_water()
    else:
        move_in_air()

    _was_in_water = _is_in_water



func apply_keel_torque(transform_up: Vector3, transform_sideways: Vector3):
    var y = 1 - transform_up.y
    var x = transform_sideways.y
    _keel_preasure = heel_curve.interpolate(abs(x)) * sign(x) * 40
    var keel_force = Vector3.RIGHT * _keel_preasure
    add_torque(global_transform.basis.xform(keel_force))


func apply_sail_torque(transform_up: Vector3, wind: Wind):
    # when mast is up right all wind force is applied,
    # and when mast is sideways no wind force is applied:
    var x = clamp(transform_up.y - 0.3, 0, 1)
    var sail_force = wind.vector * x
    _sail_preasure = sail_force.length()
    add_torque(sail_force)


func move_in_water():

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


func relative_wind_angle() -> float:
    var wind_vector = WaveManager.get_wind().vector
    var relative_wind_vector = global_transform.basis.xform(wind_vector)
    return Vector2(relative_wind_vector.x, relative_wind_vector.z).angle()


func get_input_direction() -> float:
    return Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")


func update_hud():
    var text = ""
    text += "mspf: %.1f\n" % (1000 / Engine.get_frames_per_second())
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
    text += "wind angle: %.2f\n" % WaveManager.get_wind().angle
    text += "relative wind angle: %.2f\n" % relative_wind_angle()

    Hud.get_children()[0].text = text

