class_name BadgeInteraction
extends AbstractInteraction

var badge_ui_scene = preload("res://scenes/ui/badge_ui.tscn")
var badge_instance = null

func pre_interact() -> void:
	super()

func interact() -> void:
	super()
	if not can_interact: return
	if badge_instance: return
	badge_instance = badge_ui_scene.instantiate()
	badge_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(badge_instance)
	badge_instance.closed.connect(func():
		badge_instance = null)

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()

func use_item(_item_data: ItemData) -> bool:
	return false
