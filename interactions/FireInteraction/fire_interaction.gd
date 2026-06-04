class_name FireInteraction
extends AbstractInteraction

@export var required_item: String = "wood"
@export var required_amount: int = 3
@export var boiled_water_scene: PackedScene = preload("res://interactions/CollectableInteraction/EquippableInteraction/Interactables/boiled_water_mug.tscn")
@export var ignite_sound: AudioStream

var wood_meshes: Array = []
var wood_count: int = 0
var fire_particles: GPUParticles3D
var fire_light: OmniLight3D
var fire_pit: Node3D
var flames: Node3D
var is_lit: bool = false 

func _ready() -> void:
	super()
	# object_ref = StaticBody3D, parent = FirePit root
	fire_pit = object_ref.get_parent()
	flames = fire_pit.get_node_or_null("Flames")
	fire_particles = fire_pit.get_node_or_null("FireParticles")
	fire_light = fire_pit.get_node_or_null("FireLight")
	
	wood_meshes = [
		fire_pit.get_node_or_null("Wood1"),
		fire_pit.get_node_or_null("Wood2"),
		fire_pit.get_node_or_null("Wood3")
	]
	
func pre_interact() -> void:
	super()

func interact() -> void:
	super()
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if not ic: return
	if is_lit:
		var pot = get_tree().get_first_node_in_group("cooking_pot")
		if pot:
			var pot_ic = _find_interaction_component(pot)
			if pot_ic is PotInteraction:
				match pot_ic.contents:
					"": ic._show_interaction_text("Pot on fire — equip dirty water bucket and use it on the pot.", 2.0)
					"dirty_water":
						if pot_ic.is_boiling:
							ic._show_interaction_text("Boiling! %ds remaining — look at pot." % pot_ic.boil_remaining, 2.0)
						else:
							ic._show_interaction_text("Pot has water on lit fire — boiling starting.", 2.0)
					"boiled_water": ic._show_interaction_text("Water boiled! Equip a mug and use it on the pot.", 2.0)
					"purified_water": ic._show_interaction_text("Water purified! Equip a mug and use it on the pot.", 2.0)
			else:
				ic._show_interaction_text("Fire burning! Look at the pot directly to interact.", 2.0)
		else:
			ic._show_interaction_text("Fire burning! Equip cooking pot and use it here to place it.", 2.0)
	else:
		ic._show_interaction_text("Equip wood and use it here (%d/%d)" % [wood_count, required_amount], 2.0)

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()

func use_item(item_data: ItemData) -> bool:
	print("FireInteraction.use_item: '", item_data.item_name, "'")
	var ic = get_tree().get_first_node_in_group("interaction_controller")

	# wood logic
	if item_data.item_name == required_item:
		if wood_count >= required_amount:
			if ic: ic._show_interaction_text("Fire is already lit!", 1.5)
			return false
		if wood_count < wood_meshes.size() and wood_meshes[wood_count]:
			wood_meshes[wood_count].visible = true
		wood_count += 1
		if ic: ic._show_interaction_text(
			"Wood added (%d/%d)" % [wood_count, required_amount], 1.5)
		if wood_count >= required_amount:
			_light_fire()
		return true

	# cooking pot placement — takes the actual equipped pot so any water already in it is preserved
	if item_data.item_name == "cooking_pot":
		if get_tree().get_first_node_in_group("cooking_pot"):
			if ic: ic._show_interaction_text("The pot is already on the fire!", 2.0)
			return false
		var ic_node = get_tree().get_first_node_in_group("interaction_controller")
		var pot_instance: Node3D = ic_node.equipped_item if ic_node else null
		if not pot_instance:
			if ic: ic._show_interaction_text("Something went wrong placing the pot.", 2.0)
			return false
		# detach from hand and place at fire
		ic_node.unequip_no_destroy()
		pot_instance.get_parent().remove_child(pot_instance)
		get_tree().current_scene.add_child(pot_instance)
		pot_instance.global_position = fire_pit.global_position + Vector3(0, 0.8, 0)
		if pot_instance is RigidBody3D:
			(pot_instance as RigidBody3D).freeze = true
		pot_instance.add_to_group("cooking_pot")
		if pot_instance is RigidBody3D:
			(pot_instance as RigidBody3D).freeze = true
		# Restore collision shapes and mesh layers disabled/changed during equip
		for child in pot_instance.get_children():
			if child is CollisionShape3D:
				child.disabled = false
			elif child is MeshInstance3D:
				child.layers = 1
		# start cooking if fire is already lit and pot has contents
		if GameManager.fire_lit:
			var pot_ic = _find_interaction_component(pot_instance)
			if pot_ic and pot_ic is PotInteraction:
				pot_ic.notify_fire_lit()
		for child in pot_instance.get_children():
			if child is EquippableInteraction:
				child.can_interact = false
				break
		if ic: ic._show_interaction_text("Pot placed on the fire!", 2.0)
		return true

	# delegate bucket_dirty_water, mug, and tablet to the pot on the fire
	if item_data.item_name in ["bucket_dirty_water", "mug", "purification_tablet"]:
		var pot = get_tree().get_first_node_in_group("cooking_pot")
		if pot:
			var pot_ic = _find_interaction_component(pot)
			if pot_ic and pot_ic is PotInteraction:
				return pot_ic.use_item(item_data)
		if ic: ic._show_interaction_text("Place the cooking pot on the fire first!", 2.0)
		return false

	return false

func _light_fire() -> void:
	is_lit = true
	GameManager.fire_lit = true
	GameManager.complete_skill("fire")
	#can_interact = false
	wood_count = required_amount  # ensure guard above always triggers
	if fire_particles:
		fire_particles.emitting = true
	if fire_light:
		fire_light.visible = true
	if flames: flames.visible = true 
	if ignite_sound:
		SoundManager.play_sfx(ignite_sound)
	
	# notify any pot already on the fire to start cooking if it has contents
	var pot = get_tree().get_first_node_in_group("cooking_pot")
	if pot:
		var pot_ic = _find_interaction_component(pot)
		if pot_ic and pot_ic is PotInteraction:
			pot_ic.notify_fire_lit()
			
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic._show_interaction_text("Fire lit!", 3.0)

func _start_boiling() -> void:
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic: ic._show_interaction_text("Boiling water... wait 3 seconds", 2.0)
	await get_tree().create_timer(3.0).timeout
	
	# add boiled water to inventory
	var boiled_instance = boiled_water_scene.instantiate()
	get_tree().current_scene.add_child(boiled_instance)
	var boiled_ic = _find_interaction_component(boiled_instance)
	if boiled_ic:
		var player = get_tree().get_first_node_in_group("player")
		var inventory = player.get_node("%InventoryController/CanvasLayer/InventoryUI")
		inventory.pickup_item(boiled_ic.item_data)
	boiled_instance.queue_free()
	
	if ic: ic._show_interaction_text("Water boiled! Now purify it", 2.0)

func _find_interaction_component(node: Node) -> AbstractInteraction:
	if node.has_method("get_interaction_component"):
		var ic = node.get_interaction_component()
		if ic:
			return ic
	for child in node.get_children():
		if child is AbstractInteraction:
			return child
	return null
