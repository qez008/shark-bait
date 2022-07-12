extends Spatial

export (NodePath) var general_surface

onready var camera = $InterpolatedCamera
export (NodePath) onready var boat = get_node(boat)

func _physics_process(delta):

    var pos = camera.global_transform.origin

    WaveManager.set_wave_offset(pos.x, pos.z)

    Hud.set_compass_angle(camera.rotation.y)
    Hud.set_needle_angle(camera.rotation.y - boat.rotation.y + PI / 2)
    Hud.update_track(boat.global_transform.origin)
