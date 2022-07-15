extends CanvasLayer


@onready var compass = $compass/spinny
@onready var needle = $compass/needle_origin
@onready var track_display = $ColorRect/track_display

var i = 0
var track_size = 20
var frequenzy = 200

func update_track(point: Vector3):
	i += 1
	if i == frequenzy:
		var track = track_display.track

		var p: Vector2 = Vector2(point.x, point.z)
		track.push_back(p)

		track_display.average.x += p.x / track_size
		track_display.average.y += p.y / track_size

		if track.size() > track_size:
			var q = track.pop_front()

			track_display.average.x -= q.x / track_size
			track_display.average.y -= q.y / track_size

		i = 0



func set_compass_angle(a: float):
	compass.rotation = a


func set_needle_angle(a: float):
	needle.rotation = a


func set_windex_angle(a: float):
	$compass/windex.rotation = compass.rotation + a
