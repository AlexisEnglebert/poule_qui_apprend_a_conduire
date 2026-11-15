extends Node3D

@export var canvas_layer: Node2D
@export var parking_layer: Node2D

var _last_position: Vector3


func _ready() -> void:
	_last_position = global_position
	parking_layer.hide()
	canvas_layer.show()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") \
	or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		canvas_layer.hide()
		get_tree().create_timer(0.1).timeout
		parking_layer.show();
		
func _process(delta: float) -> void:
	pass
