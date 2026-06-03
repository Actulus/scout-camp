extends AbstractInteraction
class_name SaveInteraction

func _ready() -> void:
	super._ready()
	add_to_group("save_interaction")

func pre_interact() -> void:
	super.pre_interact()
	SaveSystem.save()

	var ic := get_tree().get_first_node_in_group("interaction_controller")
	if ic:
		ic._show_interaction_text("Game Saved — Day %d" % GameManager.current_day, 2.5)

	# One-shot: end the interaction immediately so the player doesn't stay "locked"
	post_interact()
