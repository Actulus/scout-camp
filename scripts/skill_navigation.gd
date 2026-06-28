extends Node3D

var papers_found = 0 
var player_ref: Node

# Called when the node enters the scene tree for the first time.
#func _ready():
	##if GameManager.current_day == 5:
		#GameManager.flag_found.connect(_on_flag_found)
		#var box = get_tree().root.get_node("World/DialogueBox")
		#box.show_dialogue("Kofi",
		#"I have hidden 3 flags. Find them using the compass! " + \
		#"First clue: Walk north-east from the camp firepit.")

func set_player(p: Node):
	player_ref = p 
	print("player_ref set to: ", player_ref)

func _on_flag_found(idx: int):
	papers_found += 1
	if papers_found >= 3: 
		GameManager.complete_skill("navigation")
		queue_free()
