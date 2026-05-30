extends CanvasLayer

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var status_label: Label = %StatusLabel

var _target_scene: String = ""

func load_scene(path: String) -> void:
	_target_scene = path
	visible = true
	status_label.text = "Loading..."
	ResourceLoader.load_threaded_request(path)
	set_process(true)

func _process(_delta: float) -> void:
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(_target_scene, progress)
	
	if progress.size() > 0:
		progress_bar.value = progress[0] * 100
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			status_label.text = "Loading... %d%%" % int(progress_bar.value)
		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)
			var scene = ResourceLoader.load_threaded_get(_target_scene)
			get_tree().change_scene_to_packed(scene)
			visible = false
		ResourceLoader.THREAD_LOAD_FAILED:
			status_label.text = "Failed to load!"
			set_process(false)
