extends CanvasLayer
class_name PlantQuizUI

@export var plants: Array[PlantInfo] = []

@onready var progress_label: Label = %ProgressLabel
@onready var plant_name_label: Label = %PlantNameLabel
@onready var plant_info_label: Label = %PlantInfoLabel
@onready var plant_image: TextureRect = %PlantImage
@onready var edible_btn: Button = %EdibleButton
@onready var poisonous_btn: Button = %PoisonousButton
@onready var status_label: Label = %StatusLabel
@onready var submit_btn: Button = %SubmitButton
@onready var prev_btn: Button = %PrevButton
@onready var next_btn: Button = %NextButton

var current_index: int = 0
var player_answers: Dictionary = {}
var correct_answers: Dictionary = {}
var wrong_answers: Array = []

signal quiz_completed
signal quiz_closed

func _ready() -> void:
	edible_btn.pressed.connect(func(): _answer(true))
	poisonous_btn.pressed.connect(func(): _answer(false))
	prev_btn.pressed.connect(func(): _navigate(-1))
	next_btn.pressed.connect(func(): _navigate(1))
	submit_btn.pressed.connect(_submit)

func setup() -> void:
	correct_answers.clear()
	for plant in plants:
		correct_answers[plant.plant_id] = plant.is_safe
	if plants.size() > 0:
		_show_plant(0)
	_update_submit_state()
	_freeze_player(true)

func _freeze_player(frozen: bool) -> void:
	# show/hide mouse
	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE if frozen else Input.MOUSE_MODE_CAPTURED)
	
	# freeze player movement
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(not frozen)
	
	# disable interaction raycast so player can't interact with world
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic.set_process(not frozen)
		ic.set_physics_process(not frozen)
		ic.interaction_raycast.enabled = not frozen

func _show_plant(index: int) -> void:
	current_index = index
	var plant = plants[index]
	
	progress_label.text = "Plant %d of %d" % [index + 1, plants.size()]
	plant_name_label.text = plant.display_name
	plant_info_label.text = plant.visual_clue
	
	# show image if available, color fallback if not
	if plant.image != null:
		plant_image.texture = plant.image
		plant_image.modulate = Color.WHITE
	else:
		plant_image.texture = null
		# color hint as fallback
		plant_image.modulate = Color(0.2, 0.8, 0.2) if plant.is_safe else Color(0.8, 0.2, 0.2)
	
	status_label.text = ""
	if plant.plant_id in wrong_answers:
		status_label.text = "❌ Wrong! Try again."
		status_label.modulate = Color(1.0, 0.3, 0.3)
	elif player_answers.has(plant.plant_id):
		var prev_answer = player_answers[plant.plant_id]
		status_label.text = "✓ Categorized as: " + ("Edible" if prev_answer else "Poisonous")
		status_label.modulate = Color(0.3, 1.0, 0.3)
		_highlight_buttons(prev_answer)
	else:
		status_label.modulate = Color.WHITE
		_highlight_buttons(null)
	
	# update navigation buttons
	prev_btn.disabled = index == 0
	next_btn.disabled = index == plants.size() - 1

func _answer(is_edible: bool) -> void:
	var plant: PlantInfo = plants[current_index]
	player_answers[plant.plant_id] = is_edible
	# clear wrong flag when player re-answers
	wrong_answers.erase(plant.plant_id)
	
	var label = "Edible" if is_edible else "Poisonous"
	status_label.text = plant.display_name + " marked as " + label
	status_label.modulate = Color.WHITE
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
	wrong_answers.clear()
	var wrong_plant_names: Array = []
	
	for plant in plants:
		if player_answers.get(plant.plant_id) != correct_answers[plant.plant_id]:
			wrong_answers.append(plant.plant_id)
			wrong_plant_names.append(plant.display_name)
	
	
	if wrong_answers.is_empty():
		status_label.text = "✓ Perfect! All plants correctly identified!"
		status_label.modulate = Color(0.3, 1.0, 0.3)
		GameManager.complete_skill("plants")
		await get_tree().create_timer(2.0).timeout
		_close()
	else:
		status_label.text = "❌ Incorrect: " + ", ".join(wrong_plant_names)
		status_label.modulate = Color(1.0, 0.3, 0.3)
		
		# clear only wrong answers so player retries just those
		for plant_id in wrong_answers:
			player_answers.erase(plant_id)
		
		_update_submit_state()
		
		# navigate to first wrong plant
		for i in range(plants.size()):
			if plants[i].plant_id in wrong_answers:
				_show_plant(i)
				return

func _close() -> void:
	_freeze_player(false)
	emit_signal("quiz_closed")
	queue_free()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	# block mouse motion so camera doesn't rotate
	if event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
		return
	# only block movement keys, not mouse clicks on UI
	if event is InputEventKey:
		for action in ["move_forward", "move_backward", "move_left", 
					   "move_right", "jump", "sprint", "crouch"]:
			if event.is_action(action):
				get_viewport().set_input_as_handled()
				return
