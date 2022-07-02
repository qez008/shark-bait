class_name Boat
extends RigidBody

# 1 m/s in knots
const MS_TO_KNOTS = 1.94384449

# Boat variables
export (float) var acceleration = 3.0
export (float) var surf_angle = 0.027
export (float) var surf_boost = 5.0
export (float) var climb_angle = 0.03
export (float) var climb_friction = 3.0
export (float) var steering_rate = 10.0
export (float) var buoyancy_rate = 30.0
export (float) var max_buoyancy = 30.0



# Camera export variables:
export (float, 0.0, 1.0) var sensitivity = 0.5
export (float, 0.0, 0.999, 0.001) var smoothness = 0.5 setget set_smoothness
export (int, 0, 360) var yaw_limit = 360
export (int, 0, 360) var pitch_limit = 360
export (bool) var camera_yaw = false
export (bool) var camera_pitch = false

# Intern camera variables:
var _mouse_offset = Vector2()
var _rotation_offset = Vector2()
var _yaw = 0.0
var _total_yaw = 0.0
var _pitch = 0.0
var _total_pitch = 0.0



func _ready():
    if camera_pitch or camera_yaw:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

    for state in $state_machine._states.values():
        state.body = self

    $camera_rotor/camera_target.transform.origin = $camera_rotor/right_target.transform.origin


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
        $camera_rotor.rotate_y(deg2rad(-_yaw))


    if camera_pitch:
        _pitch = _pitch * smoothness + offset.y * (1.0 - smoothness)
        if pitch_limit < 360:
            _pitch = clamp(_pitch, -pitch_limit - _total_pitch, pitch_limit - _total_pitch)
        _total_pitch += _pitch
        $camera_rotor.rotate_object_local(Vector3(1,0,0), deg2rad(-_pitch))


func _physics_process(_delta):
    if is_in_water():
        # accelerate
        if Input.is_action_pressed("ui_up"):
            add_central_force(global_transform.basis.xform(Vector3.RIGHT * acceleration))
            # apply speed boost when going 'downhill' i.e. surfing
            var angle = boat_angle()
#            if is_surfing(angle):
#                add_central_force(global_transform.basis.xform(Vector3.RIGHT * surf_boost))
#            # halt speed if climbing up a wave
#            elif is_climbing(angle):
#                add_central_force(global_transform.basis.xform(Vector3.LEFT * climb_friction))

        # steer
        var direction = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
        if direction != 0:
            add_torque(Vector3(0, steering_rate * direction, 0))

    apply_buoyancy()


func boat_angle():
    return self.rotation.z


func is_surfing(angle):
    return $bow.global_transform.origin.y < $stern.global_transform.origin.y and angle > surf_angle


func is_climbing(angle):
    return $bow.global_transform.origin.y > $stern.global_transform.origin.y and angle > climb_angle


func is_in_water():
    var propeller_position = $propeller.global_transform.origin
    return propeller_position.y < WaveManager.get_wave_height(propeller_position)


func apply_buoyancy():
    var num_floaters = $floaters.get_child_count()

    for floater in $floaters.get_children():

        var floater_position = (floater as Spatial).global_transform.origin
        var position = floater_position - global_transform.origin
        var force = Vector3.DOWN * 9.8 / num_floaters
        force = Vector3.ZERO
        var wave_y = WaveManager.get_wave_height(floater_position)
        var depth = wave_y - floater_position.y
        if depth > 0:
            var submergence_level = clamp(depth * buoyancy_rate, 0.0, 1.0)
            var buoyancy_force = Vector3.UP * submergence_level * max_buoyancy / num_floaters
            force += buoyancy_force

        add_force(force, position)


func update_hud():
    var text = ""
    text += "mspf: %.1f\n" % (1000 / Engine.get_frames_per_second())
    var xyz = [global_transform.origin.x, global_transform.origin.y, global_transform.origin.z]
    text += "x: %.1f, y: %.1f, z: %.1f\n" % xyz
    text += "speed: %.1f\n" % abs(linear_velocity.length())
    text += "SOG: %.1f\n" % abs(Vector2(linear_velocity.x, linear_velocity.z).length())
    text += "boat angle: %.2f\n" % boat_angle()

    Hud.get_children()[0].text = text


func set_smoothness(value):
    smoothness = clamp(value, 0.001, 0.999)

