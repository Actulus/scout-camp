extends CanvasLayer
class_name AnimalQuizUI

@export var animals: Array[AnimalInfo] = []

@onready var progress_label: Label = %ProgressLabel
@onready var animal_name_label: Label = %AnimalNameLabel
@onready var animal_info_label: Label = %AnimalInfoLabel
@onready var animal_image: TextureRect = %AnimalImage
@onready var safe_btn: Button = %SafeButton
@onready var dangerous_btn: Button = %DangerousButton
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
	add_to_group("animal_quiz")
	safe_btn.pressed.connect(func(): _answer(false))
	dangerous_btn.pressed.connect(func(): _answer(true))
	prev_btn.pressed.connect(func(): _navigate(-1))
	next_btn.pressed.connect(func(): _navigate(1))
	submit_btn.pressed.connect(_submit)
	_style_answer_buttons()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func setup() -> void:
	var hud = get_tree().get_first_node_in_group("hud_hints")
	if hud: hud.set_context("quiz")
	correct_answers.clear()
	for animal in animals:
		correct_answers[animal.animal_id] = animal.is_dangerous
	if animals.size() > 0:
		_show_animal(0)
	_update_submit_state()
	_freeze_player(true)
	status_label.text = "[E] Safe  [P] Dangerous  [←→] Navigate"

func _freeze_player(frozen: bool) -> void:
	# show/hide mouse
	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE if frozen else Input.MOUSE_MODE_CAPTURED)
	
	if frozen:
		await get_tree().process_frame
		await get_tree().process_frame
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
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

func _show_animal(index: int) -> void:
	current_index = index
	var animal = animals[index]
	
	progress_label.text = "Animal %d of %d" % [index + 1, animals.size()]
	animal_name_label.text = animal.display_name
	animal_info_label.text = animal.description
	
	animal_info_label.text = animal.description if animal.description else ""
	animal_info_label.custom_minimum_size = Vector2(0, 60)
	animal_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# show image if available, color fallback if not
	if animal.image != null:
		animal_image.texture = animal.image
		animal_image.modulate = Color.WHITE
	else:
		animal_image.texture = null
		# color hint as fallback
		animal_image.modulate = Color(0.8, 0.2, 0.2) if animal.is_dangerous else Color(0.2, 0.8, 0.2)
	
	animal_image.custom_minimum_size = Vector2(300, 320)
	animal_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	animal_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	status_label.text = "[E] Safe  [P] Dangerous  [←→] Navigate"
	status_label.modulate = Color.WHITE
	
	if wrong_answers and animal.animal_id in wrong_answers:
		status_label.text = "❌ Wrong! Check the guide and try again."
		status_label.modulate = Color(1.0, 0.3, 0.3)
	elif player_answers.has(animal.animal_id):
		var prev_answer = player_answers[animal.animal_id]
		status_label.text = "✓ Categorized as: " + \
			("Safe [E]" if prev_answer else "Dangerous [P]")
		status_label.modulate = Color(0.3, 1.0, 0.3)
		_highlight_buttons(prev_answer)
	else:
		_highlight_buttons(null)
	
	# update navigation buttons
	prev_btn.disabled = index == 0
	next_btn.disabled = index == animals.size() - 1

func _answer(is_dangerous: bool) -> void:
	var animal: AnimalInfo = animals[current_index]
	player_answers[animal.animal_id] = is_dangerous
	# clear wrong flag when player re-answers
	wrong_answers.erase(animal.animal_id)
	
	var label = "Dangerous" if is_dangerous else "Safe"
	status_label.text = animal.display_name + " marked as " + label
	status_label.modulate = Color.WHITE
	_highlight_buttons(is_dangerous)
	_update_submit_state()
	
	# auto advance to next unanswered animal
	await get_tree().create_timer(0.5).timeout
	_go_to_next_unanswered()

func _go_to_next_unanswered() -> void:
	# find next unanswered animal after current
	for i in range(current_index + 1, animals.size()):
		if not player_answers.has(animals[i].animal_id):
			_show_animal(i)
			return
	# if all after are answered check before
	for i in range(0, current_index):
		if not player_answers.has(animals[i].animal_id):
			_show_animal(i)
			return
	# all answered — stay on current

func _navigate(direction: int) -> void:
	var new_index = clamp(current_index + direction, 0, animals.size() - 1)
	_show_animal(new_index)

func _highlight_buttons(is_dangerous) -> void:
	# reset both
	safe_btn.modulate = Color.WHITE
	dangerous_btn.modulate = Color.WHITE
	if is_dangerous == null:
		return
	if is_dangerous:
		dangerous_btn.modulate = Color(1.0, 0.5, 0.5)
	else:
		safe_btn.modulate = Color(0.5, 1.0, 0.5)

func _update_submit_state() -> void:
	submit_btn.disabled = player_answers.size() < animals.size()
	if not submit_btn.disabled:
		status_label.text = "All animals categorized! Press Submit to confirm."

func _submit() -> void:
	var correct_count = 0
	wrong_answers.clear()
	var wrong_animal_names: Array = []
	
	for animal in animals:
		if player_answers.get(animal.animal_id) != correct_answers[animal.animal_id]:
			wrong_answers.append(animal.animal_id)
			wrong_animal_names.append(animal.display_name)
	
	
	if wrong_answers.is_empty():
		status_label.text = "✓ Perfect! All animals correctly identified!"
		status_label.modulate = Color(0.3, 1.0, 0.3)
		GameManager.complete_skill("animals")
		await get_tree().create_timer(2.0).timeout
		_close()
	else:
		status_label.text = "❌ Incorrect: " + ", ".join(wrong_animal_names)
		status_label.modulate = Color(1.0, 0.3, 0.3)
		
		# clear only wrong answers so player retries just those
		for animal_id in wrong_answers:
			player_answers.erase(animal_id)
		
		_update_submit_state()
		
		# navigate to first wrong animal
		for i in range(animals.size()):
			if animals[i].animal_id in wrong_answers:
				_show_animal(i)
				return

func _close() -> void:
	var hud = get_tree().get_first_node_in_group("hud_hints")
	if hud: hud.set_context("default")
	_freeze_player(false)
	emit_signal("quiz_closed")
	queue_free()

func _input(event: InputEvent) -> void:
	if not visible:
		return
		
	# block Tab entirely in quiz
	if event is InputEventKey and event.keycode == KEY_TAB:
		get_viewport().set_input_as_handled()
		return
		
	# close with Escape/B button
	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()
		return
		
	# answer with E (safe) and P (dangerous) — must come before book_next check (E is bound to book_next)
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_E:
				_answer(false)
				get_viewport().set_input_as_handled()
				return
			KEY_P:
				_answer(true)
				get_viewport().set_input_as_handled()
				return
			KEY_TAB:
				get_viewport().set_input_as_handled()
				return

	# navigate animals with arrow keys / dpad
	if event.is_action_pressed("ui_right") or event.is_action_pressed("book_next"):
		_navigate(1)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_left") or event.is_action_pressed("book_prev"):
		_navigate(-1)
		get_viewport().set_input_as_handled()
		return

	# submit with Enter when all answered
	if event.is_action_pressed("ui_accept"):
		if not submit_btn.disabled:
			_submit()
		get_viewport().set_input_as_handled()
		return
		
	# block movement
	if event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
		return
	for action in ["move_forward", "move_backward", "move_left",
				   "move_right", "jump", "sprint", "crouch", "book_next", "book_prev"]:
		if event.is_action(action):
			get_viewport().set_input_as_handled()
			return

func _style_answer_buttons() -> void:
	var font_bold = UiFonts.body_bold
	if not font_bold:
		push_error("UiFonts.body_bold is null")
		return
		
	# safe - green
	var safe_style = StyleBoxFlat.new()
	safe_style.bg_color = Color("#2E7D32")
	safe_style.border_color = Color("#69F0AE")
	safe_style.set_border_width_all(2)
	safe_style.set_corner_radius_all(12)
	safe_style.content_margin_left = 24
	safe_style.content_margin_right = 24
	safe_style.content_margin_top = 12
	safe_style.content_margin_bottom = 12
	safe_style.shadow_color = Color(0, 0, 0, 0.3)
	safe_style.shadow_size = 4
	safe_style.shadow_offset = Vector2(0, 3)
	
	var safe_hover = safe_style.duplicate()
	safe_hover.bg_color = Color("#43A047")
	safe_hover.border_color = Color("#B9F6CA")
	
	safe_btn.add_theme_stylebox_override("normal", safe_style)
	safe_btn.add_theme_stylebox_override("hover", safe_hover)
	safe_btn.add_theme_font_override("font", font_bold)
	safe_btn.add_theme_font_size_override("font_size", 18)
	safe_btn.add_theme_color_override("font_color", Color.WHITE)
	
	# dangerous - red
	var danger_style = StyleBoxFlat.new()
	danger_style.bg_color = Color("#C62828")
	danger_style.border_color = Color("#FF8A80")
	danger_style.set_border_width_all(2)
	danger_style.set_corner_radius_all(12)
	danger_style.content_margin_left = 24
	danger_style.content_margin_right = 24
	danger_style.content_margin_top = 12
	danger_style.content_margin_bottom = 12
	danger_style.shadow_color = Color(0, 0, 0, 0.3)
	danger_style.shadow_size = 4
	danger_style.shadow_offset = Vector2(0, 3)
	
	var danger_hover = danger_style.duplicate()
	danger_hover.bg_color = Color("#E53935")
	danger_hover.border_color = Color("#FFCDD2")
	
	dangerous_btn.add_theme_stylebox_override("normal", danger_style)
	dangerous_btn.add_theme_stylebox_override("hover", danger_hover)
	dangerous_btn.add_theme_font_override("font", font_bold)
	dangerous_btn.add_theme_font_size_override("font_size", 18)
	dangerous_btn.add_theme_color_override("font_color", Color.WHITE)
