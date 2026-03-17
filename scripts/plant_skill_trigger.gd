extends Area3D

var skill_scene = preload("res://scenes/skills/plant/skill_plants.tscn")
var skill_instance = null

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" and GameManager.current_day == 4:
		if skill_instance == null:
			skill_instance = skill_scene.instantiate()
			skill_instance.set_player(body)
			get_tree().root.add_child(skill_instance)
			skill_instance.global_position = global_position
