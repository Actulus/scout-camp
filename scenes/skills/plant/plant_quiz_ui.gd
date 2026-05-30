extends CanvasLayer
class_name PlantQuizUI

@export var plants: Array[PlantInfo] = []

@onready var progress_label: Label = %ProgressLabel
@onready var plant_name_label: Label = %PlantNameLabel
@onready var plant_info_label: Label = %PlantInfoLabel
@onready var plant_color_rect: ColorRect = %PlantImage
@onready var edible_btn: Button = %EdibleButton
@onready var poisonous_btn: Button = %PoisonousButton
@onready var status_label: Label = %StatusLabel
@onready var submit_btn: Button = %SubmitButton
@onready var prev_btn: Button = %PrevButton
@onready var next_btn: Button = %NextButton

var current_index: int = 0
var player_answers: Dictionary = {}
var correct_answers: Dictionary = {}

signal quiz_completed
signal quiz_closed

func _ready() -> void:
	edible_btn.pressed.connect(func(): _answer(true))
	poisonous_btn.pressed.connect(func(): _answer(false))
	prev_btn.pressed.connect(func(): _navigate(-1))
	next_btn.pressed.connect(func(): _navigate(1))
	submit_btn.pressed.connect(_submit)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# don't call _show_plant here — plants not assigned yet

func setup() -> void:
	# no signal connections here — only data setup
	correct_answers.clear()
	for plant in plants:
		correct_answers[plant.plant_id] = plant.is_safe
	if plants.size() > 0:
		_show_plant(0)
	_update_submit_state()
	
	# release mouse, block player movement
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _show_plant(index: int) -> void:
	current_index = index
	var plant = plants[index]
	
	plant_color_rect.color = Color(0.2, 0.8, 0.2) if plant.is_safe else Color(0.8, 0.2, 0.2)
	
	progress_label.text = "Plant %d of %d" % [index + 1, plants.size()]
	plant_name_label.text = plant.display_name
	plant_info_label.text = plant.visual_clue
	
	# show previous answer if already categorized
	status_label.text = ""
	if player_answers.has(plant.plant_id):
		var prev = player_answers[plant.plant_id]
		status_label.text = "Categorized as: " + ("Edible" if prev else "Poisonous")
		_highlight_buttons(prev)
	else:
		_highlight_buttons(null)
	
	# update navigation buttons
	prev_btn.disabled = index == 0
	next_btn.disabled = index == plants.size() - 1

func _answer(is_edible: bool) -> void:
	var plant: PlantInfo = plants[current_index]
	player_answers[plant.plant_id] = is_edible
	
	var label = "Edible" if is_edible else "Poisonous"
	status_label.text = plant.display_name + " marked as " + label
	_highlight_buttons(is_edible)
	_update_submit_state()
	
	# auto advance to next unanswered plant
	await get_tree().create_timer(0.5).timeout
	_go_to_next_unanswered()

func _go_to_next_unanswered() -> void:
	# find next unanswered plant after current
	for i in range(current_index + 1, plants.size()):
		if not player_answers.has(plants[i].plant_id):
			_show_plant(i)
			return
	# if all after are answered check before
	for i in range(0, current_index):
		if not player_answers.has(plants[i].plant_id):
			_show_plant(i)
			return
	# all answered — stay on current

func _navigate(direction: int) -> void:
	var new_index = clamp(current_index + direction, 0, plants.size() - 1)
	_show_plant(new_index)

func _highlight_buttons(is_edible) -> void:
	# reset both
	edible_btn.modulate = Color.WHITE
	poisonous_btn.modulate = Color.WHITE
	if is_edible == null:
		return
	if is_edible:
		edible_btn.modulate = Color(0.5, 1.0, 0.5)
	else:
		poisonous_btn.modulate = Color(1.0, 0.5, 0.5)

func _update_submit_state() -> void:
	submit_btn.disabled = player_answers.size() < plants.size()
	if not submit_btn.disabled:
		status_label.text = "All plants categorized! Press Submit to confirm."

func _submit() -> void:
	var correct_count = 0
	var wrong_plants: Array = []
	
	for plant in plants:
		if player_answers.get(plant.plant_id) == correct_answers[plant.plant_id]:
			correct_count += 1
		else:
			wrong_plants.append(plant.display_name)
	
	if wrong_plants.is_empty():
		status_label.text = "Perfect! All plants correctly identified!"
		GameManager.complete_skill("plants")
		await get_tree().create_timer(2.0).timeout
		_close()
	else:
		status_label.text = "Incorrect: " + ", ".join(wrong_plants) + "\nCheck the guide and try again."
		# clear wrong answers only
		for plant in plants:
			if player_answers.get(plant.plant_id) != correct_answers[plant.plant_id]:
				player_answers.erase(plant.plant_id)
		_update_submit_state()
		# show first wrong plant
		for i in range(plants.size()):
			if not player_answers.has(plants[i].plant_id):
				_show_plant(i)
				return

func _close() -> void:
	# restore mouse capture
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("quiz_closed")
	queue_free()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	# only block movement keys, not mouse clicks on UI
	if event is InputEventKey:
		var action_keys = ["move_forward", "move_backward", "move_left", 
						  "move_right", "jump", "sprint", "crouch"]
		for action in action_keys:
			if event.is_action(action):
				get_viewport().set_input_as_handled()
				return
	# block mouse motion so camera doesn't move
	if event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
