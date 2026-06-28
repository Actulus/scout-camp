class_name LightInteraction
extends AbstractInteraction

@export var light_on_text: String = "Turn off light"
@export var light_off_text: String = "Turn on light"
@export var emission_energy: float = 1.0
@export var emission_color: Color = Color(0.85, 0.65, 0.0)
@export var lamp_mesh: MeshInstance3D
@export var cover_surface_index: int = 1

var light: OmniLight3D
var bulb: MeshInstance3D
var is_on: bool = false
var _cooldown: bool = false
var _bulb_material: StandardMaterial3D
var _cover_material: StandardMaterial3D

func _ready() -> void:
	super()
	for child in object_ref.get_children():
		if child is OmniLight3D:
			light = child
		if child.name == "Bulb":
			bulb = child

	if bulb:
		_bulb_material = StandardMaterial3D.new()
		_bulb_material.emission_enabled = true
		_bulb_material.emission = emission_color
		_bulb_material.emission_energy_multiplier = emission_energy
		bulb.material_override = _bulb_material
	
	if lamp_mesh:
		var existing = lamp_mesh.get_active_material(cover_surface_index)
		if existing:
			_cover_material = existing.duplicate()
		else:
			_cover_material = StandardMaterial3D.new()
		_cover_material.emission_enabled = true
		_cover_material.emission = emission_color
		_cover_material.emission_energy_multiplier = emission_energy
		lamp_mesh.set_surface_override_material(cover_surface_index, _cover_material)
		
	_set_light_state(false)

func pre_interact() -> void:
	super()
	_toggle_light()

func interact() -> void:
	super()

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()

func use_item(_item_data: ItemData) -> bool:
	return false

func _toggle_light() -> void:
	is_on = not is_on
	_set_light_state(is_on)
	
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic._show_interaction_text(
			light_on_text if is_on else light_off_text, 1.5)

func _set_light_state(state: bool) -> void:
	if light:
		light.visible = state
	if bulb:
		bulb.visible = state
	if _bulb_material:
		_bulb_material.emission_energy_multiplier = emission_energy if state else 0.0
	if _cover_material:
		_cover_material.emission_energy_multiplier = emission_energy if state else 0.0
