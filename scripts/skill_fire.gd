extends Node3D

var slots_filled = {"tinder": false, "kindling": false, "fuel": false}
var slot_items = {
	"tinder": "Dry tinder", "kindling": "kindling", "fuel": "fuel"
}
var steps_done=[]
var required_items = {
	"tinder": ["tinder"],
	"kindling": ["kindling"],
	"fuel": ["fuel"]
}


@onready var feedback = $FireUI/Control/Panel/StatusText
@onready var tinder_btn = $FireUI/Control/Panel/TinderSlotBtn
@onready var kindling_btn = $FireUI/Control/Panel/KindlingSlotBtn
@onready var fuel_btn = $FireUI/Control/Panel/FuelSlotBtn
var player_ref: Node

func _ready() -> void:
	print("SkillFire ready. player_ref: ", player_ref)
	tinder_btn.pressed.connect(func(): try_slot("tinder"))
	kindling_btn.pressed.connect(func(): try_slot("kindling"))
	fuel_btn.pressed.connect(func(): try_slot("fuel"))

func set_player(p: Node): 
	player_ref = p 
	print("player_ref set to: ", player_ref)
	
func try_slot(slot: String):
	var inv = player_ref.get_node("Inventory")
	var needed = slot_items[slot]
	if inv.has_item(needed):
		slots_filled[slot] = true 
		feedback.text = needed.replace("_"," ") + " placed correctly!"
		_check_complete()
	elif inv.has_item("wet_" + needed):
		feedback.text("Wet wood won't burn! Find dry " + needed + ".")
	else:
		feedback.text = "You don't have " + needed + " yet."
		
func _check_complete(): 
		if slots_filled.values().all(func(v): return v):
			GameManager.complete_skill("fire")
			feedback.text = "Fire lit! Well done!"
			await get_tree().create_timer(2.0).timeout
			queue_free()
