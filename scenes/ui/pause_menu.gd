extends CanvasLayer

signal resumed

@onready var resume_btn: Button = %ResumeButton
@onready var save_btn: Button = %SaveButton
@onready var main_menu_btn: Button = %MainMenuButton
@onready var settings_btn: Button = %SettingsButton
@onready var controls_btn: Button = %ControlsButton

var settings_scene = preload("res://scenes/ui/settings_panel.tscn")
var settings_instance = null
var controls_scene = preload("res://scenes/ui/controls_panel.tscn")
var controls_instance = null

func _ready() -> void:
	resume_btn = get_node_or_null("%ResumeButton")
	save_btn = get_node_or_null("%SaveButton")
	main_menu_btn = get_node_or_null("%MainMenuButton")
	settings_btn = get_node_or_null("%SettingsButton")
	controls_btn = get_node_or_null("%ControlsButton")

	if resume_btn: resume_btn.pressed.connect(func(): resumed.emit())
	if save_btn: save_btn.pressed.connect(_save_game)
	if main_menu_btn: main_menu_btn.pressed.connect(_go_to_main_menu)
	if settings_btn: settings_btn.pressed.connect(_open_settings)
	if controls_btn: controls_btn.pressed.connect(_open_controls)
	
	resume_btn.grab_focus.call_deferred()

func _save_game() -> void:
	PerformanceMonitor.start_timer()
	SaveSystem.save()
	PerformanceMonitor.end_timer("save()")
	save_btn.text = "Saved!"
	save_btn.disabled = true
	await get_tree().create_timer(1.5, true).timeout
	if is_instance_valid(save_btn):
		save_btn.text = "Save Game"
		save_btn.disabled = false

func _go_to_main_menu() -> void:
	# close everything before scene change
	var map = get_tree().get_first_node_in_group("map_ui")
	if map: map.queue_free()
	var task = get_tree().get_first_node_in_group("task_menu")
	if task: task.queue_free()
	var dialogue = get_tree().get_first_node_in_group("dialogue_ui")
	if dialogue: dialogue.queue_free()
	get_tree().paused = false
	queue_free()
	LoadingScreen.load_scene("res://scenes/ui/main_menu.tscn")

func _open_settings() -> void:
	if settings_instance and is_instance_valid(settings_instance): return
	settings_instance = settings_scene.instantiate()
	settings_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	# remove the layer = 11 line, it's already set in the scene
	get_tree().root.add_child(settings_instance)
	var back = settings_instance.get_node_or_null("%BackButton")
	if back:
		back.pressed.connect(func():
			settings_instance.queue_free()
			settings_instance = null
			var s_btn = get_node_or_null("%SettingsButton")
			if s_btn: s_btn.grab_focus.call_deferred())

func _open_controls() -> void:
	if controls_instance and is_instance_valid(controls_instance): return
	controls_instance = controls_scene.instantiate()
	controls_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(controls_instance)
	var back = controls_instance.get_node_or_null("%BackButton")
	if back:
		back.pressed.connect(func():
			controls_instance.queue_free()
			controls_instance = null
			var c_btn = get_node_or_null("%ControlsButton")
			if c_btn: c_btn.grab_focus.call_deferred())
