extends CanvasLayer

@onready var _panel: Panel = $Control/Panel
@onready var _name_label: Label = $Control/Panel/Margin/VBox/NPCName
@onready var _text_label: RichTextLabel = $Control/Panel/Margin/VBox/DialogueText
@onready var _hint_label: Label = $Control/Panel/Margin/VBox/ContinueHint

var _lines: Array[String] = []
var _line_index: int = 0
var _close_callback: Callable

func _ready() -> void:
	add_to_group("dialogue_ui")
	_apply_style()
	hide()

func open(npc_name: String, lines: Array[String], on_close: Callable) -> void:
	_lines = lines
	_line_index = 0
	_close_callback = on_close
	_name_label.text = npc_name
	_show_line()
	show()

func _show_line() -> void:
	_text_label.text = _lines[_line_index]
	var is_last := _line_index >= _lines.size() - 1
	_hint_label.text = "[Enter]/[LMB] to close" if is_last else "[Enter]/[LMB] to continue"

func _input(event: InputEvent) -> void:
	if not visible:
		return
	var accepted: bool = (event.is_action_pressed("ui_accept") and not event.is_echo()) \
		or (event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed \
			and not event.is_echo())
	if accepted:
		get_viewport().set_input_as_handled()
		_advance()

func _advance() -> void:
	_line_index += 1
	if _line_index >= _lines.size():
		_close_dialogue()
	else:
		_show_line()

func _close_dialogue() -> void:
	hide()
	if _close_callback.is_valid():
		_close_callback.call()

func _apply_style() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#1C2E1A", 0.94)
	panel_style.border_color = Color("#C68B3A")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	_panel.add_theme_stylebox_override("panel", panel_style)

	var body_font: Font = UiFonts.body

	_name_label.add_theme_color_override("font_color", Color("#C68B3A"))
	_name_label.add_theme_font_size_override("font_size", 18)
	_name_label.add_theme_font_override("font", body_font)

	_text_label.add_theme_color_override("default_color", Color("#F5E6C8"))
	_text_label.add_theme_font_size_override("normal_font_size", 15)
	_text_label.add_theme_font_override("normal_font", body_font)

	_hint_label.add_theme_color_override("font_color", Color("#9BB89A"))
	_hint_label.add_theme_font_size_override("font_size", 12)
	_hint_label.add_theme_font_override("font", body_font)
