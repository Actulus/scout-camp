extends Node

const MAP_UI_SCENE: PackedScene = preload("res://scenes/ui/map_compass_ui.tscn")

var map_ui: CanvasLayer = null
var map_visible: bool = false

func _ready() -> void:
	map_ui = MAP_UI_SCENE.instantiate()
	get_tree().root.add_child.call_deferred(map_ui)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("map"):
		_toggle_map()

func _toggle_map() -> void:
	if not _has_item("map") or not _has_item("compass"):
		_show_text("You need a map and compass to navigate!", 2.0)
		return
	map_visible = not map_visible
	map_ui.visible = map_visible

func _has_item(item_name: String) -> bool:
	var inventory = _get_inventory()
	if not inventory:
		return false
	for slot in inventory.inventory_slots:
		if slot.slot_data and slot.slot_data.item_name == item_name:
			return true
	# also check equipped item via interaction_controller group
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic and ic.item_equipped and ic.equipped_item_interaction_component:
		if ic.equipped_item_interaction_component.item_data.item_name == item_name:
			return true
	return false

func _get_inventory() -> InventoryController:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return null
	return player.get_node_or_null("%InventoryController/CanvasLayer/InventoryUI")

func _show_text(text: String, duration: float) -> void:
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic._show_interaction_text(text, duration)

func _process(_delta: float) -> void:
	if map_visible and map_ui:
		_update_map()

func _update_map() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var camera = player.get_node_or_null("%Camera3D")
	if camera:
		map_ui.update_heading(camera.global_rotation_degrees.y)
