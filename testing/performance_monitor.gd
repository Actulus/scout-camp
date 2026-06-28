extends Node
## PerformanceMonitor
## Add as an AutoLoad in Project Settings > AutoLoad
## Toggle display with F12 in-game
## Logs a snapshot next to the project/executable with F11

var LOG_PATH: String

var _display: bool = false
var _label: Label
var _canvas: CanvasLayer
var _frame_times: Array[float] = []
var _max_samples: int = 60

# Called externally to measure load/save times
var _ticks_start: int = 0

func _ready() -> void:
	if OS.has_feature("editor"):
		LOG_PATH = ProjectSettings.globalize_path("res://performance_log.txt")
	else:
		LOG_PATH = OS.get_executable_path().get_base_dir().path_join("performance_log.txt")
	_setup_overlay()

func _setup_overlay() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = 100
	add_child(_canvas)

	_label = Label.new()
	_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_label.position = Vector2(10, 10)
	_label.add_theme_font_size_override("font_size", 13)
	_label.add_theme_color_override("font_color", Color.WHITE)

	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.6)
	bg.set_corner_radius_all(4)
	bg.content_margin_left = 8
	bg.content_margin_right = 8
	bg.content_margin_top = 6
	bg.content_margin_bottom = 6
	_label.add_theme_stylebox_override("normal", bg)

	_label.visible = false
	_canvas.add_child(_label)

func _process(_delta: float) -> void:
	# Track frame times for FPS average
	_frame_times.append(Performance.get_monitor(Performance.TIME_FPS))
	if _frame_times.size() > _max_samples:
		_frame_times.pop_front()

	if _display:
		_label.text = _build_stats()

func _input(event: InputEvent) -> void:
	# F12 toggles overlay
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F12:
			_display = not _display
			_label.visible = _display
		# F11 saves snapshot to file
		elif event.keycode == KEY_F11:
			_save_snapshot()
			print("[PerformanceMonitor] Snapshot saved to ", LOG_PATH)

func _build_stats() -> String:
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var avg_fps = 0.0
	if _frame_times.size() > 0:
		avg_fps = _frame_times.reduce(func(a, b): return a + b) / _frame_times.size()
	var min_fps = _frame_times.min() if _frame_times.size() > 0 else 0.0

	var ram_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / 1_048_576.0
	var vram_mb = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1_048_576.0
	var draw_calls = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var objects = Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	var triangles = Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)

	return """[ScoutCamp Performance Monitor]
FPS (current):   %d
FPS (avg/60f):   %.1f
FPS (min/60f):   %.1f
RAM:             %.1f MB
VRAM:            %.1f MB
Draw Calls:      %d
Objects:         %d
Triangles:       %d
Position:        %s
""" % [fps, avg_fps, min_fps, ram_mb, vram_mb, draw_calls, objects, triangles, _get_current_location()]

func _save_snapshot() -> void:
	var location = _get_current_location()
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var avg_fps = 0.0
	if _frame_times.size() > 0:
		avg_fps = _frame_times.reduce(func(a, b): return a + b) / _frame_times.size()
	var min_fps = _frame_times.min() if _frame_times.size() > 0 else 0.0
	var ram_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / 1_048_576.0
	var vram_mb = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1_048_576.0
	var draw_calls = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)

	var timestamp = Time.get_datetime_string_from_system()
	var entry = """
=== Snapshot: %s ===
Location:      %s
FPS:           %d (avg: %.1f, min: %.1f)
RAM:           %.1f MB
VRAM:          %.1f MB
Draw Calls:    %d
""" % [timestamp, location, fps, avg_fps, min_fps, ram_mb, vram_mb, draw_calls]

	var file = FileAccess.open(LOG_PATH, FileAccess.READ_WRITE if FileAccess.file_exists(LOG_PATH) else FileAccess.WRITE)
	if file:
		file.seek_end()
		file.store_string(entry)
		file.close()

func _get_current_location() -> String:
	var player = get_tree().get_first_node_in_group("player")
	if player and player is Node3D:
		var p: Vector3 = player.global_position
		return "(%.1f, %.1f, %.1f)" % [p.x, p.y, p.z]
	return "no player"

# ── Called externally around load/save operations ──────────────────────────

## Call this right before loading world.tscn
func start_timer() -> void:
	_ticks_start = Time.get_ticks_msec()

## Call this right after the operation finishes, returns ms elapsed
func end_timer(label: String = "Operation") -> int:
	var elapsed = Time.get_ticks_msec() - _ticks_start
	print("[PerformanceMonitor] %s took %d ms" % [label, elapsed])
	var file = FileAccess.open(LOG_PATH, FileAccess.READ_WRITE if FileAccess.file_exists(LOG_PATH) else FileAccess.WRITE)
	if file:
		file.seek_end()
		file.store_string("\n[Timer] %s: %d ms\n" % [label, elapsed])
		file.close()
	return elapsed
