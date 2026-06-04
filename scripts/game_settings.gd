extends Node

const SAVE_PATH = "user://settings.cfg"

var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var mouse_sensitivity: float = 0.2
var window_mode: int = 0  # 0=fullscreen, 1=windowed, 2=maximized

func _ready() -> void:
	load_settings()

func save() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "master", master_volume)
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.set_value("display", "window_mode", window_mode)
	config.set_value("gameplay", "sensitivity", mouse_sensitivity)
	config.save(SAVE_PATH)

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	master_volume = config.get_value("audio", "master", 1.0)
	music_volume = config.get_value("audio", "music", 0.8)
	sfx_volume = config.get_value("audio", "sfx", 1.0)
	window_mode = config.get_value("display", "window_mode", 0)
	mouse_sensitivity = config.get_value("gameplay", "sensitivity", 0.2)
	_apply()

func _apply() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),  linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),    linear_to_db(sfx_volume))
	match window_mode:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		2: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
