extends Node3D

@export var final_rotation: float = 90 
var starting_rotation: float 

func _ready() -> void:
	starting_rotation = rotation.x 
	final_rotation = deg_to_rad(rad_to_deg(starting_rotation)+final_rotation)
	
func execute(percentage: float) -> void: 
	rotation.x = starting_rotation + percentage*(final_rotation-starting_rotation)
