extends CharacterBody3D

signal interact_object

@onready var ray_cast_camera_3d = $Camera3D/RayCast3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5 
const CAMERA_SENS = 0.003
const GRAVITY = -20.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var pickedObject 
var collider


func _ready():
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event.is_action_pressed("quit"): get_tree().quit()
	
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * CAMERA_SENS
		rotation.x -= event.relative.y * CAMERA_SENS
		
	if event.is_action_pressed("interaction") and pickedObject:
		pickedObject.reparent(get_tree().current_scene)
		pickedObject = null
	
func _process(delta):
	if ray_cast_camera_3d.is_colliding():
		collider = ray_cast_camera_3d.get_collider()
		interact_object.emit(collider)
	else:
		interact_object.emit(null)
		

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Read keyboard input 
	#var input = Vector3.ZERO
	#input.x = Input.get_axis("move_left", "move_right")
	#input.z = Input.get_axis("move_up", "move_down")s
	#
	## Move relative to fixed camera angle 
	#if input.length() > 0: 
		#input = input.normalized()
	#velocity.x = input.x * SPEED
	#velocity.z = input.z * SPEED 
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func pick_up_object(object):
	object.reparent(self)
	object.global_position = %CarryObjectMarker.global_position
	
	await get_tree().create_timer(0.1).timeout
	pickedObject = object
