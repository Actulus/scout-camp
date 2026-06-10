class_name SinkInteraction
extends WaterInteraction

@onready var water_block: MeshInstance3D = get_node_or_null("../WaterBlock")
var tap_on: bool = false

func _ready() -> void:
	super()
	if water_block: water_block.visible = false

func pre_interact() -> void:
	super()

func interact() -> void:
	super()
	if not can_interact: return
	_toggle_tap()

func _toggle_tap() -> void:
	tap_on = not tap_on
	if water_block: water_block.visible = tap_on
	
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic._show_interaction_text(
			"Tap on — equip bucket to collect water" if tap_on else "Tap off", 2.0)

func use_item(item_data: ItemData) -> bool:
	if not tap_on:
		var ic = get_tree().get_first_node_in_group("interaction_controller")
		if ic: ic._show_interaction_text("Turn the tap on first!", 2.0)
		return false
	# tap is on — use parent WaterInteraction logic
	return super.use_item(item_data)

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()
