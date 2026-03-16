extends CharacterBody3D

@export var npc_name: String = "Scout"
@export var dialogue_lines: Array = ["Hello!", "Nice day for scouting."]
@export var patrol_path: NodePath

var current_line: int = 0
var player_nearby: bool = false 
var path_follow: PathFollow3D
var patrol_speed = 1.5
const GRAVITY = -20.0

func _ready():
	print("patrol_path value: ", patrol_path)
	print("path_follow found: ", path_follow)
	$TalkZone.body_entered.connect(_on_player_enter)
	$TalkZone.body_exited.connect(_on_player_exit)
	$NameLabel.text = npc_name
	if patrol_path:
		path_follow = get_node(patrol_path).get_child(0)
	
func _on_player_enter(body):
	if body.name == "Player":
		player_nearby = true
		
func _on_player_exit(body):
	if body.name == "Player":
		player_nearby = false
		
func interact(player: Node):
	var dialogue_box = get_tree().get_root().get_node("World/DialogueBox")
	dialogue_box.show_dialogue(npc_name, dialogue_lines[current_line])
	current_line = (current_line + 1) % dialogue_lines.size()

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Follow patrol path when player is not nearby
	if path_follow and not player_nearby:
		path_follow.progress += patrol_speed * delta

		# Only move on X and Z — let gravity handle Y
		var target = path_follow.global_position
		var direction = (target - global_position)
		direction.y = 0  # ignore vertical difference
		
		if direction.length() > 0.1:
			velocity.x = direction.normalized().x * patrol_speed
			velocity.z = direction.normalized().z * patrol_speed
		else:
			velocity.x = 0
			velocity.z = 0
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()
