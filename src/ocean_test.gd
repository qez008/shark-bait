extends Spatial

export (NodePath) var general_surface

onready var camera = $InterpolatedCamera

func _physics_process(delta):

    var pos = camera.global_transform.origin

    WaveManager.set_wave_offset(pos.x, pos.z)

    Hud.set_compass_angle(camera.rotation.y)
    Hud.set_needle_angle(camera.rotation.y - $TestBoat.rotation.y + PI / 2)
    Hud.update_track($TestBoat.global_transform.origin)
