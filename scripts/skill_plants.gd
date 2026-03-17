extends Node3D

var player_answers: Dictionary = {}
var correct_answers = {
	"chanterelle": true,
	"death_cap": false,
	"fly_agaric": false,
	"blueberry": true,
	"elderberry": true,
	"nightshade": false
}

var player_ref: Node

@onready var feedback = $PlantUI/Control/MainPanel/StatusText
@onready var submit_btn = $PlantUI/Control/MainPanel/SubmitBtn

func _ready():
	# Safe column buttons
	$PlantUI/Control/MainPanel/ColumnsContainer/SafeColumn/ChanterelleBtn.pressed.connect(
		func(): _categorise("chanterelle", true))
	$PlantUI/Control/MainPanel/ColumnsContainer/SafeColumn/BlueberryBtn.pressed.connect(
		func(): _categorise("blueberry", true))
	$PlantUI/Control/MainPanel/ColumnsContainer/SafeColumn/ElderberryBtn.pressed.connect(
		func(): _categorise("elderberry", true))

	# Danger column buttons
	$PlantUI/Control/MainPanel/ColumnsContainer/DangerColumn/DeathCapBtn.pressed.connect(
		func(): _categorise("death_cap", false))
	$PlantUI/Control/MainPanel/ColumnsContainer/DangerColumn/FlyAgaricBtn.pressed.connect(
		func(): _categorise("fly_agaric", false))
	$PlantUI/Control/MainPanel/ColumnsContainer/DangerColumn/NightshadeBtn.pressed.connect(
		func(): _categorise("nightshade", false))

	submit_btn.pressed.connect(_submit)

func set_player(p: Node):
	player_ref = p 
	print("player_ref set to: ", player_ref)

func _categorise(plant_id: String, is_safe: bool):
	player_answers[plant_id] = is_safe
	feedback.text = plant_id.replace("_", " ").capitalize() + " categorized."

func _submit():
	if player_answers.size() < 6:
		feedback.text = "Categorize all plants before submit!"
		return
	var all_correct = true
	for plant_id in correct_answers:
		if player_answers.get(plant_id) != correct_answers[plant_id]:
			all_correct = false
			break
	if all_correct:
		feedback.text = "Correct! All plants categorized correctly."
		GameManager.complete_skill("plants")
		await get_tree().create_timer(2.0).timeout
		queue_free()
	else:
		feedback.text = "Some categorizations are incorrect. Check the plant and try again."
		player_answers.clear()
