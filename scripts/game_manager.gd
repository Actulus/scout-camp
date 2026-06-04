extends Node

@export var pause_menu_scene: PackedScene = preload("res://scenes/ui/pause_menu.tscn")
var pause_menu_instance = null

const BadgeMenuScript        = preload("res://scenes/ui/badge_menu.gd")
const BadgeEarnedPopupScript = preload("res://scenes/ui/badge_earned_popup.gd")
var _badge_menu_instance: CanvasLayer = null

var current_day: int = 1 
var fire_lit: bool = false
var skills_completed: Dictionary = {
	"shelter": false,
	"tent": false,
	"fire": false,
	"water": false,
	"plants": false,
	"animals": false,
	"navigation": false 
}
var badges_earned: Array = []
var scattered_positions: Array[Vector3] = []
var plant_guide_read: bool = false
var animal_guide_read: bool = false
var pages_found: int = 0

# Day/night time — 0.0 = dawn, 0.5 = noon, 1.0 = dusk
#var current_time: float = 0.5
#var day_length_seconds: float = 600.0
#var _dusk_fired: bool = false

signal skill_completed(skill_id: String)
signal badge_earned(badge_id: String)
#signal day_changed(day_number: int)
signal flag_found(flag_index: int)
#signal time_changed(time: float)
#signal dawn_reached
#signal dusk_reached

func _ready() -> void:
	reset()
	set_process_input(true)

func reset() -> void:
	current_day = 1
	fire_lit = false
	skills_completed = {
		"shelter": false,
		"tent": false,
		"fire": false,
		"water": false,
		"plants": false,
		"animals": false,
		"navigation": false
	}
	badges_earned.clear()
	scattered_positions.clear()
	plant_guide_read = false
	animal_guide_read = false
	pages_found = 0
	#current_time = 0.0
	#_dusk_fired = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("task_menu"):
		var menu = get_tree().get_first_node_in_group("task_menu")
		if menu:
			if menu.visible: menu._close()
			else: menu.open()

	if Input.is_action_just_pressed("badge_menu"):
		var badge_menu = _get_badge_menu()
		if badge_menu.visible: badge_menu._close()
		else: badge_menu.open()
				
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
		
func earn_badge(badge_id: String) -> void:
	if badge_id not in badges_earned:
		badges_earned.append(badge_id)
		emit_signal("badge_earned", badge_id)
		# Show earned popup
		var popup = BadgeEarnedPopupScript.new()
		get_tree().root.add_child(popup)
		popup.show_badge(badge_id)

		
func _get_badge_menu() -> CanvasLayer:
	if not is_instance_valid(_badge_menu_instance):
		_badge_menu_instance = BadgeMenuScript.new()
		get_tree().root.add_child(_badge_menu_instance)
	return _badge_menu_instance

#func advance_time(delta: float) -> void:
	#if current_time >= 1.0:
		#return
	#current_time = minf(current_time + delta / day_length_seconds, 1.0)
	#emit_signal("time_changed", current_time)
	#if current_time >= 0.85 and not _dusk_fired:
		#_dusk_fired = true
		#emit_signal("dusk_reached")

#func advance_day() -> void:
	#current_day += 1
	#current_time = 0.0
	#_dusk_fired = false
	#emit_signal("day_changed", current_day)
	#emit_signal("dawn_reached")
	

func _pause() -> void:
	get_tree().paused = true
	
	var plant_quiz = get_tree().get_first_node_in_group("plant_quiz")
	if plant_quiz:
		plant_quiz._close()
		
	var animal_quiz = get_tree().get_first_node_in_group("animal_quiz")
	if animal_quiz:
		animal_quiz._close()
	
	var task_menu = get_tree().get_first_node_in_group("task_menu")
	if task_menu and task_menu.visible:
		task_menu._close()
		
	var map = get_tree().get_first_node_in_group("map")
	if map and map.visible:
		map.visible = false

	if is_instance_valid(_badge_menu_instance) and _badge_menu_instance.visible:
		_badge_menu_instance._close()
	
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
