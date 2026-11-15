extends Area3D

@export var time_to_stay := 1

var voiture_parked := false
var current_time_parked := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _physics_process(delta):
	if voiture_parked:
		return
	for body in get_overlapping_bodies():
		if body.name == "VehicleRigidBody":
			var aligne = abs(body.global_transform.basis.z.dot(global_transform.basis.z)) > 0.95
			if aligne and body.linear_velocity.length() < 0.5:
				current_time_parked += delta
				if current_time_parked >= time_to_stay:
					voiture_parked = true
					print(voiture_parked)
			else:
				current_time_parked = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
