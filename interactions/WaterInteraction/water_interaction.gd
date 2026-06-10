class_name WaterInteraction
extends AbstractInteraction

@export var required_item: String = "bucket"
@export var dirty_water_scene: PackedScene

func pre_interact() -> void:
	super()

# Called when player has NO item equipped and presses primary at the water source.
# Fills the bucket directly from inventory so the player doesn't have to equip it.
func interact() -> void:
	super()
	var ic_node = get_tree().get_first_node_in_group("interaction_controller")
	if not ic_node or dirty_water_scene == null:
		return
	var inventory = ic_node.inventory_controller
	for slot in inventory.inventory_slots:
		if slot.slot_data and slot.slot_data.item_name == required_item:
			slot.fill_slot(null)
			inventory.inventory_full = false
			_give_item_to_inventory(dirty_water_scene)
			ic_node._show_interaction_text("Bucket filled with water!", 2.0)
			return
	ic_node._show_interaction_text("You need a bucket to collect water", 2.0)

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()

# Called when the player has the bucket EQUIPPED and uses it on the water source.
# Swaps the equipped empty bucket for the dirty water bucket in-hand.
func use_item(item_data: ItemData) -> bool:
	print("WaterInteraction.use_item: '", item_data.item_name, "'")
	var ic_node = get_tree().get_first_node_in_group("interaction_controller")
	if item_data.item_name != required_item:
		if ic_node: ic_node._show_interaction_text("You need an empty bucket to collect water", 2.0)
		return false

	if dirty_water_scene == null:
		push_error("WaterInteraction: dirty_water_scene not assigned in Inspector")
		return false
		
	if ic_node:
		ic_node.swap_equipped_item_after_use(dirty_water_scene)
		ic_node._show_interaction_text("Bucket filled with water!", 2.0)
	return true

func _give_item_to_inventory(scene: PackedScene) -> void:
	var instance = scene.instantiate()
	get_tree().current_scene.add_child(instance)
	for child in instance.get_children():
		if child is CollectableInteraction and child.item_data:
			child.item_data.item_model_prefab = scene
			var ic_node = get_tree().get_first_node_in_group("interaction_controller")
			if ic_node:
				ic_node.inventory_controller.pickup_item(child.item_data)
			break
	instance.queue_free()
