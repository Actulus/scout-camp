@tool  # makes it run in the editor so you can see it immediately
extends MultiMeshInstance3D

@export var scatter_now: bool = false:
	set(value):
		scatter()
@export var count: int = 100
@export var area_size: float = 50.0
@export var min_scale: float = 0.8
@export var max_scale: float = 1.2
@export var seed: int = 42

func _notification(what):
	if what == NOTIFICATION_READY or \
	   what == NOTIFICATION_EDITOR_POST_SAVE:
		scatter()

func _ready():
	scatter()

func scatter():
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	
	multimesh.instance_count = count
	
	for i in count:
		var x = rng.randf_range(-area_size, area_size)
		var z = rng.randf_range(-area_size, area_size)
		var scale = rng.randf_range(min_scale, max_scale)
		var rotation_y = rng.randf_range(0, TAU)
		
		var t = Transform3D()
		t = t.rotated(Vector3.UP, rotation_y)
		t = t.scaled(Vector3(scale, scale, scale))
		t.origin = Vector3(x, 0, z)
		
		multimesh.set_instance_transform(i, t)
