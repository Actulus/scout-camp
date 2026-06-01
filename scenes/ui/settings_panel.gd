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
	
	# update labels on load
	%MasterValueLabel.text = "%d%%" % int(master_slider.value * 100)
	%MusicValueLabel.text = "%d%%" % int(music_slider.value * 100)
	%SFXValueLabel.text = "%d%%" % int(sfx_slider.value * 100)
	%SensitivityValueLabel.text = "%d%%" % int(sensitivity_slider.value * 100)
	
	# update audio immediately on slider change
	master_slider.value_changed.connect(func(v):
		%MasterValueLabel.text = "%d%%" % int(v * 100)
		_set_bus_volume("Master", v))
	music_slider.value_changed.connect(func(v):
		%MusicValueLabel.text = "%d%%" % int(v * 100)
		_set_bus_volume("Music", v))
	sfx_slider.value_changed.connect(func(v):
		%SFXValueLabel.text = "%d%%" % int(v * 100)
		_set_bus_volume("SFX", v))
	sensitivity_slider.value_changed.connect(func(v):
		%SensitivityValueLabel.text = "%d%%" % int(v * 100)
		GameSettings.mouse_sensitivity = v)

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

func _set_bus_volume(bus_name: String, volume: float) -> void:
	var idx = AudioServer.get_bus_index(bus_name)
	if idx == -1:
		push_error("Audio bus not found: " + bus_name)
		return
	AudioServer.set_bus_volume_db(idx, linear_to_db(volume))
