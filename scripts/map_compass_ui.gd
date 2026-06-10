extends CanvasLayer


@onready var close_btn: Button = %CloseButton

var compass_label: Label

func _ready() -> void:
	add_to_group("map")
	add_to_group("map_ui")

	close_btn.pressed.connect(func(): close_map())
	visible = false
	compass_label = get_node_or_null("Panel/CompassLabel")

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		close_map()
		get_viewport().set_input_as_handled()

func update_heading(y_rotation_degrees: float) -> void:
	if not compass_label:
		return
	var normalized = fmod(-y_rotation_degrees + 360.0, 360.0)
	var directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
	var index = int((normalized + 22.5) / 45.0) % 8
	compass_label.text = "You are facing: " + directions[index]

# Stubs kept so NavigationController calls don't error
func update_player_position(_world_pos: Vector3) -> void:
	pass

func update_found_pages(_count: int) -> void:
	pass

func close_map() -> void:
	visible = false
