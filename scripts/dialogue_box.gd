extends CanvasLayer

@onready var dialogue_text = $Control/Panel/DialogueText
@onready var npc_name_label = $Control/Panel/NPCName
@onready var continue_btn = $Control/Panel/ContinueBtn

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	continue_btn.pressed.connect(hide)
	
func show_dialogue(name: String, text: String):
	npc_name_label.text = name
	dialogue_text.text = text
	show()
