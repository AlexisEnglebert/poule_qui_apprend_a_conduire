extends AnimatableBody3D

@export var vitesse := 3.0

var depart: Vector3
var arrivee: Vector3
var cible: Vector3


func _ready():
	depart = global_position
	arrivee = $end.global_position
	cible = arrivee


func _physics_process(delta):
	global_position = global_position.move_toward(cible, vitesse * delta)
	if global_position.distance_to(cible) < 0.01:
		cible = depart if cible == arrivee else arrivee
