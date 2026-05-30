extends Node

@onready var interaction_controller: Node = %InteractionController
@onready var interaction_raycast: RayCast3D = %InteractionRayCast3D
@onready var player_camera: Camera3D = %Camera3D
@onready var hand: Marker3D = %Hand 
@onready var note_hand: Marker3D = %NoteHand 
@onready var item_hand: Marker3D = %ItemHand
@onready var interactable_check: Area3D = $"../InteractableCheck"
@onready var note_overlay: Control = %NoteOverlay 
@onready var note_content: RichTextLabel = %NoteContent
@onready var inventory_controller: InventoryController = %InventoryController/CanvasLayer/InventoryUI
@onready var interaction_textbox: Label = %InteractionTextBox
@onready var outline_material: Material = preload("res://assets/materials/item_highlighter.tres")

@onready var default_reticle: TextureRect = %DefaultReticle
@onready var highlight_reticle: TextureRect = %HighlightReticle
@onready var interacting_reticle: TextureRect = %InteractingReticle
@onready var use_reticle: TextureRect = %UseReticle

enum Reticle {
	DEFAULT,
	HIGHLIGHT,
	INTERACTING,
	USE_ITEM
}

signal invent_on_item_collected(item)

var item_equipped: bool = false
var equipped_item: Node3D
var equipped_item_interaction_component: AbstractInteraction
var _item_swap_on_use: PackedScene = null

var current_object: Object 
var potential_interaction_component: AbstractInteraction
var potential_object: Object
var interaction_component: AbstractInteraction

var current_note: StaticBody3D
var note_interaction_component: InspectableInteraction 
var is_note_overlay_display: bool = false 

var interact_failure_player: AudioStreamPlayer
var interact_failure_sound_effect: AudioStreamWAV = load("res://assets/audio/fail_steel_drums_negative.wav")
var interact_success_player: AudioStreamPlayer
var interact_success_sound_effect: AudioStreamWAV = load("res://assets/audio/success_steel_drums_positive_long.wav")
var equip_item_player: AudioStreamPlayer
var equip_item_sound_effect: AudioStreamWAV = load("res://assets/audio/item_pickup_minifantasy.wav")
	
func _ready() -> void:
	add_to_group("interaction_controller")
	interactable_check.body_entered.connect(_collectable_item_entered_range)
	interactable_check.body_exited.connect(_collectable_item_exited_range)
	invent_on_item_collected.connect(inventory_controller.pickup_item)
	
	interact_failure_player = AudioStreamPlayer.new()
	interact_failure_player.volume_db = -25.0
	interact_failure_player.stream = interact_failure_sound_effect
	add_child(interact_failure_player)
	interact_success_player = AudioStreamPlayer.new()
	interact_success_player.volume_db = -10.0 
	interact_success_player.stream = interact_success_sound_effect
	add_child(interact_success_player)
	equip_item_player = AudioStreamPlayer.new()
	equip_item_player.volume_db = -20.0
	equip_item_player.stream = equip_item_sound_effect
	add_child(equip_item_player)

func _process(delta: float) -> void:
	if item_equipped:
		_update_reticle_state()
		# still update potential_object so use_item knows what to target
		potential_object = interaction_raycast.get_collider()
		if potential_object and potential_object is Node:
			if potential_object == equipped_item or potential_object.get_parent() == equipped_item:
				potential_object = null
				potential_interaction_component = null
			else:
				potential_interaction_component = find_interaction_component(potential_object)
				print("equipped mode - potential: ", potential_object.name if potential_object else "null")
				print("equipped mode - ic: ", potential_interaction_component)
		else:
			potential_interaction_component = null
		return  # skip all other interaction logic
	if inventory_controller.visible == false:
		# If on the previous frame, we were interacting with and object, lets keep interacting with it
		if current_object:
			if interaction_component:
				# Update reticle 
				if interaction_component.is_interacting:
					_update_reticle_state()
					
				# Limit interaction distance 
				if player_camera.global_transform.origin.distance_to(interaction_raycast.get_collision_point()) > 5.0:
					interaction_component.post_interact()
					current_object = null 
					_unfocus()
					return 
					
				# Perform Interactions 
				if Input.is_action_just_pressed("secondary"):
					interaction_component.aux_interact()
					current_object = null 
					_unfocus()
				elif Input.is_action_pressed("primary"):
					if not interaction_component is CollectableInteraction or not inventory_controller.inventory_full:
						interaction_component.interact()
					else: 
						if not interact_failure_player.playing:
							_show_interaction_text("Inventory Full...", 1.0)
							interact_failure_player.play() 
				else: 
					# to unfocus at items like doors
					interaction_component.post_interact()
					current_object = null
					_unfocus()
			else:
				# it's not interaction 
				current_object = null 
				_unfocus()
		else: # we weren't interacting with something, let's see if we can 
			potential_object = interaction_raycast.get_collider()
			
			if potential_object and potential_object is Node:
				potential_interaction_component = find_interaction_component(potential_object)
				if potential_interaction_component:
					if potential_interaction_component.can_interact == false:
						return
						
					_focus() 
					if Input.is_action_just_pressed("primary"):
						interaction_component = potential_interaction_component
						current_object = potential_object
						
						if interaction_component is TypeableInteraction: 
							interaction_component.set_target_button(current_object)
							
						interaction_component.pre_interact()
						
						if interaction_component is GrabbableInteraction:
							interaction_component.set_player_hand_position(hand)
							
						if interaction_component is ConsumableInteraction or interaction_component is EquippableInteraction:
							if not interaction_component.is_connected("item_collected", Callable(self, "_on_item_collected")):
								interaction_component.connect("item_collected", Callable(self, "_on_item_collected"))
								
						if interaction_component is InspectableInteraction:
							if not interaction_component.is_connected("note_inspected", Callable(self, "on_note_inspected")):
								interaction_component.connect("note_inspected", Callable(self, "on_note_inspected"))
								
						if interaction_component is DoorInteraction: 
							interaction_component.set_direction(current_object.to_local(interaction_raycast.get_collision_point()))
			else: # needed to show reticle 
				_unfocus()
	else: 
		_update_reticle_state()
		current_object = null 

func _input(event: InputEvent) -> void:
	if is_note_overlay_display and event.is_action_pressed("primary"):
		_on_note_collected()
		
	if item_equipped and Input.is_action_just_pressed("primary"):
		_use_equipped_item()
		
# Determines if the object the player is interacting with should stop mouse camera  movement 
func isCameraLocked() -> bool:
	if interaction_component:
		if interaction_component.lock_camera and interaction_component.is_interacting:
			return true 
	return false 
	
# Called when the player is looking at an interactable object
func _focus() -> void: 
	_update_reticle_state()
	
# Called when the player is NOT looking at an interactable object 
func _unfocus() -> void: 
	_update_reticle_state()
	
# Displays the picked up note in the player's hand
func on_note_inspected(note: Node3D):
	# If the player is holding the note and they go to pickup another one, collect the currently held note first 
	if current_note != null: 
		_on_note_collected()
		
	# Set the note the player is currently holding 
	current_note = note 
	# Cache the interaction component for this note 
	note_interaction_component = find_interaction_component(current_note) as InspectableInteraction
	_play_sound_effect(note_interaction_component.collect_sound_effect)
	# Reparent Note to the player hand 
	if current_note.get_parent() != null: 
		current_note.get_parent().remove_child(current_note)
	note_hand.add_child(current_note)
	
	# Change rendering layer for the note mesh so it doesn't clip into walls 
	_change_mesh_layer(note_interaction_component.meshes, 2)
	
	# Remove collision shapes so the note doesn't push on player or other physics objects 
	_remove_collision_shapes(note_interaction_component.collision_shapes)
	
	# Set the note's transform/rotation so it faces the player in the hand 
	current_note.transform.origin = note_hand.transform.origin
	current_note.position = Vector3(0.0,0.0,0.0)
	current_note.rotation_degrees = Vector3(90,10,0)
	
	# Show the note overlay as well as the note text 
	note_overlay.visible = true 
	is_note_overlay_display = true 
	note_content.bbcode_enabled = true 
	note_content.text = note_interaction_component.content

# Puts the note currently in the player's hand and puts it in their inventory
func _on_note_collected() -> void:
	# Hide the note overlay and mark that no note is being inspected
	note_overlay.visible = false
	is_note_overlay_display = false

	# Track special collectible notes
	if note_interaction_component.item_data:
		match note_interaction_component.item_data.item_name:
			"plant_field_guide":
				GameManager.plant_guide_read = true
				_show_interaction_text("Plant guide read! You can now attempt the plant skill.", 3.0)
			"book_page_1", "book_page_2", "book_page_3":
				if not GameManager.skills_completed["navigation"]:
					GameManager.pages_found += 1
					_show_interaction_text("Page found! (%d/3)" % GameManager.pages_found, 2.0)
					if GameManager.pages_found >= 3:
						GameManager.complete_skill("navigation")

	# Add the note's ItemData to the player's inventory
	_add_item_to_inventory(note_interaction_component.item_data)

	# Play the sound effect for putting the note away
	_play_sound_effect(note_interaction_component.put_away_sound_effect)

	# Remove the note from the world
	current_note.queue_free()

	# Clear references to the current note
	current_note = null
	note_interaction_component = null
		
# Called when the player collects an item
func _on_item_collected(item: Node3D) -> void:
	var ic: CollectableInteraction = find_interaction_component(item)
	if not ic:
		return
	
	# Add the item data to the inventory
	_add_item_to_inventory(ic.item_data)
	# Play the item's pickup sound effect
	_play_sound_effect(ic.collect_sound_effect)
	# Delete the item from the world since it exists in the inventory
	item.queue_free()
	
# Equips an object in the players hannd
func on_item_equipped(item: Node3D):
	# Set the equipped item and update flag
	equipped_item = item
	item_equipped = true
	
	if item is CollisionObject3D:
		interaction_raycast.add_exception(item)
	
	# Cache the interaction component for this item
	equipped_item_interaction_component = find_interaction_component(equipped_item)
	
	# Rigid bodies behave strangely when equipped.
	if item is RigidBody3D:
		item.freeze = true
		item.linear_velocity = Vector3.ZERO
		item.angular_velocity = Vector3.ZERO
		item.gravity_scale = 0.0
		
	# Reparent Note to the Hand
	if item.get_parent() != null:
		item.get_parent().remove_child(item)
	item_hand.add_child(item)
		
	# Change rendering layer for the note mesh so it doesnt clip into walls
	_change_mesh_layer(equipped_item_interaction_component.meshes, 2)
	
	# Remove collision shapes so the note doesnt push on player or other physics objects
	_remove_collision_shapes(equipped_item_interaction_component.collision_shapes)
	
	# Set the items's transform/rotation
	item.transform.origin = item_hand.transform.origin
	item.position = Vector3(0.0,0.0,0.0)
	var equippable = find_interaction_component(item) as EquippableInteraction
	if equippable:
		item.rotation_degrees = equippable.hand_rotation
		item.position = equippable.hand_position
	else:
		item.rotation_degrees = Vector3(0, 180, -90)
	
	# Play sound effect
	equip_item_player.play()
	
# Called by interactions that want to replace the equipped item with a different one on success.
func swap_equipped_item_after_use(new_scene: PackedScene) -> void:
	_item_swap_on_use = new_scene

# Called by interactions that physically place the equipped item in the world themselves
# (e.g. cooking pot placed on fire). Clears IC state without returning item to inventory
# or destroying it.
func unequip_no_destroy() -> void:
	if equipped_item is CollisionObject3D:
		interaction_raycast.remove_exception(equipped_item)
	equipped_item = null
	equipped_item_interaction_component = null
	item_equipped = false

func _use_equipped_item() -> void:
	_item_swap_on_use = null
	if potential_object:
		if potential_interaction_component != null and potential_interaction_component.has_method("use_item") and potential_interaction_component.use_item(equipped_item_interaction_component.item_data):
			# swap: use_item scheduled a replacement item (e.g. empty bucket → dirty water bucket)
			if _item_swap_on_use != null:
				var swap_scene = _item_swap_on_use
				_item_swap_on_use = null
				if equipped_item is CollisionObject3D:
					interaction_raycast.remove_exception(equipped_item)
				equipped_item.queue_free()
				equipped_item = null
				var new_item = swap_scene.instantiate()
				get_tree().current_scene.add_child(new_item)
				on_item_equipped(new_item)
				interact_success_player.play()
				return
			# use_item already handled the equipped item (e.g. pot placed on fire via unequip_no_destroy)
			if not item_equipped:
				interact_success_player.play()
				return
			# normal success: destroy if one-time-use
			if equipped_item_interaction_component.item_data.action_data.one_time_use:
				if equipped_item is CollisionObject3D:
					interaction_raycast.remove_exception(equipped_item)
				equipped_item.queue_free()
				equipped_item = null
				item_equipped = false
			_show_interaction_text(equipped_item_interaction_component.item_data.action_data.success_text, 1.0)
			interact_success_player.play()
			return
		else:
			_show_interaction_text("Nothing interesting happens...", 1.0)
	else:
		_show_interaction_text("Nothing to be used on...", 1.0)

	interact_failure_player.play()
	inventory_controller.pickup_item(equipped_item_interaction_component.item_data)
	if equipped_item is CollisionObject3D:
		interaction_raycast.remove_exception(equipped_item)
	equipped_item.queue_free()
	equipped_item = null
	item_equipped = false
	current_object = null
	potential_interaction_component = null
	
	
# Adds the given item data to the first open inventory slot
func _add_item_to_inventory(item_data: ItemData):
	if item_data != null:
		invent_on_item_collected.emit(item_data)
		return
				
	print("Item not found")

# Called when a collectable item is within range of the player
func _collectable_item_entered_range(body: Node3D) -> void:
	if body.name != "Player":
		var ic: AbstractInteraction = find_interaction_component(body)
		if ic and ic is ConsumableInteraction or ic is EquippableInteraction:
			var mesh: MeshInstance3D = body.find_child("MeshInstance3D", true, false)
			if mesh:
				mesh.material_overlay = outline_material

## Called when a collectable item is NO LONGER within range of the player
func _collectable_item_exited_range(body: Node3D) -> void:
	if body.name != "Player":
		var ic: AbstractInteraction = find_interaction_component(body)
		if ic and ic is ConsumableInteraction or ic is EquippableInteraction:
			var mesh: MeshInstance3D = body.find_child("MeshInstance3D", true, false)
			if mesh:
				mesh.material_overlay = null
			
## Recursively searches a node to find its InteractionComponent node. Returns null if there is none.
func find_interaction_component(node: Node) -> AbstractInteraction:
	while node:
		if node.has_method("get_interaction_component"):
			var ic = node.get_interaction_component()
			if ic:
				return ic
		for child in node.get_children():
			if child is AbstractInteraction:
				return child
		node = node.get_parent()
	return null

# Shows the provided text to a textbox in the middle of the screen for a given amount of time
func _show_interaction_text(text: String, duration: float) -> void:
	interaction_textbox.text = text
	interaction_textbox.visible = true
	await get_tree().create_timer(duration).timeout
	interaction_textbox.visible = false
	
# Plays a provided sound effect
func _play_sound_effect(sound_effect: AudioStream) -> void:
	if not sound_effect:
		return

	# Create the audio player and assign its sound effect
	var audio_player := AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.stream = sound_effect

	# Ensure the audio player is queue-free when its done playing
	audio_player.finished.connect(audio_player.queue_free)
	audio_player.play()
	
# Sets every mesh layer in the provided array to the provided layer
func _change_mesh_layer(meshes: Array[MeshInstance3D], layer: int) -> void:
	for mesh in meshes:
		mesh.layers = layer
		
# Deletes all the collision shapes from the provided array
func _remove_collision_shapes(collision_shapes: Array[CollisionShape3D]) -> void:
	for collision_shape in collision_shapes:
		collision_shape.disabled = true

func _update_reticle_state() -> void:
	# Hide all reticles by default
	default_reticle.visible = false
	highlight_reticle.visible = false
	interacting_reticle.visible = false
	use_reticle.visible = false

	# No reticle is show if the player has the inventory open
	if inventory_controller.visible:
		return

	# If an item is equipped, show the possible use icon
	if item_equipped:
		use_reticle.visible = true
		return

	# If we have a current object and are currently interacting with an object show the interaction reticle
	# If not interacting, show the highlight reticle to indicate possible interaction
	# If not interacting AND can't interact, show default reticle
	if current_object and interaction_component:
		if interaction_component.is_interacting:
			interacting_reticle.visible = true
			return
		elif interaction_component.can_interact:
			highlight_reticle.visible = true
			return
		else:
			default_reticle.visible = true
			return

	# If we have a potential object to interaction with, show the highlight reticle
	if potential_object:
		if potential_interaction_component and potential_interaction_component.can_interact:
			highlight_reticle.visible = true
			return

	# Fallback: default reticle
	default_reticle.visible = true
