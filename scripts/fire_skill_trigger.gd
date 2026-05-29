extends StaticBody3D

@export var required_item: String = "stick"
@export var required_amount: int = 2

@onready var fire_particles = $"../FireParticles"
@onready var fire_light = $"../FireLight"

var is_lit: bool = false

# this gets called by your interaction system
# look at how door_interaction connects to the player
# and replicate the same connection here
func interact():
	if is_lit:
		return
	
	# check inventory - adjust this to match your inventory API
	var inventory = get_tree().get_first_node_in_group("inventory")
	if inventory and inventory.has_item(required_item, required_amount):
		inventory.remove_item(required_item, required_amount)
		_light_fire()

func _light_fire():
	is_lit = true
	fire_particles.emitting = true
	fire_light.visible = true
	# notify other systems that fire is lit
	get_tree().call_group("fire_listeners", "on_fire_lit")
