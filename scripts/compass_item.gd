extends RigidBody3D

var needle: MeshInstance3D

func _ready() -> void:
	needle = get_node_or_null("Needle")

func _process(_delta: float) -> void:
	if not needle:
		return
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var camera = player.get_node_or_null("%Camera3D")
	if not camera:
		return
	# Keep needle pointing to world north (-Z) by cancelling the camera's Y rotation.
	# The compass body rotates with the player, so the needle counter-rotates to stay fixed.
	needle.rotation.y = camera.global_rotation.y
