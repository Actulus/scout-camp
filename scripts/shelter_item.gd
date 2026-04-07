extends CharacterBody3D

@onready var item = $MeshInstance3D
@onready var item_outline = $MeshInstance3D/MeshInstance3D

@export var item_name: String = "branch"
@export var display_name: String = "A sturdy branch"
@export var tooltip: String = "Dry and strong - good for a frame."

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var selected = false 
var outlineWidth = 0.05 
var player

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction") and selected:
		player.pick_up_object(self)

func _ready():
	player = get_tree().get_first_node_in_group("player")
	player.interact_object.connect(_set_selected)
	
	item_outline.visible = false 

func _process(delta):
	$CollisionShape3D.disabled = player == get_parent()
	item_outline.visible = selected and not player == get_parent() 
	
	if selected: item.position.y = outlineWidth 
	else: item.position.y = 0 

func _physics_process(delta: float) -> void:
	if player == get_parent(): return 
	
	if not is_on_floor(): 
		velocity.y -= gravity * delta 
		
		move_and_slide()

func interact(player: Node):
	player.get_node("Inventory").add_item(item_name)
	queue_free()

func _set_selected(object):
	selected = self == object 
