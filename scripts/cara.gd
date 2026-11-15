extends Area3D

@export var alcool := 10

var already_taken := false
	 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_collision)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(0.2 * delta)
	
func _on_collision(body):
	if already_taken:
		return
	if not body.is_in_group("player"):
		return
	already_taken = true
	hide()
	print("cara prise et bue")
