extends CanvasLayer
class_name TaskMenu

@onready var task_list: VBoxContainer = %TaskList
@onready var progress_label: Label = %ProgressLabel

const TASKS = [
	{
		"id": "fire",
		"title": "🔥 Light a Fire",
		"description": "Find wood in the forest.\nBring it to the fire pit at camp.\nUse wood on the fire pit 3 times to light it.",
		"hint": "Look for wood scattered near the trees."
	},
	{
		"id": "tent",
		"title": "⛺ Set Up Shelter",
		"description": "Find the tent poles and canvas near camp.\nEquip each and use on the tent spot marker.",
		"hint": "The tent spot is marked with a white circle near the fire pit."
	},
	{
		"id": "water",
		"title": "💧 Purify Water",
		"description": "1. Collect water from the river with a bucket.\n2. Pour into the cooking pot on the fire.\n3. Wait for it to boil.\n4. Use a mug to collect boiled water.\n5. Add a purification tablet.\n6. Drink the purified water.",
		"hint": "The bucket is near camp. The river is to the west."
	},
	{
		"id": "plants",
		"title": "🌿 Identify Plants",
		"description": "Find and read the plant field guide.\nThen go to the notice board at the forest edge.\nIdentify which plants are edible or poisonous.",
		"hint": "The field guide is in the camp house bookshelf."
	},
	{
		"id": "navigation",
		"title": "🧭 Navigate the Camp",
		"description": "Find the map and compass near camp.\nPress M to open the map.\nCollect all 3 navigation book pages in the forest.",
		"hint": "Look for glowing markers on the map showing page locations."
	}
]

var task_panels: Dictionary = {}

func _ready() -> void:
	add_to_group("task_menu")
	visible = false
	_build_task_list()
	GameManager.skill_completed.connect(_on_skill_completed)

func _build_task_list() -> void:
	for task in TASKS:
		var panel: Control = _create_task_panel(task)
		task_list.add_child(panel)
		task_panels[task.id] = panel
	_update_progress()

func _create_task_panel(task: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var style = StyleBoxFlat.new()
	var is_done = GameManager.skills_completed.get(task.id, false)
	style.bg_color = Color("#1B5E20") if is_done else Color("#1C2E1A")
	style.border_color = Color("#C68B3A")
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	panel.set_meta("style", style)
	panel.set_meta("task_id", task.id)
	
	panel.focus_mode = Control.FOCUS_ALL
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	panel.add_theme_stylebox_override("focus", _make_focus_style())
	
	panel.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				panel.accept_event()
				panel.grab_focus()
				_toggle_task(panel)
		if event.is_action_pressed("ui_accept"):
			panel.accept_event()
			_toggle_task(panel))
	
	var font_body = UiFonts.body
	var font_bold = UiFonts.body_bold
	
	var vbox = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)
	
	var header = HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(header)
	
	var title = Label.new()
	title.text = task.title
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.add_theme_font_override("font", font_bold)
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", Color("#F5E6C8"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	var status = Label.new()
	status.text = "✓" if is_done else "○"
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status.add_theme_font_override("font", font_bold)
	status.add_theme_color_override("font_color",
		Color("#69F0AE") if is_done else Color("#B8A882"))
	header.add_child(status)
	panel.set_meta("status_label", status)
	
	var desc = Label.new()
	desc.text = task.description
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc.add_theme_font_override("font", font_body)
	desc.add_theme_font_size_override("font_size", 13)
	desc.add_theme_color_override("font_color", Color("#B8A882"))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.visible = false
	vbox.add_child(desc)
	panel.set_meta("desc_label", desc)
	
	var hint = Label.new()
	hint.text = "💡 " + task.hint
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.add_theme_font_override("font", font_body)
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color("#E8B84B"))
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.visible = false
	vbox.add_child(hint)
	panel.set_meta("hint_label", hint)
	
	panel.focus_entered.connect(func():
		var focused_style = _make_focus_style()
		panel.add_theme_stylebox_override("panel", focused_style))
	panel.focus_exited.connect(func():
		panel.add_theme_stylebox_override("panel", style))
		
	return panel

func _make_focus_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#2A3D28", 0.0)  # transparent bg
	s.border_color = Color("#E8B84B")
	s.set_border_width_all(3)
	s.set_corner_radius_all(8)
	s.shadow_color = Color("#E8B84B", 0.3)
	s.shadow_size = 6
	return s

func _toggle_task(panel: PanelContainer) -> void:
	var desc = panel.get_meta("desc_label") as Label
	var hint = panel.get_meta("hint_label") as Label
	desc.visible = not desc.visible
	hint.visible = not hint.visible

func _on_skill_completed(skill_id: String) -> void:
	if not task_panels.has(skill_id):
		return
	var panel = task_panels[skill_id] as PanelContainer
	var style = panel.get_meta("style") as StyleBoxFlat
	var status = panel.get_meta("status_label") as Label
	style.bg_color = Color("#1B5E20")
	panel.add_theme_stylebox_override("panel", style)
	status.text = "✓"
	status.add_theme_color_override("font_color", Color("#69F0AE"))
	_update_progress()

func _update_progress() -> void:
	var done = 0
	for task in TASKS:
		if GameManager.skills_completed.get(task.id, false):
			done += 1
	progress_label.text = "%d / %d tasks completed" % [done, TASKS.size()]

func open() -> void:
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var player = get_tree().get_first_node_in_group("player")
	if player: player.ui_open = true
	await get_tree().process_frame
	if task_list.get_child_count() > 0:
		task_list.get_child(0).grab_focus()

func _close() -> void:
	visible = false
	var player = get_tree().get_first_node_in_group("player")
	if player: player.ui_open = false
	if not get_tree().get_first_node_in_group("plant_quiz"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if not visible: return

	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		for panel in task_panels.values():
			if panel.get_global_rect().has_point(event.global_position):
				panel.grab_focus()
				_toggle_task(panel)
				get_viewport().set_input_as_handled()
				return

	if event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
		return

	var movement_actions = [
		"move_forward", "move_backward", "move_left", "move_right"
	]
	for action in movement_actions:
		if event.is_action(action):
			var is_ui = event.is_action("ui_up") or event.is_action("ui_down") or \
						event.is_action("ui_left") or event.is_action("ui_right") or \
						event.is_action("ui_accept")
			if not is_ui:
				get_viewport().set_input_as_handled()
			return

	for action in ["jump", "sprint", "crouch", "primary", "secondary",
				   "lean_left", "lean_right"]:
		if event.is_action(action) and not event.is_action("ui_accept"):
			get_viewport().set_input_as_handled()
			return
