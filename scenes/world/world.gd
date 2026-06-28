extends Node3D

var welcome_popup_scene = preload("res://scenes/ui/welcome_popup.tscn")

func _ready() -> void:
	if GameManager.skills_completed.get("tent", false):
		var tent_canvas = get_node_or_null("TentCanvas")
		var tent_poles  = get_node_or_null("TentPoles")
		if tent_canvas: tent_canvas.queue_free()
		if tent_poles:  tent_poles.queue_free()

	if GameManager.is_new_game:
		GameManager.is_new_game = false
		await get_tree().process_frame
		await get_tree().process_frame
		var popup = welcome_popup_scene.instantiate()
		popup.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().root.add_child(popup)
