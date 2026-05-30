class_name NoticeBoardInteraction
extends AbstractInteraction

var quiz_scene = preload("res://scenes/skills/plant/plant_quiz_ui.tscn")
var quiz_instance = null

func pre_interact() -> void:
	super()

func interact() -> void:
	super()
	if not can_interact:
		return
	
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	
	if GameManager.skills_completed["plants"]:
		if ic: ic._show_interaction_text("Plant identification — already completed!", 2.0)
		return
	
	if not GameManager.plant_guide_read:
		if ic: ic._show_interaction_text("Find and read the plant guide first!", 3.0)
		return
	
	if quiz_instance != null:
		return
	
	_start_quiz()

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()

func _start_quiz() -> void:
	quiz_instance = quiz_scene.instantiate()
	get_tree().root.add_child(quiz_instance)
	
	for plant in _get_plants():
		quiz_instance.plants.append(plant)
	
	quiz_instance.setup()
	quiz_instance.quiz_closed.connect(func(): 
		quiz_instance = null
		# restore interaction text on board
		var ic = get_tree().get_first_node_in_group("interaction_controller")
		if ic: ic._show_interaction_text("Plant Identification Test", 2.0)
	)

func _get_plants() -> Array:
	return [
		preload("res://data/chanterelle.tres"),
		preload("res://data/death_cap.tres"),
		preload("res://data/fly_agaric.tres"),
		preload("res://data/blueberry.tres"),
		preload("res://data/elderberry.tres"),
		preload("res://data/nightshade.tres")
	]

func use_item(_item_data: ItemData) -> bool:
	return false
