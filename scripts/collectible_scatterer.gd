extends Node3D

@export var collectible_scene: PackedScene
@export var count: int = 15
@export var world_radius: float = 55.0
@export var camp_clear_radius: float = 8.0
@export var min_distance_from_others: float = 3.0
@export var avoid_multimeshes: Array[NodePath] = []
@export var water_level: float = -1.5

var _placed_positions: Array[Vector3] = []
var _avoid_transforms: Array[Transform3D] = []

func _ready():
	await get_tree().physics_frame
	await get_tree().physics_frame
	_cache_multimesh_positions()
	_scatter()

func _cache_multimesh_positions():
	for path in avoid_multimeshes:
		var node = get_node(path) as MultiMeshInstance3D
		if not node or not node.multimesh: continue
		for i in node.multimesh.instance_count:
			_avoid_transforms.append(
				node.multimesh.get_instance_transform(i)
			)

func _scatter():
	var placed = 0
	var attempts = 0
	while placed < count and attempts < count * 20:
		attempts += 1
		var x = randf_range(-world_radius, world_radius)
		var z = randf_range(-world_radius, world_radius)
		var dist = Vector2(x, z).length()
		if dist > world_radius: continue
		if dist < camp_clear_radius: continue
		var height = _get_height(x, z)
		if height < water_level: continue
		var pos = Vector3(x, _get_height(x, z), z)
		if _too_close(pos): continue

		var instance = collectible_scene.instantiate()
		add_child(instance)
		instance.global_position = pos

		# rotate randomly so items don't all face same direction
		instance.rotation.y = randf() * TAU

		_placed_positions.append(pos)
		GameManager.scattered_positions.append(pos)
		placed += 1
		

func _too_close(pos: Vector3) -> bool:
	for p in _placed_positions:
		if pos.distance_to(p) < min_distance_from_others:
			return true
	for t in _avoid_transforms:
		if pos.distance_to(t.origin) < min_distance_from_others:
			return true
	#for p in GameManager.scattered_positions:
		#if pos.distance_to(p) < min_distance_from_others:
			#return true
	return false

func _get_height(x: float, z: float) -> float:
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		Vector3(x, 50, z), Vector3(x, -50, z))
	query.collision_mask = 1
	var result = space.intersect_ray(query)
	return result.position.y if result else 0.0
