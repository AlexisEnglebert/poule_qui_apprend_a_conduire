extends Area3D

@export var time_to_stay := 1.5
@export var tolerance_cote := 0.25
@export var tolerance_longueur := 0.4

var gagne := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _physics_process(delta):
	if gagne:
		return
	var voiture_parked := false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
