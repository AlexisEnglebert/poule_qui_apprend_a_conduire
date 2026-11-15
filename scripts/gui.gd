extends Control

@onready var speed_label = $VBoxContainer/Speed
@onready var rpm_label = $VBoxContainer/RPM
@onready var gear_label = $VBoxContainer/Gear
@onready var health_label = $VBoxContainer/Health

@export var health := 50.0
@export var damage_multiplicator := 5.0
@export var speed_min_crash := 3.0

var vehicle: Vehicle
var old_speed := Vector3.ZERO
@export var invincible := 2.0

func _ready():
	await get_tree().process_frame
	vehicle = get_tree().get_first_node_in_group("player")
	if vehicle == null:
		return
	vehicle.contact_monitor = true
	vehicle.max_contacts_reported = 4
	vehicle.body_entered.connect(_on_collision)

func _process(delta):
	speed_label.text = str(round(vehicle.speed * 3.6)) + " km/h"
	rpm_label.text = str(round(vehicle.motor_rpm)) + " rpm"
	gear_label.text = "Gear: " + str(vehicle.current_gear)
	health_label.text = "Health: " + str(int(max(health, 0)))
	
func _physics_process(delta):
	if vehicle == null:
		return
	if invincible > 0.0:
		invincible -= delta
	old_speed = vehicle.linear_velocity

func _on_collision(object):	
	if health <= 0.0 or invincible > 0.0 or _est_route(object):
		return
	print("collision")
	var crash = (old_speed - vehicle.linear_velocity).length()
	health -= crash * damage_multiplicator
	health = snapped(health, 0.1)
	if health <= 0.0:
		_game_over()

func plus_de_vie():
	if health <= 0.0:
		return
	health = 0.0
	_game_over()

func _game_over():
	get_tree().current_scene.add_child(preload("res://scenes/game_over_prefab.tscn").instantiate())

func _est_route(object: Node) -> bool:
	var n := object
	while n:
		if n.name.begins_with("road"):
			return true
		n = n.get_parent()
	return false
	 
	
