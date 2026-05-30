class_name PotInteraction
extends AbstractInteraction

@export var boil_time: float = 10.0

const BOILED_MUG_SCENE = preload("res://interactions/CollectableInteraction/EquippableInteraction/Interactables/boiled_water_mug.tscn")
const PURIFIED_MUG_SCENE = preload("res://interactions/CollectableInteraction/EquippableInteraction/Interactables/purified_water_mug.tscn")

# State: "", "dirty_water", "boiled_water", "purified_water"
var contents: String = ""
var is_boiling: bool = false
var boil_remaining: int = 0
var water_surface: MeshInstance3D

const COLOR_DIRTY    := Color(0.42, 0.26, 0.15, 0.85)
const COLOR_HOT      := Color(0.9,  0.4,  0.1,  0.85)
const COLOR_BOILED   := Color(0.2,  0.5,  0.8,  0.85)
const COLOR_PURIFIED := Color(0.7,  0.9,  1.0,  0.9)

func _ready() -> void:
	super()
	water_surface = object_ref.get_node_or_null("WaterSurface")
	if water_surface: water_surface.visible = false

func pre_interact() -> void:
	super()

func interact() -> void:
	super()
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if not ic: return
	match contents:
		"":
			ic._show_interaction_text("Add dirty water to the pot first", 1.5)
		"dirty_water":
			if is_boiling:
				ic.interaction_textbox.text = "Boiling... %ds remaining" % boil_remaining
				ic.interaction_textbox.visible = true
			elif object_ref.is_in_group("cooking_pot") and GameManager.fire_lit:
				ic._show_interaction_text("Pot on fire — boiling starting soon!", 1.5)
			elif GameManager.fire_lit:
				ic._show_interaction_text("Equip pot and use it on the firepit to place it on fire.", 1.5)
			else:
				ic._show_interaction_text("Light the fire to boil the water!", 1.5)
		"boiled_water":
			ic._show_interaction_text("Boiled! Equip a mug and use it here, or add purification tablet.", 2.0)
		"purified_water":
			ic._show_interaction_text("Purified! Equip a mug and use it here to collect.", 2.0)

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()

func use_item(item_data: ItemData) -> bool:
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	match item_data.item_name:

		"bucket_dirty_water":
			if contents != "":
				if ic: ic._show_interaction_text("Pot already has something in it!", 2.0)
				return false
			contents = "dirty_water"
			_set_water(COLOR_DIRTY)
			if object_ref.is_in_group("cooking_pot") and GameManager.fire_lit:
				if ic: ic._show_interaction_text("Dirty water added — boiling started!", 2.0)
				_start_cooking()
			else:
				if ic: ic._show_interaction_text("Dirty water added. Place pot on lit fire to boil.", 2.0)
			return true

		"mug":
			if contents == "boiled_water":
				if ic: ic.swap_equipped_item_after_use(BOILED_MUG_SCENE)
				contents = ""
				if water_surface: water_surface.visible = false
				if ic: ic._show_interaction_text("Boiled water collected in mug!", 2.0)
				return true
			elif contents == "purified_water":
				if ic: ic.swap_equipped_item_after_use(PURIFIED_MUG_SCENE)
				contents = ""
				if water_surface: water_surface.visible = false
				if ic: ic._show_interaction_text("Purified water collected! Now drink it.", 2.0)
				return true
			else:
				if ic: ic._show_interaction_text("Nothing ready to collect yet — boil first.", 2.0)
				return false

		"purification_tablet":
			if contents == "boiled_water":
				contents = "purified_water"
				_set_water(COLOR_PURIFIED)
				if ic: ic._show_interaction_text("Tablet dissolved! Water is safe. Use a mug to collect.", 3.0)
				return true
			else:
				if ic: ic._show_interaction_text("Boil the water first before adding the tablet!", 2.0)
				return false

		_:
			if ic: ic._show_interaction_text("Can't use that with the pot", 2.0)
			return false

func notify_fire_lit() -> void:
	if contents == "dirty_water" and not is_boiling:
		_start_cooking()

func _set_water(color: Color) -> void:
	if not water_surface: return
	water_surface.visible = true
	if not water_surface.material_override:
		var mat = StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		water_surface.material_override = mat
	water_surface.material_override.albedo_color = color

func _start_cooking() -> void:
	if not GameManager.fire_lit or contents != "dirty_water": return
	is_boiling = true
	boil_remaining = int(boil_time)
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic: ic._show_interaction_text("Boiling! %ds — look at the pot to check." % boil_remaining, 3.0)

	while boil_remaining > 0 and is_boiling:
		var progress = 1.0 - float(boil_remaining) / float(boil_time)
		var current_color: Color
		if progress < 0.5:
			current_color = COLOR_DIRTY.lerp(COLOR_HOT, progress * 2.0)
		else:
			current_color = COLOR_HOT.lerp(COLOR_BOILED, (progress - 0.5) * 2.0)
		_set_water(current_color)
		var ic2 = get_tree().get_first_node_in_group("interaction_controller")
		if ic2:
			ic2.interaction_textbox.text = "Boiling... %ds remaining (look at pot to check)" % boil_remaining
			ic2.interaction_textbox.visible = true
		await get_tree().create_timer(1.0).timeout
		boil_remaining -= 1

	is_boiling = false
	boil_remaining = 0
	contents = "boiled_water"
	_set_water(COLOR_BOILED)

	ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic: ic._show_interaction_text("Water boiled! Use a mug on the pot, or add a tablet to purify.", 5.0)
