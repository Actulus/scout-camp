extends CanvasLayer
class_name PageBookUI

@export var page_turn_sound: AudioStream = preload("res://assets/audio/book_flip_kenney_cards.wav")

@onready var book_title: Label = %BookTitle
@onready var page_title: Label = %PageTitle
@onready var page_content: RichTextLabel = %PageContent
@onready var page_counter: Label = %PageCounter
@onready var prev_btn: Button = %PrevButton
@onready var next_btn: Button = %NextButton
@onready var close_btn: Button = %CloseButton

var pages: Array = []
var current_page: int = 0

signal closed

func _ready() -> void:
	add_to_group("page_book")
	SoundManager.play_sfx(page_turn_sound)
	close_btn.pressed.connect(func(): _close())
	prev_btn.pressed.connect(func(): _navigate(-1))
	next_btn.pressed.connect(func(): _navigate(1))
	
	var player = get_tree().get_first_node_in_group("player")
	if player: player.ui_open = true
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic.set_process(false)
		ic.set_physics_process(false)
	
	await get_tree().process_frame
	await get_tree().process_frame
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func setup(title: String, book_pages: Array) -> void:
	book_title.text = title
	pages = book_pages
	_show_page(0)

func _show_page(index: int) -> void:
	current_page = index
	var page = pages[index]
	
	page_title.text = page.title
	page_content.parse_bbcode(page.content)
	page_counter.text = "Page %d of %d" % [index + 1, pages.size()]
	
	prev_btn.disabled = index == 0
	next_btn.disabled = index == pages.size() - 1

func _navigate(direction: int) -> void:
	var new_index = clamp(current_page + direction, 0, pages.size() - 1)
	if new_index != current_page:
		SoundManager.play_sfx(page_turn_sound)
	_show_page(new_index)

func _close() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player: player.ui_open = false
	var ic = get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic.set_process(true)
		ic.set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("closed")
	queue_free()

func _input(event: InputEvent) -> void:
	if not visible: return
	
	if event is InputEventKey and event.keycode == KEY_TAB:
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("book_next") or event.is_action_pressed("ui_right"):
		_navigate(1)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("book_prev") or event.is_action_pressed("ui_left"):
		_navigate(-1)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
		return
	for action in ["move_forward", "move_backward", "move_left",
				   "move_right", "jump", "sprint", "crouch"]:
		if event.is_action(action):
			get_viewport().set_input_as_handled()
			return
