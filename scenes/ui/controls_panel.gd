extends PanelContainer

func _ready() -> void:
	%BackButton.pressed.connect(func(): visible = false)
