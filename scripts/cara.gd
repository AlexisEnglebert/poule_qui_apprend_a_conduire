extends Area3D

@export var alcool := 10

signal prise

var already_taken := false
	 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var env := get_tree().root.get_child(0).get_node("WorldEnvironment") as WorldEnvironment
	var ivresse: EffetIvresse = env.compositor.compositor_effects[0]
	
	ivresse.enabled = true
	ivresse.intensite = 0
	body_entered.connect(_on_collision)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var env := get_tree().root.get_child(0).get_node("WorldEnvironment") as WorldEnvironment
	var ivresse: EffetIvresse = env.compositor.compositor_effects[0]
	
	rotate_y(5.0 * delta)
	
func _on_collision(body):
	if body.name != "VehicleRigidBody":
		return
	var env := get_tree().root.get_child(0).get_node("WorldEnvironment") as WorldEnvironment
	var ivresse: EffetIvresse = env.compositor.compositor_effects[0]
	
	ivresse.intensite += 0.2;
	if already_taken:
		return
	if not body.is_in_group("player"):
		return
	already_taken = true
	hide()
	print("cara prise et bue")
	prise.emit()
	set_process(false)
