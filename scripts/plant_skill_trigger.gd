extends Area3D

var quiz_scene = preload("res://scenes/skills/plant/plant_quiz_ui.tscn")
var quiz_instance = null

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name != "Player": return
	if GameManager.skills_completed["plants"]: return
	if quiz_instance != null: return
	
	if not GameManager.plant_guide_read:
		var ic = get_tree().get_first_node_in_group("interaction_controller")
		if ic: ic._show_interaction_text("Find and read the plant guide first!", 3.0)
		return
	
	quiz_instance = quiz_scene.instantiate()
	# assign plant data array in code or via export
	get_tree().root.add_child(quiz_instance)
	
	print("quiz_instance type: ", quiz_instance.get_class())
	print("quiz_instance script: ", quiz_instance.get_script())
	print("has plants property: ", "plants" in quiz_instance)
	
	var plant_list = [
	preload("res://data/chanterelle.tres"),
	preload("res://data/death_cap.tres"),
	preload("res://data/fly_agaric.tres"),
	preload("res://data/blueberry.tres"),
	preload("res://data/elderberry.tres"),
	preload("res://data/nightshade.tres")
]

	for plant in plant_list:
		quiz_instance.plants.append(plant)
	
	quiz_instance.setup()
	quiz_instance.quiz_closed.connect(func(): quiz_instance = null)
