extends StaticBody3D

@export var item_name: String = "item"
@export var display_name: String = "An item"

func interact(player: Node):
	var inventory = player.get_node("Inventory")
	inventory.add_item(item_name)
	queue_free() # Remove from world after pickup
