class_name ToggleDoorInteraction
extends AbstractInteraction

@export var open_angle: float = 90.0
@export var open_speed: float = 3.0
@export var pivot_point: Node3D

var is_open: bool = false
var target_angle: float = 0.0
var current_angle: float = 0.0
var _already_toggled: bool = false

func _ready() -> void:
	super()
	lock_camera = false

func pre_interact() -> void:
	super()
	# pre_interact fires once on first press — toggle here
	if not _already_toggled:
		_already_toggled = true
		_toggle_door()

func interact() -> void:
	super()
	# interact fires every frame — do nothing here

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()
	# post_interact fires on release — reset flag
	_already_toggled = false

func use_item(_item_data: ItemData) -> bool:
	return false

func _toggle_door() -> void:
	is_open = not is_open
	target_angle = open_angle if is_open else 0.0
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic._show_interaction_text(
			"Door opened" if is_open else "Door closed", 1.0)

func _process(delta: float) -> void:
	if not pivot_point: return
	current_angle = lerp(current_angle, target_angle, delta * open_speed)
	pivot_point.rotation_degrees.y = current_angle
