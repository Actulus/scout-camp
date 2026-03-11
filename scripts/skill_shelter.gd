extends Node3D

var steps_done = []
var required_items = {
	"frame": ["branch", "large_branch", "tent_kit"],
	"insulation": ["moss", "dry_leaves"],
	"roof": ["large_branch", "dry_leaves"]
}

@onready var status = $ShelterUI/Control/Panel/StatusText

func try_place(slot: String, player: Node):
	var inv = player.get_node("Inventory")
	for needed in required_items[slot]:
		if inv.has_item(needed):
			steps_done.append(slot)
			status.text = slot + " placed!"
			_check_complete()
			return
	status.text = "You need " + required_items[slot][0] + " for this!"
	
func _check_complete():
	if "frame" in steps_done and "insulation" in steps_done and "roof" in steps_done:
		GameManager.complete_skill("shelter")
		status.text = "Shelter complete! Badge earned!"
		await get_tree().create_timer(2.0).timeout
		queue_free()
