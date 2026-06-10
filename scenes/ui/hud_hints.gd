extends CanvasLayer

@onready var hint_bar: VBoxContainer = %HintBar

# hint sets per context
const HINTS = {
	"default": [
		{"key": "T", "action": "Tasks"},
		{"key": "B", "action": "Badges"},
		{"key": "M", "action": "Map"},
		{"key": "Tab", "action": "Inventory"},
		{"key": "Esc", "action": "Pause"}
	],
	"near_object": [
		{"key": "E", "action": "Interact"},
		{"key": "T", "action": "Tasks"},
		{"key": "M", "action": "Map"},
		{"key": "Esc", "action": "Pause"}
	],
	"equipped": [
		{"key": "LClick", "action": "Use"},
		{"key": "RClick", "action": "Unequip"},
		{"key": "Esc", "action": "Pause"}
	],
	"reading": [
		{"key": "E", "action": "Next"},
		{"key": "Q", "action": "Previous"},
		{"key": "Esc", "action": "Close"}
	],
	"plant_quiz": [
		{"key": "E", "action": "Edible"},
		{"key": "P", "action": "Poisonous"},
		{"key": "←→", "action": "Navigate"},
		{"key": "Enter", "action": "Submit"},
		{"key": "Esc", "action": "Close"}
	],
	"animal_quiz": [
		{"key": "E", "action": "Safe"},
		{"key": "P", "action": "Dangerous"},
		{"key": "←→", "action": "Navigate"},
		{"key": "Enter", "action": "Submit"},
		{"key": "Esc", "action": "Close"}
	],
	"inventory": [
		{"key": "DblClick", "action": "Use / Equip"},
		{"key": "RClick", "action": "Drop"},
		{"key": "Drag", "action": "Move"},
		{"key": "Tab", "action": "Close"}
	]
}

# controller equivalents
const CONTROLLER_HINTS = {
	"default": [
		{"key": "X", "action": "Tasks"},
		{"key": "Y", "action": "Badges"},
		{"key": "↑", "action": "Map"},
		{"key": "LB", "action": "Inventory"},
		{"key": "Start", "action": "Pause"}
	],
	"near_object": [
		{"key": "A", "action": "Interact"},
		{"key": "X", "action": "Tasks"},
		{"key": "↑", "action": "Map"},
		{"key": "Start", "action": "Pause"}
	],
	"equipped": [
		{"key": "RT", "action": "Use"},
		{"key": "LT", "action": "Unequip"},
		{"key": "Start", "action": "Pause"}
	],
	"reading": [
		{"key": "A", "action": "Next"},
		{"key": "X", "action": "Previous"},
		{"key": "B", "action": "Close"}
	],
	"plant_quiz": [
		{"key": "DPad", "action": "Navigate"},
		{"key": "A", "action": "Confirm"},
		{"key": "B", "action": "Close"}
	],
	"animal_quiz": [
		{"key": "DPad", "action": "Navigate"},
		{"key": "A", "action": "Confirm"},
		{"key": "B", "action": "Close"}
	],
	"inventory": [
		{"key": "A", "action": "Use / Equip"},
		{"key": "B", "action": "Drop"},
		{"key": "LB", "action": "Close"}
	]
}

var current_context: String = "default"
var using_controller: bool = false
var font_body: FontFile

func _ready() -> void:
	add_to_group("hud_hints")
	font_body = UiFonts.body
	# Right-side vertical bar (Alba-style): anchored center-right, grows up/down
	hint_bar.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	hint_bar.offset_left = -210.0
	hint_bar.offset_right = -10.0
	hint_bar.offset_top = 0.0
	hint_bar.offset_bottom = 0.0
	_show_hints("default")

func _input(event: InputEvent) -> void:
	# detect input device
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if not using_controller:
			using_controller = true
			_show_hints(current_context)
	elif event is InputEventKey or event is InputEventMouseButton:
		if using_controller:
			using_controller = false
			_show_hints(current_context)

func set_context(context: String) -> void:
	if context == current_context: return
	current_context = context
	_show_hints(context)

func _show_hints(context: String) -> void:
	for child in hint_bar.get_children():
		child.queue_free()
	
	var hints = CONTROLLER_HINTS[context] if using_controller \
				else HINTS[context]
	
	for hint in hints:
		var container = HBoxContainer.new()
		container.add_theme_constant_override("separation", 4)
		
		# key badge
		var key_label = Label.new()
		key_label.text = hint.key
		key_label.add_theme_font_override("font", font_body)
		key_label.add_theme_font_size_override("font_size", 12)
		key_label.add_theme_color_override("font_color", Color("#1C2E1A"))
		
		var key_bg = StyleBoxFlat.new()
		key_bg.bg_color = Color("#E8B84B")
		key_bg.set_corner_radius_all(4)
		key_bg.content_margin_left = 6
		key_bg.content_margin_right = 6
		key_bg.content_margin_top = 2
		key_bg.content_margin_bottom = 2
		key_label.add_theme_stylebox_override("normal", key_bg)
		container.add_child(key_label)
		
		# action label
		var action_label = Label.new()
		action_label.text = hint.action
		action_label.add_theme_font_override("font", font_body)
		action_label.add_theme_font_size_override("font_size", 12)
		action_label.add_theme_color_override("font_color", Color("#F5E6C8"))
		container.add_child(action_label)
		
		hint_bar.add_child(container)
