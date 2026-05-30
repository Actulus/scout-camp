extends PanelContainer

@onready var fullscreen_option: OptionButton = %FullscreenOption
@onready var resolution_option: OptionButton = %ResolutionOption
@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var back_btn: Button = %BackButton
@onready var apply_btn: Button = %SaveSettingsButton

const RESOLUTIONS = [
	Vector2i(1920, 1080),
	Vector2i(1280, 720),
	Vector2i(2560, 1440),
	Vector2i(1366, 768)
]

func _ready() -> void:
	back_btn.pressed.connect(func(): visible = false)
	apply_btn.pressed.connect(_apply_settings)
	_load_settings()

func _load_settings() -> void:
	# load saved settings or use defaults
	master_slider.value = GameSettings.master_volume
	music_slider.value = GameSettings.music_volume
	sfx_slider.value = GameSettings.sfx_volume
	sensitivity_slider.value = GameSettings.mouse_sensitivity
	fullscreen_option.selected = GameSettings.window_mode
	
	# update audio immediately on slider change
	master_slider.value_changed.connect(func(v): 
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Master"), linear_to_db(v)))
	music_slider.value_changed.connect(func(v):
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Music"), linear_to_db(v)))
	sfx_slider.value_changed.connect(func(v):
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("SFX"), linear_to_db(v)))

func _apply_settings() -> void:
	# window mode
	match fullscreen_option.selected:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		2: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	
	# resolution (only in windowed)
	if fullscreen_option.selected == 1:
		var res = RESOLUTIONS[resolution_option.selected]
		DisplayServer.window_set_size(res)
	
	# save to GameSettings
	GameSettings.master_volume = master_slider.value
	GameSettings.music_volume = music_slider.value
	GameSettings.sfx_volume = sfx_slider.value
	GameSettings.mouse_sensitivity = sensitivity_slider.value
	GameSettings.window_mode = fullscreen_option.selected
	GameSettings.save()
	
	visible = false
