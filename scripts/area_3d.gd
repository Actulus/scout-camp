extends Area3D

var skill_scene = preload("res://scenes/skills/shelter/skill_shelter.tscn")
var skill_instance = null

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_enter)


func _on_enter(body):
	if body.name == "Player" and GameManager.current_day == 1:
		if skill_instance == null:
			skill_instance = skill_scene.instantiate()
			get_tree().root.add_child(skill_instance)
