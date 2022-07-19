#tool
extends Node2D

onready var comp1 = $comp1
onready var comp2 = $comp2
onready var comp3 = $comp3
onready var comp4 = $comp4
onready var comp5 = $comp5
onready var comp6 = $comp6


var _angle = 0.0

func set_compass_angle(a: float):
    comp1.rotation = a
    comp2.rotation = a / 2
    comp3.rotation = a * 2
    comp4.rotation = -a / 2
    comp5.rotation = -a / 4
    comp6.rotation = -a * 2


func _process(delta):
    if Engine.editor_hint:
        _angle += delta
        set_compass_angle(_angle)


