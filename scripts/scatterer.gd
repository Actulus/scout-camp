extends MultiMeshInstance3D

@export var count: int = 300
@export var world_radius: float = 60.0
@export var camp_clear_radius: float = 15.0
@export var scale_min: float = 4.0
@export var scale_max: float = 7.0
@export var collision_radius: float = 1.0
@export var collision_height: float = 3.0

func _ready():
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = count
	var placed = 0
	var attempts = 0
	while placed < count and attempts < count * 10:
		attempts += 1
		var x = randf_range(-world_radius, world_radius)
		var z = randf_range(-world_radius, world_radius)
		var dist = Vector2(x, z).length()
		if dist < camp_clear_radius: continue
		# density increases toward edges
		var edge_factor = dist / world_radius
		if randf() > edge_factor: continue
		var t = Transform3D()
		t.origin = Vector3(x, _get_height(x, z), z)
		t.basis = t.basis.rotated(Vector3.UP, randf() * TAU)
		var s = randf_range(scale_min, scale_max)
		t.basis = t.basis.scaled(Vector3(s, s, s))
		multimesh.set_instance_transform(placed, t)
		placed += 1
	multimesh.instance_count = placed
	_add_collision()

func _get_height(x: float, z: float) -> float:
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		Vector3(x, 50, z), Vector3(x, -50, z))
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
		
		var adjusted = mesh_transform
		adjusted.origin.y += collision_height / 2.0
		# strip scale from transform so shape isn't stretched
		adjusted.basis = adjusted.basis.orthonormalized()
		shape.transform = adjusted
		
		sBody.add_child(shape)
