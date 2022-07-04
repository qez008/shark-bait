extends Spatial

export (NodePath) var general_surface

func _physics_process(delta):
    var pos = $InterpolatedCamera.global_transform.origin
    WaveManager.set_wave_offset(pos.x, pos.z)
