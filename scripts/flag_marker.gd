extends StaticBody3D

@export var clue_text: String = "Walk north from the large rock."
@export var page_index = 1 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label3D.text = "Page " + str(page_index)

func interact(player: Node):
	var box = get_tree().root.get_node("World/DialogueBox")
	box.show_dialogue("Page " + str(page_index) + " found!", "Well done! Next clue: " + clue_text)
	GameManager.emit_signal("page_found", page_index)
	queue_free()
	
