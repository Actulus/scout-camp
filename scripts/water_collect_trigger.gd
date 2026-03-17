extends Area3D


func interact(player: Node):
	var inv = player.get_node("Inventory")
	if inv.has_item("canteen"):
		inv.set_item_state("canteen", "unfiltered")
		var box = get_tree().root.get_node("World/DialogueBox")
		box.show_dialogue("Stream",
		"Canteen filled. The water looks clear, but is it safe to drink?"
		)
	else:
		var box = get_tree().root.get_node("World/DialogueBox")
		box.show_dialogue("Stream",
		"You need a canteen to collect water. Check the leader's house."
		)
