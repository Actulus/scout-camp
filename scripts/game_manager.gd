extends Node

@export var pause_menu_scene: PackedScene = preload("res://scenes/ui/pause_menu.tscn")
var pause_menu_instance = null

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

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		# don't pause if on main menu
		if get_tree().current_scene.scene_file_path.contains("main_menu"):
			return
		if pause_menu_instance:
			_resume()
		else:
			_pause()

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
	

func _pause() -> void:
	get_tree().paused = true
	
	var quiz = get_tree().get_first_node_in_group("plant_quiz")
	if quiz:
		quiz._close()
	
	var task_menu = get_tree().get_first_node_in_group("task_menu")
	if task_menu and task_menu.visible:
		task_menu._close()
		
	var map = get_tree().get_first_node_in_group("map")
	if map and map.visible:
		map.visible = false
	
	pause_menu_instance = pause_menu_scene.instantiate()
	pause_menu_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(pause_menu_instance)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pause_menu_instance.resumed.connect(_resume)

func _resume() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if pause_menu_instance:
		pause_menu_instance.queue_free()
		pause_menu_instance = null
