extends Node

var body: FontFile
var body_bold: FontFile
var heading: FontFile

func _ready() -> void:
	# update path to match your actual font location
	var dir = DirAccess.open("res://assets/fonts/")
	
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			print("Font file found: ", file)
			file = dir.get_next()
	
	body = _try_load(["res://assets/fonts/Nunito/static/Nunito-Regular.ttf"])
	body_bold = _try_load(["res://assets/fonts/Nunito/static/Nunito-Bold.ttf"])
	heading = _try_load(["res://assets/fonts/Nunito/static/Nunito-Bold.ttf"])
	
	print("UIFonts body: ", body)
	print("UIFonts body_bold: ", body_bold)

func _try_load(paths: Array) -> FontFile:
	for path in paths:
		if ResourceLoader.exists(path):
			return load(path)
	push_error("UIFonts: could not find font at any of: " + str(paths))
	return null
