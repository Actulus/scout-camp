extends MultiMeshInstance3D

@export var count: int = 300
@export var world_radius: float = 60.0
@export var camp_clear_radius: float = 15.0
@export var scale_min: float = 4.0
@export var scale_max: float = 7.0
@export var collision_radius: float = 1.0
@export var collision_height: float = 3.0
@export var min_distance_from_others: float = 3.0
@export var avoid_multimeshes: Array[NodePath] = []
@export var water_level: float = -1.5

var _placed_positions: Array[Vector3] = []
var _avoid_transforms: Array[Transform3D] = []

func _ready():
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = count
	#await get_tree().physics_frame
	_cache_multimesh_positions()
	_scatter()
	_add_collision()

func _scatter():
	var attempts = 0
	var rejected_water = 0
	var rejected_edge = 0
	var rejected_camp = 0
	var rejected_close = 0
	var transforms: Array[Transform3D] = []
	while transforms.size() < count and attempts < count * 5:
		attempts += 1
		var x = randf_range(-world_radius, world_radius)
		var z = randf_range(-world_radius, world_radius)
		var dist = Vector2(x, z).length()
		if dist > world_radius: continue
		if dist < camp_clear_radius:
			rejected_camp += 1
			continue
		var height = _get_height(x, z)
		if height < water_level:
			rejected_water += 1
			continue
		var edge_factor = dist / world_radius
		if randf() > edge_factor:
			rejected_edge += 1
			continue
		var pos = Vector3(x, height, z)
		if _too_close(pos):
			rejected_close += 1
			continue
		var t = Transform3D()
		t.origin = pos
		t.basis = t.basis.rotated(Vector3.UP, randf() * TAU)
		var s = randf_range(scale_min, scale_max)
		t.basis = t.basis.scaled(Vector3(s, s, s))
		transforms.append(t)
		GameManager.scattered_positions.append(pos)
		_placed_positions.append(pos)
	var placed = transforms.size()
	#print("=== SCATTER RESULTS ===")
	#print("Placed: ", placed, "/", count)
	#print("Total attempts: ", attempts)
	#print("Rejected water: ", rejected_water)
	#print("Rejected edge factor: ", rejected_edge)
	#print("Rejected camp: ", rejected_camp)
	#print("Rejected too close: ", rejected_close)
	#print("Height sample at 0,0: ", _get_height(0, 0))
	#print("Height sample at 30,30: ", _get_height(30, 30))
	multimesh.instance_count = placed
	for i in placed:
		multimesh.set_instance_transform(i, transforms[i])

func _cache_multimesh_positions():
	for path in avoid_multimeshes:
		var node = get_node(path) as MultiMeshInstance3D
		if not node or not node.multimesh: continue
		for i in node.multimesh.instance_count:
			_avoid_transforms.append(
				node.multimesh.get_instance_transform(i)
			)

func _get_height(x: float, z: float) -> float:
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		Vector3(x, 50, z), Vector3(x, -50, z))
	query.collision_mask = 1
	var result = space.intersect_ray(query)
	return result.position.y if result else 0.0

func _add_collision():
	var sBody = StaticBody3D.new()
	add_child(sBody)
	sBody.owner = owner

	for i in multimesh.instance_count:
		var mesh_transform = multimesh.get_instance_transform(i)
		
		var shape = CollisionShape3D.new()
		var cylinder = CylinderShape3D.new()
		cylinder.radius = collision_radius
		cylinder.height = collision_height
		shape.shape = cylinder
		
		# extract position only, build clean transform from scratch
		var clean_transform = Transform3D()
		clean_transform.origin = mesh_transform.origin
		clean_transform.origin.y += collision_height / 2.0
		# no rotation needed for cylinder trunks
		shape.transform = clean_transform
		
		sBody.add_child(shape)
		
func _too_close(pos: Vector3) -> bool:
	for p in _placed_positions:
		if pos.distance_to(p) < min_distance_from_others:
			return true
	for t in _avoid_transforms:
		if pos.distance_to(t.origin) < min_distance_from_others:
			return true
	for p in GameManager.scattered_positions:
		if pos.distance_to(p) < min_distance_from_others:
			return true
	return false
