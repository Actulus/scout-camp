extends CharacterBody3D

const SPEED = 5.0
const GRAVITY = -20.0

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
	# Read keyboard input 
	var input = Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_up", "move_down")
	
	# Move relative to fixed camera angle 
	if input.length() > 0: 
		input = input.normalized()
	velocity.x = input.x * SPEED
	velocity.z = input.z * SPEED 
	
	move_and_slide()
