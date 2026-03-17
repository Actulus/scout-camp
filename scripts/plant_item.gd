extends StaticBody3D

@export var plant_data: PlantData

# Called when the node enters the scene tree for the first time.
func _ready():
	if plant_data:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color("#c8a505") if plant_data.is_safe else Color("#8b0000")
		$MeshInstance3D.material_override = mat 

func interact(player: Node):
	var box = get_tree().root.get_node("World/DialogueBox")
	box.show_dialogue(plant_data.display_name, plant_data.visual_clue + "\n\n" + plant_data.real_world_fact)
