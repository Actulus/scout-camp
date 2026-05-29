class_name FireInteraction
extends AbstractInteraction

@export var required_item: String = "wood"
@export var required_amount: int = 3

var wood_meshes: Array = []
var wood_count: int = 0
var fire_particles: GPUParticles3D
var fire_light: OmniLight3D
var fire_pit: Node3D
var flames: Node3D

func _ready() -> void:
	super()
	# object_ref = StaticBody3D, parent = FirePit root
	fire_pit = object_ref.get_parent()
	flames = fire_pit.get_node_or_null("Flames")
	fire_particles = fire_pit.get_node_or_null("FireParticles")
	fire_light = fire_pit.get_node_or_null("FireLight")
	
	wood_meshes = [
		fire_pit.get_node_or_null("Wood1"),
		fire_pit.get_node_or_null("Wood2"),
		fire_pit.get_node_or_null("Wood3")
	]
	
func pre_interact() -> void:
	super()

func interact() -> void:
	super()
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic._show_interaction_text(
			"Equip wood and use it here (%d/%d)" % [wood_count, required_amount], 2.0)

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()

func use_item(item_data: ItemData) -> bool:
	if wood_count >= required_amount:
		var ic = get_tree().get_first_node_in_group("interaction_controller")
		if ic:
			ic._show_interaction_text("Fire is already lit!", 1.5)
		return false
	
	if item_data.item_name != required_item:
		return false
		
	print("use_item called with: '", item_data.item_name, "'")
	if item_data.item_name != required_item:
		return false

	if wood_count < wood_meshes.size() and wood_meshes[wood_count]:
		wood_meshes[wood_count].visible = true
		
	wood_count += 1
	print("Wood added: %d/%d" % [wood_count, required_amount])

	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic._show_interaction_text(
			"Wood added (%d/%d)" % [wood_count, required_amount], 1.5)

	if wood_count >= required_amount:
		_light_fire()

	return true

func _light_fire() -> void:
	can_interact = false
	wood_count = required_amount  # ensure guard above always triggers
	if fire_particles:
		fire_particles.emitting = true
	if fire_light:
		fire_light.visible = true
	if flames: flames.visible = true 
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic._show_interaction_text("Fire lit!", 3.0)
	print("Fire lit!")
