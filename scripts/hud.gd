extends CanvasLayer

var badge_colors = {
	"shelter": Color("#8B4513"),
	"fire": Color("#FF6600"),
	"water": Color("#0088FF"),
	"plants": Color("#228B22"),
	"navigation": Color("#FFD700"),
}
var badge_slots = ["shelter", "fire", "water", "plants", "navigation"]

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.badge_earned.connect(_on_badge_earned)

func _on_badge_earned(badge_id: String):
	var idx = badge_slots.find(badge_id)
	if idx >= 0:
		get_node("Control/Panel/Badge" + str(idx+1)).color = badge_colors[badge_id]
