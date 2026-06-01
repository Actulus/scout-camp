extends Node

func _ready() -> void:
	# connect to all buttons dynamically
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node is Button and not node.flat:
		node.mouse_entered.connect(func(): _animate_button(node, 1.05))
		node.mouse_exited.connect(func(): _animate_button(node, 1.0))

func _animate_button(btn: Button, scale: float) -> void:
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(scale, scale), 0.1)\
		.set_ease(Tween.EASE_OUT)
	btn.pivot_offset = btn.size / 2
