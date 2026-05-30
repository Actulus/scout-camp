extends Node3D

@onready var feedback = $WaterUI/Control/Panel/StatusText
var player_ref: Node

func set_player(p): player_ref = p 

func _ready():
	$WaterUI/Control/Panel/BoilBtn.pressed.connect(func(): _try_answer("boil"))
	$WaterUI/Control/Panel/SettleBtn.pressed.connect(func(): _try_answer("settle"))
	$WaterUI/Control/Panel/ClothBtn.pressed.connect(func(): _try_answer("cloth"))
	$WaterUI/Control/Panel/SugarBtn.pressed.connect(func(): _try_answer("sugar"))
	
func _try_answer(choice: String):
	match choice:
		"boil": 
			feedback.text = "Correct! Boiling kills all common waterborne pathogens."
			_do_boil() 
		"settle": 
			feedback.text = "Settling removes particles but not bacteria. Try again."
		"cloth":
			feedback.text = "Filtering helps,  but alone it is not enough to kill bacteria. Try again."
		"sugar":
			feedback.text = "Sugar does nothing to purify water. Try again."
			
func _do_boil():
	if not GameManager.skills_completed["fire"]:
		feedback.text = "You need a fire to boil water. Complete the fire skill first."
		return
	feedback.text = "Now collect, boil, and purify your water to complete the skill!"
	await get_tree().create_timer(2.5).timeout
	queue_free()
