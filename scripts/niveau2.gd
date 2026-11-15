extends Node3D

@export var voiture: Node
@onready var arrivee: Area3D = $Arrivee
@onready var message: Label = $Fin/Message
@onready var timer : Timer = $countdown
@onready var Timerlabel: Label = $CanvasLayer/CenterContainer/LabelTimer
@onready var texteScript: Label = $CanvasLayer2/texte_vite/CanvasLayer/CenterContainer/LabelTimer

var fini := false

func _ready() -> void:
	texteScript.show()
	for m in find_children("*", "MeshInstance3D", true, false):
		if m is StaticBody3D:
			m.add_to_group("route")
		if voiture.is_ancestor_of(m):
			continue
		if m.get_children().any(func(c): return c is StaticBody3D):
			continue
		m.create_trimesh_collision()
	for herbe in [$MeshInstance3D, $sol, $sol2]:
		for c in herbe.get_children():
			if c is StaticBody3D:
				c.add_to_group("herbe")
				c.global_position.y -= 0.05
	
	await get_tree().create_timer(2).timeout
	texteScript.hide()
	timer.timeout.connect(_on_timer_timeout)
	timer.start(120.0)

func _process(delta: float) -> void:
	if not timer.is_stopped():
		Timerlabel.text = _format_time(timer.time_left)
		
func _format_time(seconds: float) -> String:
	var total_seconds: int = ceili(seconds)
	var mins: int = total_seconds / 60
	var secs: int = total_seconds % 60
	return "⏱︎ %02d:%02d" % [mins, secs]
	
func _on_timer_timeout():
	print("C'est le moment d'attaquer !")
	
func _physics_process(_delta: float) -> void:
	if fini:
		return
	var vehicle := get_tree().get_first_node_in_group("player") as Vehicle
	if vehicle == null:
		return
	for w in vehicle.wheel_array:
		var c := w.get_collider() as Node
		if w.is_colliding() and c and c.is_in_group("herbe"):
			print("---------- PERDUUU ------------------- ")
