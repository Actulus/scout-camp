@tool
extends EditorScript

func _run() -> void:
	var theme = Theme.new()
	
	var font_heading = load("res://assets/fonts/AmaticSC-Bold.ttf")
	var font_body = load("res://assets/fonts/Nunito-Regular.ttf")
	var font_body_bold = load("res://assets/fonts/Nunito-Bold.ttf")
	
	# === PANEL ===
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#1C2E1A")
	panel_style.border_color = Color("#C68B3A")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(10)
	panel_style.content_margin_left = 16
	panel_style.content_margin_right = 16
	panel_style.content_margin_top = 12
	panel_style.content_margin_bottom = 12
	panel_style.shadow_color = Color(0, 0, 0, 0.4)
	panel_style.shadow_size = 8
	theme.set_stylebox("panel", "PanelContainer", panel_style)
	
	# === BUTTONS ===
	# normal state
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color("#4A7C3F")
	btn_normal.border_color = Color("#C68B3A")
	btn_normal.set_border_width_all(2)
	btn_normal.set_corner_radius_all(12)
	btn_normal.content_margin_left = 20
	btn_normal.content_margin_right = 20
	btn_normal.content_margin_top = 10
	btn_normal.content_margin_bottom = 10
	btn_normal.shadow_color = Color(0, 0, 0, 0.3)
	btn_normal.shadow_size = 4
	btn_normal.shadow_offset = Vector2(0, 3)
	
	# hover state
	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color("#6AAF5A")
	btn_hover.border_color = Color("#E8B84B")
	btn_hover.set_border_width_all(2)
	btn_hover.set_corner_radius_all(12)
	btn_hover.content_margin_left = 20
	btn_hover.content_margin_right = 20
	btn_hover.content_margin_top = 10
	btn_hover.content_margin_bottom = 10
	btn_hover.shadow_color = Color(0, 0, 0, 0.2)
	btn_hover.shadow_size = 6
	btn_hover.shadow_offset = Vector2(0, 4)
	
	# pressed state
	var btn_pressed = StyleBoxFlat.new()
	btn_pressed.bg_color = Color("#3A6030")
	btn_pressed.border_color = Color("#C68B3A")
	btn_pressed.set_border_width_all(2)
	btn_pressed.set_corner_radius_all(12)
	btn_pressed.content_margin_left = 20
	btn_pressed.content_margin_right = 20
	btn_pressed.content_margin_top = 12
	btn_pressed.content_margin_bottom = 8
	btn_pressed.shadow_color = Color(0, 0, 0, 0.1)
	btn_pressed.shadow_size = 2
	
	# disabled state
	var btn_disabled = StyleBoxFlat.new()
	btn_disabled.bg_color = Color("#2A3D28")
	btn_disabled.border_color = Color("#5A5A4A")
	btn_disabled.set_border_width_all(2)
	btn_disabled.set_corner_radius_all(12)
	btn_disabled.content_margin_left = 20
	btn_disabled.content_margin_right = 20
	btn_disabled.content_margin_top = 10
	btn_disabled.content_margin_bottom = 10
	
	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_stylebox("hover", "Button", btn_hover)
	theme.set_stylebox("pressed", "Button", btn_pressed)
	theme.set_stylebox("disabled", "Button", btn_disabled)
	theme.set_font("font", "Button", font_body_bold)
	theme.set_font_size("font_size", "Button", 16)
	theme.set_color("font_color", "Button", Color("#F5E6C8"))
	theme.set_color("font_hover_color", "Button", Color("#FFFFFF"))
	theme.set_color("font_pressed_color", "Button", Color("#E8B84B"))
	theme.set_color("font_disabled_color", "Button", Color("#6A6A5A"))
	
	# === LABELS ===
	theme.set_font("font", "Label", font_body)
	theme.set_font_size("font_size", "Label", 16)
	theme.set_color("font_color", "Label", Color("#F5E6C8"))
	
	# === RICH TEXT LABEL ===
	theme.set_font("normal_font", "RichTextLabel", font_body)
	theme.set_font("bold_font", "RichTextLabel", font_body_bold)
	theme.set_font("italics_font", "RichTextLabel", font_body)
	theme.set_font_size("normal_font_size", "RichTextLabel", 15)
	theme.set_font_size("bold_font_size", "RichTextLabel", 15)
	theme.set_color("default_color", "RichTextLabel", Color("#F5E6C8"))
	
	# === LINE EDIT ===
	var line_edit_style = StyleBoxFlat.new()
	line_edit_style.bg_color = Color("#0D1A0C")
	line_edit_style.border_color = Color("#C68B3A")
	line_edit_style.set_border_width_all(2)
	line_edit_style.set_corner_radius_all(6)
	line_edit_style.content_margin_left = 8
	line_edit_style.content_margin_right = 8
	line_edit_style.content_margin_top = 6
	line_edit_style.content_margin_bottom = 6
	theme.set_stylebox("normal", "LineEdit", line_edit_style)
	theme.set_color("font_color", "LineEdit", Color("#F5E6C8"))
	
	# === PROGRESS BAR ===
	var pb_bg = StyleBoxFlat.new()
	pb_bg.bg_color = Color("#0D1A0C")
	pb_bg.set_corner_radius_all(6)
	pb_bg.border_color = Color("#C68B3A")
	pb_bg.set_border_width_all(1)
	var pb_fill = StyleBoxFlat.new()
	pb_fill.bg_color = Color("#6AAF5A")
	pb_fill.set_corner_radius_all(5)
	theme.set_stylebox("background", "ProgressBar", pb_bg)
	theme.set_stylebox("fill", "ProgressBar", pb_fill)
	
	# === SLIDER ===
	var slider_style = StyleBoxFlat.new()
	slider_style.bg_color = Color("#0D1A0C")
	slider_style.set_corner_radius_all(4)
	slider_style.border_color = Color("#C68B3A")
	slider_style.set_border_width_all(1)
	theme.set_stylebox("slider", "HSlider", slider_style)
	
	var slider_fill = StyleBoxFlat.new()
	slider_fill.bg_color = Color("#6AAF5A")
	slider_fill.set_corner_radius_all(4)

	theme.set_stylebox("slider", "HSlider", slider_style)
	theme.set_stylebox("grabber_area", "HSlider", slider_fill)
	theme.set_stylebox("grabber_area_highlight", "HSlider", slider_fill)
	
	# GRABBER (the draggable circle)
	var grabber_icon = StyleBoxFlat.new()
	grabber_icon.bg_color = Color("#E8B84B")
	grabber_icon.set_corner_radius_all(8)
	grabber_icon.set_border_width_all(2)
	grabber_icon.border_color = Color("#C68B3A")

	theme.set_icon("grabber", "HSlider", _make_grabber_texture())
	theme.set_constant("grabber_offset", "HSlider", 0)
	
	# === OPTION BUTTON ===
	theme.set_stylebox("normal", "OptionButton", btn_normal)
	theme.set_stylebox("hover", "OptionButton", btn_hover)
	theme.set_stylebox("pressed", "OptionButton", btn_pressed)
	theme.set_color("font_color", "OptionButton", Color("#F5E6C8"))
	theme.set_font("font", "OptionButton", font_body)
	
	# === POPUP MENU (dropdown) ===
	var popup_style = StyleBoxFlat.new()
	popup_style.bg_color = Color("#1C2E1A")
	popup_style.border_color = Color("#C68B3A")
	popup_style.set_border_width_all(2)
	popup_style.set_corner_radius_all(8)
	theme.set_stylebox("panel", "PopupMenu", popup_style)
	theme.set_color("font_color", "PopupMenu", Color("#F5E6C8"))
	theme.set_font("font", "PopupMenu", font_body)
	
	# === SCROLL CONTAINER ===
	var scroll_style = StyleBoxEmpty.new()
	theme.set_stylebox("panel", "ScrollContainer", scroll_style)
	
	# save
	ResourceSaver.save(theme, "res://assets/ui_theme/forest_lodge_theme.tres")
	print("Theme saved successfully!")

func _make_grabber_texture() -> ImageTexture:
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color("#E8B84B"))
	return ImageTexture.create_from_image(img)
