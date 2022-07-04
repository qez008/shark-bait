extends Spatial

export (NodePath) var general_surface

onready var camera = $InterpolatedCamera

func _physics_process(delta):

    var pos = camera.global_transform.origin
    WaveManager.set_wave_offset(pos.x, pos.z)

    Hud.compass.rotation = (camera.rotation.y)
    Hud.needle.rotation = (camera.rotation.y - $TestBoat.rotation.y + PI / 2)
