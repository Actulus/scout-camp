class_name PurifyInteraction
extends AbstractInteraction

@export var purified_water_scene: PackedScene = preload("res://interactions/CollectableInteraction/EquippableInteraction/Interactables/purified_water_mug.tscn")

func pre_interact() -> void:
	super()

func interact() -> void:
	super()
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic: ic._show_interaction_text("Use boiled water mug + tablet here to purify", 2.0)

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()

func use_item(item_data: ItemData) -> bool:
	var ic = get_tree().get_first_node_in_group("interaction_controller")

	if item_data.item_name == "boiled_water_mug":
		# check if player also has tablet in inventory
		var player = get_tree().get_first_node_in_group("player")
		var inventory = player.get_node("%InventoryController/CanvasLayer/InventoryUI") as InventoryController
		if not _inventory_has_item(inventory, "purification_tablet"):
			if ic: ic._show_interaction_text("You need a purification tablet!", 2.0)
			return false

		# remove tablet from inventory
		_remove_item_from_inventory(inventory, "purification_tablet")

		# give purified water mug
		_give_item_to_inventory(purified_water_scene)

		if ic: ic._show_interaction_text("Water purified! Now drink it.", 2.0)
		return true

	if item_data.item_name == "purification_tablet":
		if ic: ic._show_interaction_text("You need boiled water in a mug first!", 2.0)
		return false

	return false

func _inventory_has_item(inventory: InventoryController, item_name: String) -> bool:
	for slot in inventory.inventory_slots:
		if slot.slot_data and slot.slot_data.item_name == item_name:
			return true
	return false

func _remove_item_from_inventory(inventory: InventoryController, item_name: String) -> void:
	for slot in inventory.inventory_slots:
		if slot.slot_data and slot.slot_data.item_name == item_name:
			slot.fill_slot(null)
			return

func _give_item_to_inventory(scene: PackedScene) -> void:
	var instance = scene.instantiate()
	get_tree().current_scene.add_child(instance)
	for child in instance.get_children():
		if child is AbstractInteraction:
			var player = get_tree().get_first_node_in_group("player")
			var inventory = player.get_node("%InventoryController/CanvasLayer/InventoryUI")
			inventory.pickup_item(child.item_data)
			break
	instance.queue_free()
