extends Position3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func _process(_delta):
    var wind = WaveManager.get_wind()
    var q = Quat(global_transform.basis)
    q.y = wind.angle
    global_transform.basis = Basis(q)
#    look_at(Vector3.FORWARD.rotated(Vector3.UP, wind.angle) * 10000000, Vector3.UP)
