class_name Wind

var angle: float
var force: float
var vector: Vector3

func _init(wind_angle: float, wind_force: float):
    self.angle = wind_angle
    self.force = wind_force
    vector = Vector3(cos(angle), 0, sin(angle)) * wind_force
