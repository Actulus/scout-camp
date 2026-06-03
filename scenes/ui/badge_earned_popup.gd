extends CanvasLayer

const BADGE_DEFINITIONS = {
	"fire":       {"name": "The Fire Starter",   "emoji": "🔥", "color": Color("#FF6600")},
	"shelter":    {"name": "The Shelter Builder", "emoji": "🏕️", "color": Color("#8B4513")},
	"tent":       {"name": "The Tent Camper",     "emoji": "⛺",  "color": Color("#A0522D")},
	"water":      {"name": "The Water Guardian",  "emoji": "💧", "color": Color("#0088FF")},
	"plants":     {"name": "The Nature Reader",   "emoji": "🌿", "color": Color("#228B22")},
	"animals":    {"name": "The Animal Expert",   "emoji": "🦊", "color": Color("#CC4400")},
	"navigation": {"name": "The Pathfinder",      "emoji": "🧭", "color": Color("#FFD700")},
}

var _card: Control

func _ready() -> void:
	layer = 10

func show_badge(badge_id: String) -> void:
	var def: Dictionary = BADGE_DEFINITIONS.get(badge_id, {})
	if def.is_empty():
		queue_free()
		return
	_build_popup(def)
	_animate_in()
	get_tree().create_timer(3.5).timeout.connect(_dismiss)

func _build_popup(def: Dictionary) -> void:
	var font_body = UiFonts.body
	var font_bold = UiFonts.body_bold

	# Full-screen dim
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed: _dismiss())
	add_child(overlay)

	# Card
	var root_ctrl = Control.new()
	root_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_ctrl)

	_card = PanelContainer.new()
	_card.custom_minimum_size = Vector2(340, 340)
	_card.set_anchors_preset(Control.PRESET_CENTER)
	_card.offset_left   = -170.0
	_card.offset_top    = -170.0
	_card.offset_right  =  170.0
	_card.offset_bottom =  170.0
	_card.mouse_filter  = Control.MOUSE_FILTER_IGNORE

	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color("#1C2E1A")
	card_style.border_color = def.color
	card_style.set_border_width_all(3)
	card_style.set_corner_radius_all(16)
	card_style.content_margin_left   = 24
	card_style.content_margin_right  = 24
	card_style.content_margin_top    = 20
	card_style.content_margin_bottom = 20
	_card.add_theme_stylebox_override("panel", card_style)
	root_ctrl.add_child(_card)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(vbox)

	# "✨ Badge Earned! ✨"
	var heading = Label.new()
	heading.text = "✨  Badge Earned!  ✨"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_override("font", font_bold)
	heading.add_theme_font_size_override("font_size", 18)
	heading.add_theme_color_override("font_color", Color("#E8B84B"))
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(heading)

	# Badge circle
	var circle_center = CenterContainer.new()
	circle_center.custom_minimum_size = Vector2(0, 130)
	circle_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(circle_center)

	var circle = PanelContainer.new()
	circle.custom_minimum_size = Vector2(120, 120)
	circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var circle_style = StyleBoxFlat.new()
	circle_style.bg_color     = (def.color as Color).darkened(0.45)
	circle_style.border_color = (def.color as Color).lightened(0.3)
	circle_style.set_border_width_all(4)
	circle_style.set_corner_radius_all(60)
	circle_style.shadow_color = def.color
	circle_style.shadow_size  = 12
	circle.add_theme_stylebox_override("panel", circle_style)
	circle_center.add_child(circle)

	var emoji_lbl = Label.new()
	emoji_lbl.text = def.emoji
	emoji_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	emoji_lbl.add_theme_font_size_override("font_size", 52)
	emoji_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	emoji_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	circle.add_child(emoji_lbl)

	# Badge name
	var name_lbl = Label.new()
	name_lbl.text = def.name
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_lbl.add_theme_font_override("font", font_bold)
	name_lbl.add_theme_font_size_override("font_size", 17)
	name_lbl.add_theme_color_override("font_color", Color("#F5E6C8"))
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_lbl)

	# Dismiss hint
	var hint_lbl = Label.new()
	hint_lbl.text = "Click anywhere to dismiss"
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_lbl.add_theme_font_override("font", font_body)
	hint_lbl.add_theme_font_size_override("font_size", 12)
	hint_lbl.add_theme_color_override("font_color", Color("#B8A882"))
	hint_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(hint_lbl)

func _animate_in() -> void:
	_card.scale    = Vector2(0.6, 0.6)
	_card.modulate = Color(1, 1, 1, 0)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(_card, "scale",    Vector2(1.0, 1.0), 0.35)
	tween.parallel().tween_property(_card, "modulate", Color(1, 1, 1, 1), 0.25)

func _dismiss() -> void:
	if not is_instance_valid(self): return
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(_card, "scale",    Vector2(0.6, 0.6), 0.25)
	tween.parallel().tween_property(_card, "modulate", Color(1, 1, 1, 0), 0.2)
	tween.tween_callback(queue_free)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		_dismiss()
		get_viewport().set_input_as_handled()
