extends CanvasLayer
class_name BadgeMenu

const BADGE_DEFINITIONS = [
	{"id": "fire",       "name": "The Fire Starter",   "emoji": "🔥", "color": Color("#FF6600"),
	 "how": "Bring wood to the campfire pit and light it."},
	{"id": "shelter",    "name": "The Shelter Builder", "emoji": "🏕️", "color": Color("#8B4513"),
	 "how": "Build a shelter using the poles and canvas found near camp."},
	{"id": "tent",       "name": "The Tent Camper",     "emoji": "⛺",  "color": Color("#A0522D"),
	 "how": "Assemble the tent at the designated marker near camp."},
	{"id": "water",      "name": "The Water Guardian",  "emoji": "💧", "color": Color("#0088FF"),
	 "how": "Collect water, boil it on the fire, purify with a tablet, then drink it."},
	{"id": "plants",     "name": "The Nature Reader",   "emoji": "🌿", "color": Color("#228B22"),
	 "how": "Read the plant field guide and pass the plant identification quiz."},
	{"id": "animals",    "name": "The Animal Expert",   "emoji": "🦊", "color": Color("#CC4400"),
	 "how": "Read the animal field guide and pass the animal identification quiz."},
	{"id": "navigation", "name": "The Pathfinder",      "emoji": "🧭", "color": Color("#FFD700"),
	 "how": "Collect all 3 navigation book pages hidden throughout the forest."},
]

var badge_grid: GridContainer
var detail_badge_label: Label
var detail_circle_style: StyleBoxFlat
var detail_name: Label
var detail_status: Label
var detail_how: Label
var progress_label: Label
var badge_buttons: Dictionary = {}
var selected_id: String = ""

func _ready() -> void:
	add_to_group("badge_menu")
	layer = 3
	visible = false
	_build_ui()
	GameManager.badge_earned.connect(func(_id): if visible: _build_grid())

func _build_ui() -> void:
	var font_body  = UiFonts.body
	var font_bold  = UiFonts.body_bold

	# Dim overlay
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.5)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	var root_ctrl = Control.new()
	root_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root_ctrl)

	# Main panel — fixed 700×480, centered
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(700, 480)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left  = -350.0
	panel.offset_top   = -240.0
	panel.offset_right =  350.0
	panel.offset_bottom =  240.0

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#1C2E1A")
	panel_style.border_color = Color("#C68B3A")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	panel_style.content_margin_left   = 18
	panel_style.content_margin_right  = 18
	panel_style.content_margin_top    = 14
	panel_style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", panel_style)
	root_ctrl.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# ── Header ──────────────────────────────────────────────────────────────
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	vbox.add_child(header)

	var title_lbl = Label.new()
	title_lbl.text = "🏆  Badges"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_override("font", font_bold)
	title_lbl.add_theme_font_size_override("font_size", 22)
	title_lbl.add_theme_color_override("font_color", Color("#F5E6C8"))
	header.add_child(title_lbl)

	progress_label = Label.new()
	progress_label.add_theme_font_override("font", font_body)
	progress_label.add_theme_font_size_override("font_size", 14)
	progress_label.add_theme_color_override("font_color", Color("#B8A882"))
	header.add_child(progress_label)

	var close_btn = Button.new()
	close_btn.text = "✕"
	close_btn.flat = true
	close_btn.add_theme_font_override("font", font_bold)
	close_btn.add_theme_font_size_override("font_size", 18)
	close_btn.add_theme_color_override("font_color", Color("#F5E6C8"))
	close_btn.pressed.connect(_close)
	header.add_child(close_btn)

	var sep = HSeparator.new()
	var sep_style = StyleBoxFlat.new()
	sep_style.bg_color = Color("#C68B3A", 0.5)
	sep_style.content_margin_top = 1
	sep.add_theme_stylebox_override("separator", sep_style)
	vbox.add_child(sep)

	# ── Content: grid (left) + detail (right) ───────────────────────────────
	var content = HBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(content)

	# Grid column
	var grid_col = VBoxContainer.new()
	grid_col.custom_minimum_size = Vector2(290, 0)
	grid_col.add_theme_constant_override("separation", 0)
	content.add_child(grid_col)

	badge_grid = GridContainer.new()
	badge_grid.columns = 4
	badge_grid.add_theme_constant_override("h_separation", 10)
	badge_grid.add_theme_constant_override("v_separation", 10)
	grid_col.add_child(badge_grid)

	# Detail column
	var detail_col = VBoxContainer.new()
	detail_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_col.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	detail_col.add_theme_constant_override("separation", 8)
	content.add_child(detail_col)

	# Badge circle in detail
	var circle_center = CenterContainer.new()
	circle_center.custom_minimum_size = Vector2(0, 120)
	detail_col.add_child(circle_center)

	var circle_panel = PanelContainer.new()
	circle_panel.custom_minimum_size = Vector2(100, 100)
	detail_circle_style = StyleBoxFlat.new()
	detail_circle_style.bg_color      = Color("#2A3D28")
	detail_circle_style.border_color  = Color("#C68B3A")
	detail_circle_style.set_border_width_all(3)
	detail_circle_style.set_corner_radius_all(50)
	circle_panel.add_theme_stylebox_override("panel", detail_circle_style)
	circle_center.add_child(circle_panel)

	detail_badge_label = Label.new()
	detail_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_badge_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	detail_badge_label.add_theme_font_size_override("font_size", 40)
	detail_badge_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	detail_badge_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	circle_panel.add_child(detail_badge_label)

	detail_name = Label.new()
	detail_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_name.add_theme_font_override("font", font_bold)
	detail_name.add_theme_font_size_override("font_size", 16)
	detail_name.add_theme_color_override("font_color", Color("#F5E6C8"))
	detail_col.add_child(detail_name)

	detail_status = Label.new()
	detail_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_status.add_theme_font_override("font", font_body)
	detail_status.add_theme_font_size_override("font_size", 13)
	detail_col.add_child(detail_status)

	var how_heading = Label.new()
	how_heading.text = "How to earn:"
	how_heading.add_theme_font_override("font", font_bold)
	how_heading.add_theme_font_size_override("font_size", 13)
	how_heading.add_theme_color_override("font_color", Color("#E8B84B"))
	detail_col.add_child(how_heading)

	detail_how = Label.new()
	detail_how.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_how.add_theme_font_override("font", font_body)
	detail_how.add_theme_font_size_override("font_size", 13)
	detail_how.add_theme_color_override("font_color", Color("#B8A882"))
	detail_col.add_child(detail_how)

	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_col.add_child(spacer)

	_show_detail("")

# ── Grid ─────────────────────────────────────────────────────────────────────

func _build_grid() -> void:
	for child in badge_grid.get_children():
		child.queue_free()
	badge_buttons.clear()

	var earned: Array = GameManager.badges_earned
	var earned_count := 0

	for def in BADGE_DEFINITIONS:
		var bid: String    = def.id
		var is_earned: bool = bid in earned
		if is_earned:
			earned_count += 1

		var btn = Button.new()
		btn.custom_minimum_size = Vector2(60, 60)
		btn.focus_mode = Control.FOCUS_ALL
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		var badge_color: Color = def.color if is_earned else Color("#3A3A3A")
		var border_col: Color  = def.color.lightened(0.3) if is_earned else Color("#555555")

		var normal_style = StyleBoxFlat.new()
		normal_style.bg_color     = badge_color.darkened(0.45)
		normal_style.border_color = border_col
		normal_style.set_border_width_all(2)
		normal_style.set_corner_radius_all(30)
		btn.add_theme_stylebox_override("normal", normal_style)

		var hover_style = normal_style.duplicate()
		hover_style.border_color  = Color("#E8B84B")
		hover_style.shadow_color  = Color("#E8B84B", 0.4)
		hover_style.shadow_size   = 6
		btn.add_theme_stylebox_override("hover", hover_style)
		btn.add_theme_stylebox_override("focus", hover_style)

		var pressed_style = normal_style.duplicate()
		pressed_style.bg_color = badge_color.darkened(0.2)
		btn.add_theme_stylebox_override("pressed", pressed_style)

		var lbl = Label.new()
		lbl.text = def.emoji
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 24)
		lbl.modulate = Color.WHITE if is_earned else Color(0.45, 0.45, 0.45, 0.8)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		btn.add_child(lbl)

		btn.pressed.connect(func(): _select_badge(bid))
		badge_grid.add_child(btn)
		badge_buttons[bid] = btn

	progress_label.text = "%d / %d earned" % [earned_count, BADGE_DEFINITIONS.size()]

	if selected_id != "":
		_show_detail(selected_id)

# ── Detail panel ─────────────────────────────────────────────────────────────

func _select_badge(badge_id: String) -> void:
	selected_id = badge_id
	_show_detail(badge_id)

func _show_detail(badge_id: String) -> void:
	if badge_id == "":
		detail_badge_label.text = "?"
		detail_name.text   = "Select a badge"
		detail_status.text = ""
		detail_how.text    = "Click any badge to learn how to earn it."
		detail_circle_style.bg_color     = Color("#2A3D28")
		detail_circle_style.border_color = Color("#C68B3A")
		return

	var def = _find_def(badge_id)
	if def.is_empty():
		return

	var is_earned: bool = badge_id in GameManager.badges_earned
	detail_badge_label.text = def.emoji

	if is_earned:
		detail_circle_style.bg_color     = (def.color as Color).darkened(0.45)
		detail_circle_style.border_color = (def.color as Color).lightened(0.3)
	else:
		detail_circle_style.bg_color     = Color("#2A2A2A")
		detail_circle_style.border_color = Color("#555555")

	detail_name.text = def.name
	detail_name.add_theme_color_override("font_color",
		(def.color as Color).lightened(0.2) if is_earned else Color("#F5E6C8"))

	if is_earned:
		detail_status.text = "✓  Earned"
		detail_status.add_theme_color_override("font_color", Color("#69F0AE"))
	else:
		detail_status.text = "○  Not yet earned"
		detail_status.add_theme_color_override("font_color", Color("#B8A882"))

	detail_how.text = def.how

func _find_def(badge_id: String) -> Dictionary:
	for def in BADGE_DEFINITIONS:
		if def.id == badge_id:
			return def
	return {}

# ── Open / close ──────────────────────────────────────────────────────────────

func open() -> void:
	var task_menu = get_tree().get_first_node_in_group("task_menu")
	if task_menu and task_menu.visible: task_menu._close()

	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic.set_process(false)
		ic.set_physics_process(false)

	_build_grid()
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var player = get_tree().get_first_node_in_group("player")
	if player: player.ui_open = true

func _close() -> void:
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic.set_process(true)
		ic.set_physics_process(true)

	visible = false
	var player = get_tree().get_first_node_in_group("player")
	if player: player.ui_open = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if not visible: return

	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("badge_menu"):
		_close()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
		return
	# Don't consume primary/secondary — buttons need those via _gui_input().
	# IC is disabled in open() so world interactions can't fire while the menu is open.
	for action in ["move_forward", "move_backward", "move_left", "move_right",
				   "jump", "sprint", "crouch"]:
		if event.is_action(action) and not event.is_action("ui_accept"):
			get_viewport().set_input_as_handled()
			return
