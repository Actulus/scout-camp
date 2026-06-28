class_name MugInteraction
extends AbstractInteraction

# what can be added to the mug and what it produces
# key: input item_name, value: output scene path
@export var recipes: Dictionary = {
	"coffee": "res://path/to/coffee_mug.tscn",
	"tea_leaves": "res://path/to/tea_mug.tscn"
}

# purification now happens in the pot, not the mug
@export var requires_tablet: Array[String] = []

# what happens when player drinks from mug
@export var drink_skill: String = ""  # e.g. "water", "morale_boost"

var contents_item_name: String = ""
var water_surface: MeshInstance3D

var contents_colors: Dictionary = {
	"boiled_water_mug": Color(0.0, 0.6, 1.0, 0.7),
	"coffee": Color(0.15, 0.08, 0.02, 0.95),
	"tea_leaves": Color(0.55, 0.35, 0.1, 0.85)
}

func _ready() -> void:
	super()
	water_surface = object_ref.get_node_or_null("WaterSurface")
	if water_surface: water_surface.visible = false

func pre_interact() -> void:
	super()

func interact() -> void:
	super()
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if not ic: return
	if contents_item_name != "":
		ic._show_interaction_text("Open inventory and use the mug to drink", 2.0)
	else:
		ic._show_interaction_text("Mug is empty", 1.5)

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()

func use_item(item_data: ItemData) -> bool:
	var ic = get_tree().get_first_node_in_group("interaction_controller")

	if contents_item_name != "":
		if ic: ic._show_interaction_text("Mug already has something in it!", 2.0)
		return false

	if not recipes.has(item_data.item_name):
		if ic: ic._show_interaction_text("Can't put that in a mug", 2.0)
		return false

	# check if tablet needed
	if item_data.item_name in requires_tablet:
		var player = get_tree().get_first_node_in_group("player")
		var inventory = player.get_node(
			"%InventoryController/CanvasLayer/InventoryUI") as InventoryController
		if not _inventory_has_item(inventory, "purification_tablet"):
			if ic: ic._show_interaction_text("You need a purification tablet!", 2.0)
			return false
		_remove_item_from_inventory(inventory, "purification_tablet")

	contents_item_name = item_data.item_name

	# show contents color
	if water_surface:
		water_surface.visible = true
		var mat = StandardMaterial3D.new()
		mat.albedo_color = contents_colors.get(item_data.item_name, Color(0.5,0.5,0.5,0.8))
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		water_surface.material_override = mat

	# give output item to inventory
	var output_path = recipes.get(item_data.item_name, "")
	if output_path != "":
		_give_item_to_inventory(load(output_path))

	if ic: ic._show_interaction_text("Ready to drink!", 2.0)
	return true

func drink() -> void:
	# called from inventory use_collectable when mug is double-clicked
	contents_item_name = ""
	if water_surface: water_surface.visible = false
	if drink_skill != "":
		GameManager.complete_skill(drink_skill)
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic: ic._show_interaction_text("Refreshing!", 2.0)

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
	var player = get_tree().get_first_node_in_group("player")
	print("player: ", player)
	if player:
		# print full path of inventory-related nodes
		_print_tree(player, 0)
	var instance = scene.instantiate()
	get_tree().current_scene.add_child(instance)
	for child in instance.get_children():
		if child is AbstractInteraction:
			#var player = get_tree().get_first_node_in_group("player")
			var inventory = player.get_node("%InventoryController/CanvasLayer/InventoryUI")
			inventory.pickup_item(child.item_data)
			break
	instance.queue_free()

func _print_tree(node: Node, depth: int) -> void:
	print(" ".repeat(depth * 2), node.name, " (", node.get_class(), ")")
	for child in node.get_children():
		_print_tree(child, depth + 1)
