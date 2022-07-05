extends Node2D


var track = []
var average = Vector2.ZERO


func _process(_delta):
    update()


func _draw():
    var i = 0
    for point in track:
        i += 1
        var p = (point - average) / 3
        var c = Color.aqua if i % 2 == 0 else Color.aquamarine
        draw_circle(p, 1.5, c)


