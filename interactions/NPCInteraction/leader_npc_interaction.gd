class_name LeaderNPCInteraction
extends AbstractInteraction

@export var npc_name: String = "Scout"
@export var dialogue_lines: Array[String] = []
@export var is_leader: bool = false
@export var idle_animation: String = "RootAction"
@export var wave_animation: String = "Wave"

@onready var anim_player: AnimationPlayer = $"../scout_leader_char_anim/AnimationPlayer"

var _met_before: bool = false

func _ready() -> void:
	super()
	await get_tree().process_frame
	if anim_player:
		if anim_player.has_animation(idle_animation):
			var anim = anim_player.get_animation(idle_animation)
			if anim:
				anim.loop_mode = Animation.LOOP_LINEAR
			anim_player.play(idle_animation)
		else:
			push_warning("LeaderNPC: idle animation '%s' not found. Available: %s" % [idle_animation, str(anim_player.get_animation_list())])
	else:
		push_error("AnimationPlayer not found at ../scout_leader_char_anim/AnimationPlayer")

func pre_interact() -> void:
	super()
	can_interact = false
	_play_wave()
	_get_dialogue_ui().open(npc_name, _build_lines(), _on_dialogue_closed)

func _play_wave() -> void:
	if not anim_player:
		return
	if anim_player.has_animation(wave_animation):
		anim_player.play(wave_animation)
		if not anim_player.animation_finished.is_connected(_on_wave_finished):
			anim_player.animation_finished.connect(_on_wave_finished, CONNECT_ONE_SHOT)
	# if the wave animation doesn't exist yet, stay on idle

func interact() -> void:
	pass

func post_interact() -> void:
	pass  # dialogue UI owns its own lifetime; don't close on look-away

func _on_wave_finished(_anim_name: String) -> void:
	if anim_player and anim_player.has_animation(idle_animation):
		anim_player.play(idle_animation)

func _on_dialogue_closed() -> void:
	is_interacting = false
	can_interact = true
	_met_before = true
	if anim_player and anim_player.has_animation(idle_animation):
		anim_player.play(idle_animation)

func _build_lines() -> Array[String]:
	if is_leader:
		return _leader_lines()
	return dialogue_lines

func _leader_lines() -> Array[String]:
	var done: Dictionary = GameManager.skills_completed
	var all_done := true
	for v in done.values():
		if not v:
			all_done = false
			break

	var advice: String
	if all_done:
		advice = "Outstanding work, Scout! You've mastered all five wilderness skills. You're ready for anything."
	elif not done.get("fire", false):
		advice = "Start by lighting the fire pit — you'll find wood scattered near the trees."
	elif not done.get("water", false):
		advice = "Good work on the fire! Now try boiling water — grab the bucket from camp and head to the river."
	elif not done.get("shelter", false):
		advice = "Nice work! Now set up your tent — the poles and canvas are near the camp."
	elif not done.get("plants", false):
		advice = "Excellent! The field guide in the camp house will help you identify plants safely."
	else:
		advice = "Almost there! Find the three map pages hidden in the forest to finish your navigation training."

	if _met_before:
		return [advice]
	return ["Welcome to the Camp! " + advice]

func _get_dialogue_ui() -> CanvasLayer:
	var existing := get_tree().get_first_node_in_group("dialogue_ui")
	if existing:
		return existing as CanvasLayer
	var ui = load("res://scenes/ui/dialogue_ui.tscn").instantiate()
	get_tree().root.add_child(ui)
	return ui
