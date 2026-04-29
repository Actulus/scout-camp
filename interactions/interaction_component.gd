extends Node

# this is defined on individual objects in the game 

enum InteractionType {
	DEFAULT,
	DOOR,
	
}

@export var object_ref: Node3D
@export var interaction_type: InteractionType = InteractionType.DEFAULT 
@export var pivot_point: Node3D
@export var maximum_rotation: float = 90 

var can_interact: bool = true 
var is_interacting: bool = false 
var lock_camera: bool = false 
var starting_rotation: float 
var is_front: bool

var player_hand: Marker3D

func _ready() -> void:
	match interaction_type:
		InteractionType.DOOR:
			starting_rotation = pivot_point.rotation.x 
			maximum_rotation = deg_to_rad(rad_to_deg(starting_rotation)+maximum_rotation)
	
# run once, when the player first clicks on an object to interact with 
func preInteract() -> void: 
	is_interacting = true
	match interaction_type:
		InteractionType.DEFAULT:
			player_hand = get_tree().get_root().find_child("Hand", true, false)
		InteractionType.DOOR:
			lock_camera = true 
	
# run every frame, perform some logic on this object 
func interact() -> void:
	if not can_interact:
		return
		
	match interaction_type:
		InteractionType.DEFAULT:
			_default_interact()
	
func auxInteract() -> void: 
	if not can_interact:
		return
		
	match interaction_type:
		InteractionType.DEFAULT:
			_default_throw()
			
# run once, when the player last interacts with an object 
func postInteract() -> void: 
	is_interacting = false 
	lock_camera = false 
	
func _input(event: InputEvent) -> void:
	if is_interacting:
		match interaction_type:
			InteractionType.DOOR:
				if event is InputEventMouseMotion:
					if is_front: 
						pivot_point.rotate_y(-event.relative.y * .001)
					else:
						pivot_point.rotate_y(event.relative.y * .001)
						
					pivot_point.rotation.y = clamp(pivot_point.rotation.y, starting_rotation, maximum_rotation)

func _default_interact() -> void: 
	var object_current_position: Vector3 = object_ref.global_transform.origin
	var player_hand_position: Vector3 = player_hand.global_transform.origin 
	var object_distance: Vector3 = player_hand_position - object_current_position 
	const catch_speed = 5.0
	
	var rigid_body_3d: RigidBody3D = object_ref as RigidBody3D 
	if rigid_body_3d and rigid_body_3d.mass > 0.0: 
		rigid_body_3d.set_linear_velocity((object_distance) * (catch_speed/rigid_body_3d.mass)) 

func _default_throw() -> void: 
	var object_current_position: Vector3 = object_ref.global_transform.origin
	var player_hand_position: Vector3 = player_hand.global_transform.origin 
	var object_distance: Vector3 = player_hand_position - object_current_position 
	const throw_speed = 20.0
	
	var rigid_body_3d: RigidBody3D = object_ref as RigidBody3D 
	if rigid_body_3d and rigid_body_3d.mass > 0.0: 
		var throw_direction: Vector3 = -player_hand.global_transform.basis.z.normalized()
		var throw_strength: float = (throw_speed/rigid_body_3d.mass) 
		rigid_body_3d.set_linear_velocity(throw_direction*throw_strength)
		
		can_interact = false 
		await get_tree().create_timer(2.0).timeout # otherwise you can't pick up the item again 
		can_interact = true 

func set_direction(_normal: Vector3) -> void: 
	if _normal.z > 0: 
		is_front = true 
	else: 
		is_front = false
	
