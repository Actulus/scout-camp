class_name TentInteraction
extends AbstractInteraction

@export var required_poles: String = "tent_poles"
@export var required_canvas: String = "tent_canvas"

var poles_added: bool = false
var canvas_added: bool = false
var is_built: bool = false

var tent_frame: MeshInstance3D
var tent_canvas: MeshInstance3D
var placement_marker: MeshInstance3D

func _ready() -> void:
	super()
	# register tent position so scatterers avoid it
	var tent_spot = object_ref.get_parent()
	var pos = tent_spot.global_position
	# block a radius around the tent
	for i in 8:
		var angle = i * TAU / 8
		GameManager.scattered_positions.append(
			pos + Vector3(cos(angle) * 3.0, 0, sin(angle) * 3.0))
	GameManager.scattered_positions.append(pos)
	tent_frame = tent_spot.get_node_or_null("TentFrame")
	tent_canvas = tent_spot.get_node_or_null("TentCanvas")
	placement_marker = tent_spot.get_node_or_null("PlacementMarker")
	if tent_frame: tent_frame.visible = false
	if tent_canvas: tent_canvas.visible = false

func pre_interact() -> void:
	super()

func interact() -> void:
	super()
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if not ic: return
	if is_built:
		ic._show_interaction_text("Tent is already set up!", 2.0)
	elif not poles_added:
		ic._show_interaction_text("Equip tent poles to set up the frame", 2.0)
	else:
		ic._show_interaction_text("Now equip the canvas to finish the tent", 2.0)

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()

func use_item(item_data: ItemData) -> bool:
	print("use_item called: '", item_data.item_name, "'")
	print("poles_added: ", poles_added, " canvas_added: ", canvas_added)
	print("required_canvas: '", required_canvas, "'")
	var ic = get_tree().get_first_node_in_group("interaction_controller")

	# stage 1 — poles
	if item_data.item_name == required_poles and not poles_added:
		poles_added = true
		if tent_frame: tent_frame.visible = true
		if placement_marker: placement_marker.visible = true
		can_interact = true  # keep accepting more items
		if ic: ic._show_interaction_text("Frame up! Now find canvas to cover it", 2.0)
		return true

	# stage 2 — canvas
	if item_data.item_name == required_canvas and not canvas_added:
		if not poles_added:
			if ic: ic._show_interaction_text("Set up the frame first!", 2.0)
			return false
		canvas_added = true
		is_built = true
		can_interact = false
		if tent_canvas: tent_canvas.visible = true
		if placement_marker: placement_marker.visible = false
		if ic: ic._show_interaction_text("Tent built! You have shelter.", 3.0)
		GameManager.complete_skill("shelter")
		return true

	return false
