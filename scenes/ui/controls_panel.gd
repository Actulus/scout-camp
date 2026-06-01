extends PanelContainer

func _ready() -> void:
	var back = get_node_or_null("%BackButton")
	if back:
		back.grab_focus.call_deferred()
