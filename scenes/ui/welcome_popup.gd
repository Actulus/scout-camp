extends CanvasLayer
class_name WelcomePopup

@onready var close_btn: Button = %CloseButton
@onready var title_label: Label = %TitleLabel
@onready var content_label: RichTextLabel = %ContentLabel

signal closed

const WELCOME_TEXT = """
You have arrived at a scout camp deep in the forest. Before you can earn your badges and complete your training, you must master five essential wilderness survival skills.

[b]Your tasks:[/b]

[color=#FF6600]🔥 Light a Fire[/color] — Find wood in the forest and use it on the fire pit.

[color=#8B4513]⛺ Set Up Shelter[/color] — Locate tent poles and canvas, then assemble your tent.

[color=#0099FF]💧 Purify Water[/color] — Collect water from the river, boil it over the fire, and add a purification tablet.

[color=#228B22]🌿 Identify Plants[/color] — Read the plant field guide in the camp house, then take the identification quiz.

[color=#FFD700]🧭 Navigate the Camp[/color] — Find the map and compass, then collect all three journal pages scattered in the forest.

[b]Tips:[/b]
- Press [color=#E8B84B][T][/color] to open your task list at any time
- Press [color=#E8B84B][M][/color] to view the camp map
- Press [color=#E8B84B][Tab][/color] to open your inventory
- The camp house has books, tools and a warm bed that you can use to save your progress

[center][i]Good luck, Scout. The forest is waiting.[/i][/center]"""

func _ready() -> void:
	add_to_group("welcome_popup")
	close_btn.pressed.connect(_close)
	title_label.text = "🏕 Camp Brightwood"
	content_label.parse_bbcode(WELCOME_TEXT)
	content_label.add_theme_color_override("default_color", Color("#F5E6C8"))
	
	var player = get_tree().get_first_node_in_group("player")
	if player: player.ui_open = true
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic.set_process(false)
		ic.set_physics_process(false)
	
	await get_tree().process_frame
	await get_tree().process_frame
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# focus close button for keyboard/controller
	close_btn.grab_focus.call_deferred()

func _close() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player: player.ui_open = false
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic.set_process(true)
		ic.set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("closed")
	queue_free()

func _input(event: InputEvent) -> void:
	if not visible: return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
		return
	for action in ["move_forward", "move_backward", "move_left",
				   "move_right", "jump", "sprint", "crouch"]:
		if event.is_action(action):
			get_viewport().set_input_as_handled()
			return
