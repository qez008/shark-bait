extends Spatial
# water plow effect at the front of a vessel

onready var top = $top
onready var particles = $CPUParticles
onready var debug_sphere = $CPUParticles/debug_sphere


func _physics_process(_delta):
    if WaveManager.is_object_submerged(self) and not WaveManager.is_object_submerged(top):
        particles.emitting = true
        particles.global_transform.origin = calculate_particle_position(top, self)
        debug_sphere.visible = true
    else:
        particles.emitting = false
        debug_sphere.visible = false


func calculate_particle_position(top_node: Spatial, buttom_node: Spatial) -> Vector3:
    var top_position = top_node.global_transform.origin
    var bottom_position = buttom_node.global_transform.origin

    var v: Vector3 = (top_position - bottom_position) / 2
    var u: Vector3 = bottom_position + v
    # binary search type approach:
    for _i in 8:
        v /= 2
        var wave_y = WaveManager.calculate_wave_height(u)
        if wave_y < u.y:
            u -= v
        else:
            u += v
    return u + v
