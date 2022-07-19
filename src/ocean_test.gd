extends Spatial

export (NodePath) var general_surface

onready var camera = $InterpolatedCamera
export (NodePath) onready var boat = get_node(boat)


var _initial_y: float

func _ready():
    _initial_y = camera.global_transform.origin.y

func _physics_process(delta):

    var pos = camera.global_transform.origin

    WaveManager.set_wave_offset(pos.x, pos.z)

    Hud.set_compass_angle(camera.rotation.y)
    Hud.set_needle_angle(camera.rotation.y - boat.rotation.y + PI / 2)
    Hud.update_track(boat.global_transform.origin)
    Hud.set_windex_angle(WaveManager.get_wind().angle)


func _process(_delta):
    var wave_y = WaveManager.calculate_wave_height(camera.global_transform.origin) + 0.2
    if camera.global_transform.origin.y < wave_y:
        camera.global_transform.origin.y = wave_y
