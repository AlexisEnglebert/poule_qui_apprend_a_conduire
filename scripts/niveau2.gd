extends Node3D

@export var voiture: Node
@onready var arrivee: Area3D = $Arrivee
@onready var message: Label = $Fin/Message
@onready var timer : Timer = $countdown
@onready var Timerlabel: Label = $CanvasLayer/CenterContainer/LabelTimer
@onready var texteScript: Label = $CanvasLayer2/texte_vite/CanvasLayer/CenterContainer/LabelTimer
@export var canvas_layer: Node2D

var fini := false

func _ready() -> void:
	canvas_layer.hide()
	texteScript.show()
	for m in find_children("*", "MeshInstance3D", true, false):
		print(m.name, "cara" in m.name)
		print(m.scene_file_path)
		
		if m is StaticBody3D:
			m.add_to_group("route")
		if voiture.is_ancestor_of(m):
			continue
		if m.get_children().any(func(c): return c is StaticBody3D):
			continue
		
		if _dans_area(m): # cara : leurs meshes s'appellent Object_0..., pas "cara"
			continue
			
		m.create_trimesh_collision()
	for c in find_children("*", "Area3D", true, false):
		if c.has_signal("prise"):
			c.prise.connect(_on_cara_prise)
	for herbe in [$MeshInstance3D, $sol, $sol2]:
		for c in herbe.get_children():
			if c is StaticBody3D:
				c.add_to_group("herbe")
				c.global_position.y -= 0.05
	
	await get_tree().create_timer(2).timeout
	texteScript.hide()
	timer.timeout.connect(_on_timer_timeout)
	timer.start(10)

func _process(delta: float) -> void:
	if not timer.is_stopped():
		Timerlabel.text = _format_time(timer.time_left)
		
func _format_time(seconds: float) -> String:
	var total_seconds: int = ceili(seconds)
	var mins: int = total_seconds / 60
	var secs: int = total_seconds % 60
	return "⏱︎ %02d:%02d" % [mins, secs]
	
func _on_cara_prise():
	if not timer.is_stopped():
		timer.start(timer.time_left + 10.0)

func _on_timer_timeout():
	voiture.get_node("GUI").plus_de_vie()
	
func _physics_process(_delta: float) -> void:
	if fini:
		return
	var vehicle := get_tree().get_first_node_in_group("player") as Vehicle
	if vehicle == null:
		return
	for w in vehicle.wheel_array:
		var c := w.get_collider() as Node
		if w.is_colliding() and c and c.is_in_group("herbe"):
			fini = true
			voiture.get_node("GUI").plus_de_vie()
			return

func _dans_area(n: Node) -> bool:
	while n:
		if n is Area3D:
			return true
		n = n.get_parent()
	return false
