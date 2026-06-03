class_name FieldGuideInteraction
extends AbstractInteraction

enum GuideType { PLANTS, ANIMALS }
@export var guide_type: GuideType = GuideType.PLANTS
@export var guide_title: String = "Plant Field Guide"
@export var plant_entries: Array[PlantInfo] = []
@export var animal_entries: Array[AnimalInfo] = []

var guide_scene = preload("res://scenes/ui/field_guide_ui.tscn")
var guide_instance = null

func pre_interact() -> void:
	super()

func interact() -> void:
	super()
	if not can_interact: return
	if guide_instance: return
	_open_guide()

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()

func use_item(_item_data: ItemData) -> bool:
	return false

func _open_guide() -> void:
	guide_instance = guide_scene.instantiate()
	get_tree().root.add_child(guide_instance)
	guide_instance.guide_type = guide_type
	guide_instance.guide_title = guide_title
	guide_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	
	print("=== FIELD GUIDE DEBUG ===")
	print("guide_type: ", guide_type)
	print("plant_entries size: ", plant_entries.size())
	print("animal_entries size: ", animal_entries.size())
	print("guide_instance class: ", guide_instance.get_class())
	print("guide_instance script: ", guide_instance.get_script())
	
	if guide_type == FieldGuideUI.GuideType.PLANTS:
		for entry in plant_entries:
			print("appending plant: ", entry)
			guide_instance.entries.append(entry)
	else:
		for entry in animal_entries:
			print("appending animal: ", entry)
			guide_instance.entries.append(entry)
	
	print("entries after append: ", guide_instance.entries.size())
	guide_instance.setup()
	print("setup() called")
	
	guide_instance.closed.connect(func(): guide_instance = null)
	guide_instance.quiz_requested.connect(func():
		guide_instance = null
		_open_quiz())

func _open_quiz() -> void:
	if guide_type == FieldGuideUI.GuideType.PLANTS:
		_open_plant_quiz()
	else:
		_open_animal_quiz()

func _open_plant_quiz() -> void:
	if not GameManager.plant_guide_read:
		GameManager.plant_guide_read = true
	
	var quiz_scene = preload("res://scenes/skills/plant/plant_quiz_ui.tscn")
	var quiz_instance = quiz_scene.instantiate()
	quiz_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(quiz_instance)
	
	for plant in plant_entries:
		quiz_instance.plants.append(plant)
	
	quiz_instance.setup()
	quiz_instance.quiz_closed.connect(func(): quiz_instance = null)

func _open_animal_quiz() -> void:
	var quiz_scene = preload("res://scenes/skills/animal/animal_quiz_ui.tscn")
	var quiz_instance = quiz_scene.instantiate()
	quiz_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(quiz_instance)
	
	for animal in animal_entries:
		quiz_instance.animals.append(animal)
	
	quiz_instance.setup()
	quiz_instance.quiz_closed.connect(func(): quiz_instance = null)
