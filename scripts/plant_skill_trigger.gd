extends Area3D

var skill_scene = preload("res://scenes/skills/plant/skill_plants.tscn")
var skill_instance = null

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		if skill_instance == null and not GameManager.skills_completed["plants"]:
			if not GameManager.plant_guide_read:
				var ic = get_tree().get_first_node_in_group("interaction_controller")
				if ic:
					ic._show_interaction_text("Find and read the plant guide first!", 3.0)
				return
			skill_instance = skill_scene.instantiate()
			skill_instance.set_player(body)
			get_tree().root.add_child(skill_instance)
			skill_instance.global_position = global_position
