extends Control

@onready var play_btn: Button = %PlayButton
@onready var settings_btn: Button = %SettingsButton
@onready var controls_btn: Button = %ControlsButton
@onready var quit_btn: Button = %QuitButton

var settings_scene = preload("res://scenes/ui/settings_panel.tscn")
var controls_scene = preload("res://scenes/ui/controls_panel.tscn")
var settings_instance = null
var controls_instance = null

var _continue_btn: Button = null

func _ready() -> void:
	# Style quit button
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

	# Inject Continue button when a save file exists
	if SaveSystem.has_save():
		_inject_continue_button()
		await get_tree().process_frame
		_continue_btn.grab_focus.call_deferred()
	else:
		await get_tree().process_frame
		play_btn.grab_focus.call_deferred()

func _inject_continue_button() -> void:
	var vbox: VBoxContainer = $CenterContainer/VBoxContainer

	_continue_btn = Button.new()
	_continue_btn.text = "Continue"
	_continue_btn.custom_minimum_size = Vector2(280, 56)

	var style = StyleBoxFlat.new()
	style.bg_color     = Color("#1B4D2E")
	style.border_color = Color("#C68B3A")
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.content_margin_left   = 20
	style.content_margin_right  = 20
	style.content_margin_top    = 10
	style.content_margin_bottom = 10
	_continue_btn.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = Color("#256B3F")
	_continue_btn.add_theme_stylebox_override("hover", hover)

	_continue_btn.pressed.connect(_on_continue)
	vbox.add_child(_continue_btn)
	# Move above PlayButton
	vbox.move_child(_continue_btn, play_btn.get_index())

	# Update New Game button text for clarity
	play_btn.text = "New Game"

func _on_continue() -> void:
	# Load saved game state into GameManager; player position applied after world loads
	SaveSystem.load_game_state()
	PerformanceMonitor.start_timer()
	LoadingScreen.load_scene("res://scenes/world/world.tscn")
	PerformanceMonitor.end_timer("world.tscn load")

func _on_play() -> void:
	SaveSystem.delete_save()
	GameManager.reset()
	PerformanceMonitor.start_timer()
	LoadingScreen.load_scene("res://scenes/world/world.tscn")
	PerformanceMonitor.end_timer("world.tscn load")

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
