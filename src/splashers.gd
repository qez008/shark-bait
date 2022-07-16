extends Spatial

var splashers_submerged: bool

func _physics_process(delta):
    var b = WaveManager.is_object_submerged(self)
    if not splashers_submerged and b:
        $l.emitting = true
        $r.emitting = true

    splashers_submerged = b
