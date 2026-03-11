extends Area3D

var current_target = null
var prompt_label: Label

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	await get_tree().process_frame
	prompt_label = get_tree().root.get_node_or_null("World/HUD/Control/InteractPrompt")
	print("Prompt label found: ", prompt_label)

func _on_body_entered(body):
	print("Body entered: ", body.name, " — has interact: ", body.has_method("interact"))
	if body.has_method("interact"):
		current_target = body
		if prompt_label:
			if "display_name" in body: 
				prompt_label.text = "Press E  —  " + current_target.display_name
			else: 
				prompt_label.text = "Press E to talk"
			prompt_label.show()
		
func _on_body_exited(body):
	if body == current_target:
		current_target = null
		if prompt_label:
			prompt_label.hide()
			
func _input(event):
	if event.is_action_pressed("ui_accept") and current_target:
		current_target.interact(get_parent())
		if prompt_label:
			prompt_label.hide()
