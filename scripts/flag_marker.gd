extends StaticBody3D

@export var clue_text: String = "Walk north from the large rock."
@export var flag_index = 1 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label3D.text = "Flag " + str(flag_index)

func interact(player: Node):
	var box = get_tree().root.get_node("World/DialogueBox")
	box.show_dialogue("Flag " + str(flag_index) + " found!", "Well done! Next clue: " + clue_text)
	GameManager.emit_signal("flag_found", flag_index)
	queue_free()
	
