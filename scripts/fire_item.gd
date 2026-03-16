extends StaticBody3D

@export var item_name: String = "tinder"
@export var is_wet: bool = false 

# Called when the node enters the scene tree for the first time.
func _ready():
	var mat = StandardMaterial3D.new()
	# Wet items look dark and slightl shiny 
	# Dry items look warm golden
	mat.albedo_color = Color("#3d2a1a") if is_wet else Color("#c8a050")
	$MeshInstance3D.material_override = mat 
	item_name = ("Wet " if is_wet else "Dry ") + item_name.replace("_", " ") 


func interact(player: Node):
	player.get_node("Inventory").add_item(item_name)
	queue_free()
