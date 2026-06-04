extends CanvasLayer
class_name FieldGuideUI

enum GuideType { PLANTS, ANIMALS }

@export var guide_type: GuideType = GuideType.PLANTS
@export var entries: Array = []
@export var guide_title: String = "Field Guide"
@export var page_turn_sound: AudioStream = preload("res://assets/audio/book_flip_kenney_cards.wav")

@onready var tab_bar: HBoxContainer = %TabBar
@onready var guide_title_ui: Label = %GuideTitle
@onready var entry_image: TextureRect = %EntryImage
@onready var safety_badge: PanelContainer = %SafetyBadge
@onready var safety_label: Label = %SafetyLabel
@onready var entry_title: Label = %EntryTitle
@onready var entry_subtitle: Label = %EntrySubtitle
@onready var entry_description: Label = %EntryDescription
@onready var action_btn: Button = %ActionButton
@onready var close_btn: Button = %CloseButton

var current_index: int = 0
var tab_buttons: Array = []

signal closed
signal quiz_requested

func _ready() -> void:
	add_to_group("field_guide")
	SoundManager.play_sfx(page_turn_sound)
	var player = get_tree().get_first_node_in_group("player")
	if player: player.ui_open = true

	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic.set_process(false)
		ic.set_physics_process(false)

	var hud = get_tree().get_first_node_in_group("hud_hints")
	if hud: hud.set_context("reading")

	action_btn.pressed.connect(_on_action_btn)
	close_btn.pressed.connect(func(): _close())

	# force mouse visible after 3 frames
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _build_tabs() -> void:
	# clear existing tabs
	for child in tab_bar.get_children():
		child.queue_free()
	tab_buttons.clear()
	
	for i in entries.size():
		var entry = entries[i]
		var tab = Button.new()
		tab.text = entry.display_name.split(" ")[0]  # first word only
		tab.focus_mode = Control.FOCUS_ALL
		tab.custom_minimum_size = Vector2(80, 36)
		
		var normal = StyleBoxFlat.new()
		normal.bg_color = Color("#1C2E1A")
		normal.border_color = Color("#C68B3A")
		normal.set_border_width_all(1)
		normal.set_corner_radius_all(6)
		normal.corner_radius_bottom_left = 0
		normal.corner_radius_bottom_right = 0
		tab.add_theme_stylebox_override("normal", normal)
		tab.add_theme_color_override("font_color", Color("#B8A882"))
		
		var idx = i
		tab.pressed.connect(func(): _show_entry(idx))
		tab_bar.add_child(tab)
		tab_buttons.append(tab)

func _show_entry(index: int) -> void:
	current_index = index
	var entry = entries[index]
	SoundManager.play_sfx(page_turn_sound)

	# update tab styles
	for i in tab_buttons.size():
		var active_style = StyleBoxFlat.new()
		if i == index:
			active_style.bg_color = Color("#4A7C3F")
			active_style.border_color = Color("#E8B84B")
			tab_buttons[i].add_theme_color_override("font_color", Color("#F5E6C8"))
		else:
			active_style.bg_color = Color("#1C2E1A")
			active_style.border_color = Color("#C68B3A")
			tab_buttons[i].add_theme_color_override("font_color", Color("#B8A882"))
		active_style.set_border_width_all(1)
		active_style.set_corner_radius_all(6)
		active_style.corner_radius_bottom_left = 0
		active_style.corner_radius_bottom_right = 0
		tab_buttons[i].add_theme_stylebox_override("normal", active_style)
	
	# update image
	if entry.image:
		entry_image.texture = entry.image
	else:
		entry_image.texture = null
	
		
	entry_image.custom_minimum_size = Vector2(200, 220)
	entry_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	entry_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	entry_description.custom_minimum_size = Vector2(0, 120)
	entry_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	
	# update text
	entry_title.text = entry.display_name
	
	# subtitle differs per guide type
	if entry is PlantInfo:
		entry_subtitle.text = ""
		entry_description.text = entry.visual_clue + "\n\n" + entry.real_world_fact
		_setup_plant_safety(entry)
		action_btn.text = "📋 Take Plant Quiz"
		action_btn.visible = true
	elif entry is AnimalInfo:
		entry_subtitle.text = entry.latin_name
		entry_description.text = entry.description + "\n\nHabitat: " + entry.habitat
		_setup_animal_safety(entry)
		action_btn.text = "📋 Take Animal Quiz"
		action_btn.visible = true

func setup() -> void:
	guide_title_ui.text = guide_title
	_build_tabs()
	if entries.size() > 0:
		_show_entry(0)
	action_btn.grab_focus()

func _setup_plant_safety(entry: PlantInfo) -> void:
	safety_badge.visible = true
	var style = StyleBoxFlat.new()
	if entry.is_safe:
		style.bg_color = Color("#2E7D32")
		safety_label.text = "✓ Edible"
		safety_label.add_theme_color_override("font_color", Color("#B9F6CA"))
	else:
		style.bg_color = Color("#C62828")
		safety_label.text = "✕ Poisonous"
		safety_label.add_theme_color_override("font_color", Color("#FFCDD2"))
	style.set_corner_radius_all(6)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	safety_badge.add_theme_stylebox_override("panel", style)

func _setup_animal_safety(entry: AnimalInfo) -> void:
	safety_badge.visible = true
	var style = StyleBoxFlat.new()
	if entry.is_dangerous:
		style.bg_color = Color("#C62828")
		safety_label.text = "⚠ Dangerous"
		safety_label.add_theme_color_override("font_color", Color("#FFCDD2"))
	else:
		style.bg_color = Color("#1565C0")
		safety_label.text = "● " + entry.rarity
		safety_label.add_theme_color_override("font_color", Color("#BBDEFB"))
	style.set_corner_radius_all(6)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	safety_badge.add_theme_stylebox_override("panel", style)

func _on_action_btn() -> void:
	if entries[current_index] is PlantInfo:
		emit_signal("quiz_requested")
		_close()
	if entries[current_index] is AnimalInfo:
		emit_signal("quiz_requested")
		_close()

func _close() -> void:
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic.set_process(true)
		ic.set_physics_process(true)
	var hud = get_tree().get_first_node_in_group("hud_hints")
	if hud: hud.set_context("default")
	var player = get_tree().get_first_node_in_group("player")
	if player: player.ui_open = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("closed")
	queue_free()

func _input(event: InputEvent) -> void:
	if not visible: return
	
	# next/previous tab with E/Q
	if event.is_action_pressed("book_next"):
		_show_entry(min(current_index + 1, entries.size() - 1))
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("book_prev"):
		_show_entry(max(current_index - 1, 0))
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()
		return
	
	# block player movement
	if event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
		return
	for action in ["move_forward", "move_backward", "move_left",
				   "move_right", "jump", "sprint", "crouch"]:
		if event.is_action(action) and not event.is_action("ui_up") \
		   and not event.is_action("ui_down"):
			get_viewport().set_input_as_handled()
			return
