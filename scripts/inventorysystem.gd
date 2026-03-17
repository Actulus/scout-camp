extends Node

var items: Array = []
var item_states: Dictionary = {}

signal item_added(item_name: String)

func add_item(item_name: String):
	items.append(item_name)
	emit_signal("item_added", item_name)
	print("Picked up: ", item_name)
	
func has_item(item_name: String) -> bool:
	return item_name in items
	
func remove_item(item_name: String):
	items.erase(item_name)
	
func set_item_state(item_name: String, state: String):
	item_states[item_name] = state
	
func get_item_state(item_name: String) -> String:
	return item_states.get(item_name, "")
