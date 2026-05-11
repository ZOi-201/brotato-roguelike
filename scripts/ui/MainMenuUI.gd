class_name MainMenuUI
extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_style()
	var start_btn = $Panel/VBox/StartBtn
	start_btn.pressed.connect(func():
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.3)
		tween.finished.connect(func():
			visible = false
			modulate.a = 1.0
			GameManager.start_game()
		)
	)

func _style() -> void:
	var panel = $Panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	style.border_width_left = 2; style.border_width_right = 2
	style.border_width_top = 2; style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.4, 0.6)
	style.corner_radius_top_left = 12; style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12; style.corner_radius_bottom_right = 12
	style.content_margin_left = 32; style.content_margin_right = 32
	style.content_margin_top = 24; style.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel", style)
	var title = $Panel/VBox/Title
	title.add_theme_color_override("font_color", Color(0.3, 0.6, 1))
	title.add_theme_font_size_override("font_size", 32)
	var start_btn = $Panel/VBox/StartBtn
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.25, 0.45, 0.8)
	btn_style.corner_radius_top_left = 8; btn_style.corner_radius_top_right = 8
	btn_style.corner_radius_bottom_left = 8; btn_style.corner_radius_bottom_right = 8
	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.35, 0.55, 0.9)
	btn_hover.corner_radius_top_left = 8; btn_hover.corner_radius_top_right = 8
	btn_hover.corner_radius_bottom_left = 8; btn_hover.corner_radius_bottom_right = 8
	start_btn.add_theme_stylebox_override("normal", btn_style)
	start_btn.add_theme_stylebox_override("hover", btn_hover)
	start_btn.add_theme_color_override("font_color", Color.WHITE)
	start_btn.add_theme_font_size_override("font_size", 22)
