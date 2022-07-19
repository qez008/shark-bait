extends Spatial
# larger splash effect when a vessel makes impact with water surface

var was_submerged: bool

func _physics_process(delta):
    var is_submerged = WaveManager.is_object_submerged(self)
    if not was_submerged and is_submerged:
        $l.emitting = true
        $r.emitting = true

    was_submerged = is_submerged
