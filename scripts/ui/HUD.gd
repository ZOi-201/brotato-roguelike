# scripts/ui/HUD.gd
class_name HUD
extends CanvasLayer

@onready var hp_bar: ProgressBar = $Panel/HBox/HPBar
@onready var hp_label: Label = $Panel/HBox/HPBar/HP_Label
@onready var xp_bar: ProgressBar = $Panel/HBox/XPBar
@onready var wave_label: Label = $Panel/HBox/WaveLabel
@onready var timer_label: Label = $Panel/HBox/TimerLabel
@onready var material_label: Label = $Panel/HBox/MaterialLabel
@onready var kill_label: Label = $Panel/HBox/KillLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_style_panel()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.stats.hp_changed.connect(_on_hp_changed)
		player.stats.died.connect(_on_player_died)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.wave_timer_changed.connect(_on_wave_timer)
	GameManager.game_state_changed.connect(_on_state_changed)

func _style_panel() -> void:
	var panel = $Panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.08, 0.85)
	style.border_width_left = 0; style.border_width_right = 0
	style.border_width_top = 0; style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.3, 0.5)
	style.content_margin_left = 12; style.content_margin_right = 12
	style.content_margin_top = 4; style.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", style)
	# Label styling
	for label in [$Panel/HBox/WaveLabel, $Panel/HBox/TimerLabel, $Panel/HBox/MaterialLabel, $Panel/HBox/KillLabel]:
		label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		label.add_theme_font_size_override("font_size", 16)
	material_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2))

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	xp_bar.max_value = player.stats.xp_to_next
	xp_bar.value = player.stats.xp
	material_label.text = "Mat: %d" % player.stats.materials
	kill_label.text = "Kills: %d" % GameManager.total_kills

func _on_hp_changed(current: float, max_hp: float) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current
	hp_label.text = "%d / %d" % [int(current), int(max_hp)]
	var ratio = current / max_hp
	var c = Color.RED if ratio > 0.5 else Color.ORANGE_RED if ratio > 0.25 else Color.DARK_RED
	hp_bar.add_theme_color_override("font_color", c)

func _on_wave_changed(wave: int) -> void:
	wave_label.text = "Wave: %d/20" % wave

func _on_wave_timer(time_left: float) -> void:
	timer_label.text = "%ds" % int(time_left)
	timer_label.add_theme_color_override("font_color", Color.RED if time_left <= 5 else Color(0.9, 0.9, 0.9))

func _on_state_changed(state: GameManager.GameState) -> void:
	visible = (state == GameManager.GameState.PLAYING)

func _on_player_died() -> void:
	pass
