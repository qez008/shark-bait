extends MeshInstance


func _physics_process(_delta):
    var y = WaveManager.get_wave_height(global_transform.origin)
    transform.origin.y = y - mesh.radius * 0.5

