extends Node3D

var target: Node3D
var follow_speed = 8.0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Detach from player so camera moves smoothly 
	top_level = true
	target = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target: 
		# Smoothly follow the player position 
		global_position = global_position.lerp(
			target.global_position, follow_speed * delta
		)
