extends Node3D

## Instancié par gui.gd quand la vie tombe à 0.
## Affiche "GAME OVER" puis recharge le niveau après RESTART_DELAY secondes.

const RESTART_DELAY := 5.0

func _ready() -> void:
	# Timer enfant (et pas un await) : il meurt avec le prefab, donc jamais de rappel sur un arbre null.
	var timer := Timer.new()
	timer.wait_time = RESTART_DELAY
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(func(): get_tree().reload_current_scene())
	add_child(timer)
