extends Position3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


export var sensitivity = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


func _input(event):
    if event is InputEventPanGesture:
        var delta: Vector2 = (event as InputEventPanGesture).delta
        var angle = Vector2.UP.dot(delta)
        if angle < 0.3:
            var amount: float = delta.x * sensitivity / 20
            self.rotate_y(amount)

