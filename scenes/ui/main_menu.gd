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
	# style quit button differently
	var quit_normal = StyleBoxFlat.new()
	quit_normal.bg_color = Color("#8B2E2E")
	quit_normal.border_color = Color("#C68B3A")
	quit_normal.set_border_width_all(2)
	quit_normal.set_corner_radius_all(12)
	quit_normal.content_margin_left = 20
	quit_normal.content_margin_right = 20
	quit_normal.content_margin_top = 10
	quit_normal.content_margin_bottom = 10
	%QuitButton.add_theme_stylebox_override("normal", quit_normal)
	
	var quit_hover = quit_normal.duplicate()
	quit_hover.bg_color = Color("#B23A3A")
	%QuitButton.add_theme_stylebox_override("hover", quit_hover)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if play_btn: play_btn.pressed.connect(_on_play)
	if settings_btn: settings_btn.pressed.connect(_on_settings)
	if controls_btn: controls_btn.pressed.connect(_on_controls)
	if quit_btn: quit_btn.pressed.connect(_on_quit)
	await get_tree().process_frame
	play_btn.grab_focus.call_deferred()

func _on_play() -> void:
	GameManager.reset()
	LoadingScreen.load_scene("res://scenes/world/world.tscn")

func _on_settings() -> void:
	if settings_instance and is_instance_valid(settings_instance):
		return
	settings_instance = settings_scene.instantiate()
	add_child(settings_instance)
	var back = settings_instance.get_node_or_null("%BackButton")
	if back:
		back.pressed.connect(_close_settings)

func _close_settings() -> void:
	if settings_instance and is_instance_valid(settings_instance):
		settings_instance.queue_free()
	settings_instance = null
	# restore focus to settings button
	if settings_btn:
		settings_btn.grab_focus.call_deferred()

func _on_controls() -> void:
	if controls_instance and is_instance_valid(controls_instance):
		return
	controls_instance = controls_scene.instantiate()
	add_child(controls_instance)
	var back = controls_instance.get_node_or_null("%BackButton")
	if back:
		back.pressed.connect(_close_controls)

func _close_controls() -> void:
	if controls_instance and is_instance_valid(controls_instance):
		controls_instance.queue_free()
	controls_instance = null
	# restore focus to controls button
	if controls_btn:
		controls_btn.grab_focus.call_deferred()

func _on_quit() -> void:
	get_tree().quit()
