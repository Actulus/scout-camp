extends Node3D

var steps_done = []
var required_items = {
	"frame": ["branch", "large_branch", "tent_kit"],
	"insulation": ["moss", "dry_leaves"],
	"roof": ["large_branch", "dry_leaves"]
}

var player_ref: Node

@onready var status = $ShelterUI/Control/Panel/StatusText
@onready var frame_btn = $ShelterUI/Control/Panel/AddFrameBtn
@onready var insulation_btn = $ShelterUI/Control/Panel/AddInsulationBtn
@onready var roof_btn = $ShelterUI/Control/Panel/AddRoofBtn

func _ready():
	print("SkillShelter ready. player_ref: ", player_ref)
	frame_btn.pressed.connect(func(): try_place("frame"))
	insulation_btn.pressed.connect(func(): try_place("insulation"))
	roof_btn.pressed.connect(func(): try_place("roof"))
	
func set_player(p: Node):
	player_ref = p 
	print("player_ref set to: ", player_ref)

func try_place(slot: String):
	print("try_place called: ", slot)
	if player_ref == null:
		print("ERROR: player_ref is null")
		status.text = "Error: no player reference."
		return
	var inv = player_ref.get_node("Inventory")
	for needed in required_items[slot]:
		if inv.has_item(needed):
			if slot in steps_done:
				status.text = slot + " is already placed!"
				return
			steps_done.append(slot)
			status.text = slot.capitalize() + " placed! Good work."
			_check_complete()
			return
	status.text = "You need " + required_items[slot][0].replace("_", " ") + " for this."
	
func _check_complete():
	if "frame" in steps_done and "insulation" in steps_done and "roof" in steps_done:
		status.text = "Shelter complete! Badge earned!"
		GameManager.complete_skill("shelter")
		await get_tree().create_timer(2.0).timeout
		queue_free()
