extends Control

@onready var speed_label = $VBoxContainer/Speed
@onready var rpm_label = $VBoxContainer/RPM
@onready var gear_label = $VBoxContainer/Gear
@onready var health_label = $VBoxContainer/Health

var vehicle: Vehicle

@export var health := 50.0

func _process(delta):
	vehicle = get_parent()
	speed_label.text = str(round(vehicle.speed * 3.6)) + " km/h"
	rpm_label.text = str(round(vehicle.motor_rpm)) + " rpm"
	gear_label.text = "Gear: " + str(vehicle.current_gear)
	health_label.text = "Health: " + str(health)

func lose_life():
	health -= -1
	 
	
