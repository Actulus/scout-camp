extends CanvasLayer


@onready var close_btn: Button = %CloseButton

var compass_label: Label

func _ready() -> void:
	add_to_group("map")
	
	close_btn.pressed.connect(func(): _close())
	visible = false
	compass_label = get_node_or_null("Panel/CompassLabel")

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
