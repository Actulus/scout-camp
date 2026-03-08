extends Node

var items: Array = []

signal item_added(item_name: String)

func add_item(item_name: String):
	items.append(item_name)
	emit_signal("item_added", item_name)
	print("Picked up: ", item_name)
	
func has_item(item_name: String) -> bool:
	return item_name in items
	
func remove_item(item_name: String):
	items.erase(item_name)
