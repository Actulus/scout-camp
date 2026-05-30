extends Control

@onready var play_btn: Button = %PlayButton
@onready var settings_btn: Button = %SettingsButton
@onready var controls_btn: Button = %ControlsButton
@onready var quit_btn: Button = %QuitButton

var settings_scene = preload("res://scenes/ui/settings_panel.tscn")
var controls_scene = preload("res://scenes/ui/controls_panel.tscn")
var settings_instance = null
var controls_instance = null

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if play_btn: play_btn.pressed.connect(_on_play)
	if settings_btn: settings_btn.pressed.connect(_on_settings)
	if controls_btn: controls_btn.pressed.connect(_on_controls)
	if quit_btn: quit_btn.pressed.connect(_on_quit)

func _on_play() -> void:
	# show loading screen then load world
	LoadingScreen.load_scene("res://scenes/world/world.tscn")

func _on_settings() -> void:
	if settings_instance: return
	settings_instance = settings_scene.instantiate()
	add_child(settings_instance)
	settings_instance.get_node("%BackButton").pressed.connect(func():
		settings_instance.queue_free()
		settings_instance = null)

func _on_controls() -> void:
	if controls_instance: return
	controls_instance = controls_scene.instantiate()
	add_child(controls_instance)
	controls_instance.get_node("%BackButton").pressed.connect(func():
		controls_instance.queue_free()
		controls_instance = null)

func _on_quit() -> void:
	get_tree().quit()
