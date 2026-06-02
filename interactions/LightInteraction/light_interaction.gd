class_name LightInteraction
extends AbstractInteraction

@export var light_on_text: String = "Turn off light"
@export var light_off_text: String = "Turn on light"

var light: OmniLight3D
var bulb: MeshInstance3D
var is_on: bool = false
var _cooldown: bool = false

func _ready() -> void:
	super()
	for child in object_ref.get_children():
		if child is OmniLight3D:
			light = child
		if child.name == "Bulb":
			bulb = child
	if light: light.visible = false
	if bulb: bulb.visible = false

func pre_interact() -> void:
	super()

func interact() -> void:
	super()
	if not can_interact: return
	if _cooldown: return
	_toggle_light()
	_cooldown = true
	get_tree().create_timer(0.5).timeout.connect(
		func(): _cooldown = false)

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()

func use_item(_item_data: ItemData) -> bool:
	return false

func _toggle_light() -> void:
	is_on = not is_on
	if light: light.visible = is_on
	if bulb: bulb.visible = is_on
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic._show_interaction_text(
			light_on_text if is_on else light_off_text, 1.5)
