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
		var panel = _create_task_panel(task)
		task_list.add_child(panel)
		task_panels[task.id] = panel
	_update_progress()

func _create_task_panel(task: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.name = "Task_" + task.id
	
	# style based on completion
	var style = StyleBoxFlat.new()
	var is_done = GameManager.skills_completed.get(task.id, false)
	style.bg_color = Color("#1B5E20") if is_done else Color("#1A237E", 0.8)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# header row
	var header = HBoxContainer.new()
	vbox.add_child(header)
	
	var title = Label.new()
	title.text = task.title
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	var status = Label.new()
	status.text = "✓ Done" if is_done else "○ Todo"
	status.add_theme_color_override("font_color", 
		Color("#69F0AE") if is_done else Color("#90CAF9"))
	status.add_theme_font_size_override("font_size", 13)
	header.add_child(status)
	panel.set_meta("status_label", status)
	panel.set_meta("style", style)
	panel.set_meta("task_id", task.id)
	
	# description (collapsed by default, expand on click)
	var desc = Label.new()
	desc.text = task.description
	desc.add_theme_color_override("font_color", Color("#B0BEC5"))
	desc.add_theme_font_size_override("font_size", 12)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.visible = false
	vbox.add_child(desc)
	panel.set_meta("desc_label", desc)
	
	# hint
	var hint = Label.new()
	hint.text = "💡 " + task.hint
	hint.add_theme_color_override("font_color", Color("#FFD54F"))
	hint.add_theme_font_size_override("font_size", 11)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.visible = false
	vbox.add_child(hint)
	panel.set_meta("hint_label", hint)
	
	# make panel clickable to expand/collapse
	var btn = Button.new()
	btn.flat = true
	btn.text = ""
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(func(): _toggle_task(panel))
	# overlay button covers the panel
	panel.add_child(btn)
	
	return panel

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
	status.text = "✓ Done"
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

func _close() -> void:
	visible = false
	if not get_tree().get_first_node_in_group("plant_quiz"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.is_action("task_menu"):
			if visible:
				_close()
			else:
				open()
			get_viewport().set_input_as_handled()
			return
	
	if not visible: return
	
	if event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
	if event is InputEventKey:
		for action in ["move_forward", "move_backward", "move_left",
					   "move_right", "jump", "sprint", "crouch"]:
			if event.is_action(action):
				get_viewport().set_input_as_handled()
				return
