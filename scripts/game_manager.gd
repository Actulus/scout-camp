extends Node

var current_day: int = 1 
var fire_lit: bool = false
var skills_completed: Dictionary = {
	"shelter": false,
	"tent": false,
	"fire": false,
	"water": false,
	"plants": false,
	"navigation": false 
}
var badges_earned: Array = []
var scattered_positions: Array[Vector3] = []
var plant_guide_read: bool = false
var pages_found: int = 0

signal skill_completed(skill_id: String)
signal badge_earned(badge_id: String)
signal day_changed(day_number: int)
signal flag_found(flag_index: int)

func _ready() -> void:
	scattered_positions.clear()

func complete_skill(skill_id:  String):
	if not skills_completed[skill_id]:
		skills_completed[skill_id] = true
		emit_signal("skill_completed", skill_id)
		earn_badge(skill_id)
		
func earn_badge(badge_id: String):
	if badge_id not in badges_earned: 
		badges_earned.append(badge_id)
		emit_signal("badge_earned", badge_id)
		
func advance_day():
	current_day += 1
	emit_signal("day_changed", current_day)
	
