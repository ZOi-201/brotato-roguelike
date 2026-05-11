class_name GameOverUI
extends CanvasLayer

@onready var title_label: Label = $Panel/VBox/Title
@onready var stats_label: Label = $Panel/VBox/Stats
@onready var restart_btn: Button = $Panel/VBox/RestartBtn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.game_state_changed.connect(_on_state_changed)
	restart_btn.pressed.connect(_on_restart_pressed)
	visible = false
	_style()

func _style() -> void:
	var panel = $Panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	style.border_width_left = 2; style.border_width_right = 2
	style.border_width_top = 2; style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.4, 0.6)
	style.corner_radius_top_left = 12; style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12; style.corner_radius_bottom_right = 12
	style.content_margin_left = 24; style.content_margin_right = 24
	style.content_margin_top = 16; style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	title_label.add_theme_font_size_override("font_size", 36)
	stats_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	stats_label.add_theme_font_size_override("font_size", 18)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.25, 0.45, 0.8)
	btn_style.corner_radius_top_left = 8; btn_style.corner_radius_top_right = 8
	btn_style.corner_radius_bottom_left = 8; btn_style.corner_radius_bottom_right = 8
	restart_btn.add_theme_stylebox_override("normal", btn_style)
	restart_btn.add_theme_color_override("font_color", Color.WHITE)
	restart_btn.add_theme_font_size_override("font_size", 20)

func _on_state_changed(state: GameManager.GameState) -> void:
	if state == GameManager.GameState.GAME_OVER:
		visible = true
		var player = get_tree().get_first_node_in_group("player")
		if GameManager.current_wave >= 20:
			title_label.text = "VICTORY!"
			title_label.add_theme_color_override("font_color", Color(0.3, 1, 0.4))
		else:
			title_label.text = "DEFEAT"
			title_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		stats_label.text = "Waves: %d\nKills: %d\nMaterials: %d" % [
			GameManager.current_wave, GameManager.total_kills,
			player.stats.materials if player else 0
		]
		modulate.a = 0
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.3)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
