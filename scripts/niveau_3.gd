extends Node3D

@export var voiture: Node
@onready var arrivee: Area3D = $Arrivee
@onready var message: Label = $Fin/Message

var fini := false

func _ready() -> void:
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

func _dans_area(n: Node) -> bool:
	while n:
		if n is Area3D:
			return true
		n = n.get_parent()
	return false

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
			print("---------- PERDUUU ------------------- ")
			print("ALEXIS GROS NUL")
