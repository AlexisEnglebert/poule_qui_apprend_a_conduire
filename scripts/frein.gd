extends Node

var voiture

func _ready():
	voiture = get_parent()
	if voiture.torque_curve == null:
		voiture.torque_curve = Curve.new()
	voiture.automatic_transmission = false
	voiture.brake_input = 1.0
	voiture.handbrake_input = 1.0

func _physics_process(_delta):
	var v = voiture.linear_velocity
	if Vector2(v.x, v.z).length() < 0.5:
		voiture.linear_velocity = Vector3(0, v.y, 0)
	var r = voiture.angular_velocity
	if abs(r.y) < 0.3:
		voiture.angular_velocity = Vector3(r.x, 0, r.z)
