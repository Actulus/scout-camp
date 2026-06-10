extends CanvasLayer

var _card: Control

func _ready() -> void:
	layer = 12
	_build_popup()
	_animate_in()

func _build_popup() -> void:
	var font_body = UiFonts.body
	var font_bold = UiFonts.body_bold

	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed: _dismiss())
	add_child(overlay)

	var root_ctrl = Control.new()
	root_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_ctrl)

	_card = PanelContainer.new()
	_card.custom_minimum_size = Vector2(420, 0)
	_card.set_anchors_preset(Control.PRESET_CENTER)
	_card.offset_left  = -210.0
	_card.offset_right =  210.0
	_card.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_card.grow_vertical   = Control.GROW_DIRECTION_BOTH
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color("#1C2E1A")
	card_style.border_color = Color("#E8B84B")
	card_style.set_border_width_all(3)
	card_style.set_corner_radius_all(18)
	card_style.content_margin_left   = 28
	card_style.content_margin_right  = 28
	card_style.content_margin_top    = 24
	card_style.content_margin_bottom = 24
	card_style.shadow_color = Color("#E8B84B", 0.3)
	card_style.shadow_size  = 20
	_card.add_theme_stylebox_override("panel", card_style)
	root_ctrl.add_child(_card)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(vbox)

	# Trophy + heading
	var trophy = Label.new()
	trophy.text = "🏆"
	trophy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trophy.add_theme_font_size_override("font_size", 56)
	trophy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(trophy)

	var heading = Label.new()
	heading.text = "Scout Badge Master!"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_override("font", font_bold)
	heading.add_theme_font_size_override("font_size", 22)
	heading.add_theme_color_override("font_color", Color("#E8B84B"))
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(heading)

	var sub = Label.new()
	sub.text = "You've mastered all five wilderness skills\nand earned every Scout badge!"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.add_theme_font_override("font", font_body)
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_color_override("font_color", Color("#F5E6C8"))
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(sub)

	# Badge icon row
	var badge_row = HBoxContainer.new()
	badge_row.alignment = BoxContainer.ALIGNMENT_CENTER
	badge_row.add_theme_constant_override("separation", 10)
	badge_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(badge_row)

	for badge_id in GameManager.BADGE_DATA:
		var data = GameManager.BADGE_DATA[badge_id]
		var circle = PanelContainer.new()
		circle.custom_minimum_size = Vector2(52, 52)
		circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var cs = StyleBoxFlat.new()
		cs.bg_color     = (Color(data.color) as Color).darkened(0.4)
		cs.border_color = (Color(data.color) as Color).lightened(0.2)
		cs.set_border_width_all(2)
		cs.set_corner_radius_all(26)
		circle.add_theme_stylebox_override("panel", cs)

		var icon_lbl = Label.new()
		icon_lbl.text = data.icon
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		icon_lbl.add_theme_font_size_override("font_size", 24)
		icon_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		circle.add_child(icon_lbl)
		badge_row.add_child(circle)

	var hint = Label.new()
	hint.text = "Click anywhere to close"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_override("font", font_body)
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color("#9BB89A"))
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(hint)

func _animate_in() -> void:
	_card.scale    = Vector2(0.5, 0.5)
	_card.modulate = Color(1, 1, 1, 0)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(_card, "scale",    Vector2(1.0, 1.0), 0.5)
	tween.parallel().tween_property(_card, "modulate", Color(1, 1, 1, 1), 0.35)

func _dismiss() -> void:
	if not is_instance_valid(self): return
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(_card, "scale",    Vector2(0.5, 0.5), 0.3)
	tween.parallel().tween_property(_card, "modulate", Color(1, 1, 1, 0), 0.25)
	tween.tween_callback(queue_free)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		_dismiss()
		get_viewport().set_input_as_handled()
