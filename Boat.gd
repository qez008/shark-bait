extends RigidBody

export (int) var acceleration = 10
export (int) var steering_rate = 20
export (int) var buoyancy = 30

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


func _input(event):
    if event is InputEventMouseMotion:
        _mouse_offset = event.relative


func _process(delta):
    _update_rotation(delta)


func _update_rotation(delta):
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






func _physics_process(delta):

    # move forward

    if is_in_water():
        if Input.is_action_pressed("ui_up"):
            add_central_force(global_transform.basis.xform(Vector3.RIGHT * acceleration))

        #steer
        var direction = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
        if direction != 0:
            add_torque(Vector3(0, steering_rate * direction, 0))

    #quit
    if Input.is_action_pressed("ui_cancel"):
        get_tree().quit()

    apply_buoyancy()
    update_hud()


func is_in_water():
    var propeller_position = $propeller.global_transform.origin
    return propeller_position.y < WaveManager.get_wave_height(propeller_position)





func apply_buoyancy():
    var num_floaters = $floaters.get_child_count()
    for floater in $floaters.get_children():
        var point = (floater as Spatial).global_transform.origin
        var wave_y = WaveManager.get_wave_height(point)
        var depth = wave_y - point.y
        if depth > 0:
            add_force(Vector3.UP * depth * buoyancy / num_floaters, point - global_transform.origin)


func update_hud():
    var y_boat = global_transform.origin.y
    var y_wave = WaveManager.get_wave_height(global_transform.origin)

    #speeds
    var stw = abs(linear_velocity.length())
    var sog = abs(Vector2(linear_velocity.x, linear_velocity.z).length())


    var text = "boat y: " + str(y_boat)
    text += "\nwave y: " + str(y_wave)
    text += "\nunder water: " + str(y_boat < y_wave)
    text += "\nSOG: " + str(sog)
    text += "\nSTW: " + str(stw)
    text += "\nvelocity: " + str(linear_velocity)

    Hud.get_children()[0].text = text



func set_smoothness(value):
    smoothness = clamp(value, 0.001, 0.999)

