extends MeshInstance


func _physics_process(_delta):
    var y = WaveManager.calculate_wave_height(global_transform.origin)
    transform.origin.y = y

