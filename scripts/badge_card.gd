extends CanvasLayer

var badge_data = {
	"shelter": {
		"name": "The Shelter Builder",
		"text": "Frame first, insulation second, roof last.\nAlways sleep off cold ground."
	},
	"fire": {
		"name": "The Fire Starter",
		"text": "Dry tinder first, insulation second, roof lat.\nNever use wet wood."
	},	
	"water": {
		"name": "The Water Guardian",
		"text": "Always boil found water for at least 1 minute."
	},	
	"plants": {
		"name": "The Nature Reader",
		"text": "Red/white mushrooms and shiny dark berries are often poisonous."
	},
	"navigation": {
		"name": "The Pathfinder",
		"text": "Note landmarks. The sun rises east. Use compass with map."
	}	
}

@onready var badge_name = $Control/Panel/BadgeName
@onready var knowledge = $Control/Panel/KnowledgeText
@onready var btn = $Control/Panel/DismissBtn

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	btn.pressed.connect(hide)
	GameManager.badge_earned.connect(_on_badge_earned)
	
func _on_badge_earned(badge_id: String):
	if badge_id in badge_data:
		badge_name.text = badge_data[badge_id]["name"]
		knowledge.text = badge_data[badge_id]["text"]
		show()
