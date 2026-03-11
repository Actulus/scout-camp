extends StaticBody3D

@export var item_name: String = "branch"
@export var display_name: String = "A sturdy branch"
@export var tooltip: String = "Dry and strong - good for a frame."

func interact(player: Node):
    player.get_node("Inventory").add_item(item_name)
    queue_free()
