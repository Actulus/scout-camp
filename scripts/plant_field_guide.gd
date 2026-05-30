extends StaticBody3D

@onready var closed_mesh: MeshInstance3D = $ClosedBook
@onready var open_mesh: MeshInstance3D = $OpenBook

func _ready() -> void:
	if open_mesh:
		open_mesh.visible = false

# Called by interaction_controller.on_note_inspected() when the player starts reading.
func on_inspection_started() -> void:
	if closed_mesh:
		closed_mesh.visible = false
	if open_mesh:
		open_mesh.visible = true
