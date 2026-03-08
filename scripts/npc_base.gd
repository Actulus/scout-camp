extends CharacterBody3D

@export var npc_name: String = "Scout"
@export var dialogue_lines: Array = ["Hello!", "Nice day for scouting."]

var current_line: int = 0
var player_nearby: bool = false 

func _ready():
	$TalkZone.body_entered.connect(_on_player_enter)
	$TalkZone.body_exited.connect(_on_player_exit)
	$NameLabel.text = npc_name
	
func _on_player_enter(body):
	if body.name == "Player":
		player_nearby = true
		
func _on_player_exit(body):
	if body.name == "Player":
		player_nearby = false
		
func interact(player: Node):
	print(npc_name, ": ", dialogue_lines[current_line])
	current_line = (current_line + 1) % dialogue_lines.size()
