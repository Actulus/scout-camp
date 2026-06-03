extends CanvasLayer
class_name BadgeUI

@onready var badge_grid: GridContainer = %BadgeGrid
@onready var earned_label: Label = %EarnedLabel
@onready var detail_panel: PanelContainer = %BadgeDetail
@onready var detail_image: TextureRect = %DetailImage
@onready var detail_title: Label = %DetailTitle
@onready var detail_desc: Label = %DetailDescription
#@onready var close_btn: Button = %CloseButton

signal closed

var selected_badge_id: String = ""

func _ready() -> void:
	add_to_group("badge_ui")
	#close_btn.pressed.connect(func(): _close())
	detail_panel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var player = get_tree().get_first_node_in_group("player")
	if player: player.ui_open = true
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic.set_process(false)
		ic.set_physics_process(false)
	_build_grid()

func _build_grid() -> void:
	# clear existing
	for child in badge_grid.get_children():
		child.queue_free()
	
	var earned_count = GameManager.badges_earned.size()
	var total = GameManager.BADGE_DATA.size()
	earned_label.text = "%d / %d earned" % [earned_count, total]
	
	for badge_id in GameManager.BADGE_DATA:
		var data = GameManager.BADGE_DATA[badge_id]
		var is_earned = badge_id in GameManager.badges_earned
		
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(80, 80)
		btn.focus_mode = Control.FOCUS_ALL
		btn.text = ""
		
		# badge background style
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(12)
		style.set_border_width_all(2)
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 8
		style.content_margin_bottom = 8
		
		if is_earned:
			style.bg_color = Color(data.color)
			style.border_color = Color("#E8B84B")
		else:
			style.bg_color = Color("#2A3D28")
			style.border_color = Color("#3A4A38")
		
		var focus_style = style.duplicate()
		focus_style.border_color = Color("#E8B84B")
		focus_style.shadow_color = Color("#E8B84B", 0.4)
		focus_style.shadow_size = 6
		
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", focus_style.duplicate())
		btn.add_theme_stylebox_override("focus", focus_style)
		
		# badge icon label inside button
		var vbox = VBoxContainer.new()
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		btn.add_child(vbox)
		
		var icon = Label.new()
		icon.text = data.icon if is_earned else "🔒"
		icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon.add_theme_font_size_override("font_size", 28)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if not is_earned:
			icon.modulate = Color(0.4, 0.4, 0.4)
		vbox.add_child(icon)
		
		var id = badge_id
		btn.pressed.connect(func(): _show_detail(id))
		badge_grid.add_child(btn)

func _show_detail(badge_id: String) -> void:
	selected_badge_id = badge_id
	var data = GameManager.BADGE_DATA[badge_id]
	var is_earned = badge_id in GameManager.badges_earned
	
	detail_panel.visible = true
	
	# large icon
	detail_image.text = data.icon if is_earned else "🔒"
	detail_image.add_theme_font_size_override("font_size", 64)
	if is_earned:
		detail_image.modulate = Color.WHITE
	else:
		detail_image.modulate = Color(0.4, 0.4, 0.4)
	
	detail_title.text = data.title
	
	if is_earned:
		detail_desc.text = data.description + "\n\n✓ Earned!"
		detail_desc.add_theme_color_override("font_color", Color("#B9F6CA"))
	else:
		detail_desc.text = data.description
		detail_desc.add_theme_color_override("font_color", Color("#B8A882"))

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
	if event.is_action_pressed("ui_cancel"):
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
