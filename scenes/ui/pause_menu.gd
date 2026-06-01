extends CanvasLayer

signal resumed

@onready var resume_btn: Button = %ResumeButton
@onready var main_menu_btn: Button = %MainMenuButton
@onready var settings_btn: Button = %SettingsButton
@onready var controls_btn: Button = %ControlsButton

var settings_scene = preload("res://scenes/ui/settings_panel.tscn")
var settings_instance = null
var controls_scene = preload("res://scenes/ui/controls_panel.tscn")
var controls_instance = null

func _ready() -> void:
	resume_btn = get_node_or_null("%ResumeButton")
	main_menu_btn = get_node_or_null("%MainMenuButton")
	settings_btn = get_node_or_null("%SettingsButton")
	controls_btn = get_node_or_null("%ControlsButton")
	
	if resume_btn: resume_btn.pressed.connect(func(): resumed.emit())
	if main_menu_btn: main_menu_btn.pressed.connect(_go_to_main_menu)
	if settings_btn: settings_btn.pressed.connect(_open_settings)
	if controls_btn: controls_btn.pressed.connect(_open_controls)

func _go_to_main_menu() -> void:
	# close everything before scene change
	var map = get_tree().get_first_node_in_group("map_ui")
	if map: map.queue_free()
	var task = get_tree().get_first_node_in_group("task_menu")
	if task: task.queue_free()
	get_tree().paused = false
	queue_free()
	LoadingScreen.load_scene("res://scenes/ui/main_menu.tscn")

func _open_settings() -> void:
	if settings_instance: return
	settings_instance = settings_scene.instantiate()
	add_child(settings_instance)
	var back = settings_instance.get_node_or_null("%BackButton")
	if back: back.pressed.connect(func():
		settings_instance.queue_free()
		settings_instance = null)

func _open_controls() -> void: 
	if controls_instance: return
	controls_instance = controls_scene.instantiate()
	add_child(controls_instance)
	var back = controls_instance.get_node_or_null("%BackButton")
	if back: back.pressed.connect(func():
		controls_instance.queue_free()
		controls_instance = null)
