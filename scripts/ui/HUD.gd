# scripts/ui/HUD.gd - Redesigned HUD
# Layout: left(HP+icon) | center(wave+timer) | right(XP+kills+gold)
class_name HUD
extends CanvasLayer

@onready var hp_bar: ProgressBar = $Panel/Left/HPBar
@onready var hp_label: Label = $Panel/Left/HPBar/HP_Label
@onready var xp_bar: ProgressBar = $Panel/Right/XPBar
@onready var wave_label: Label = $Panel/Center/WaveLabel
@onready var timer_label: Label = $Panel/Center/TimerLabel
@onready var material_label: Label = $Panel/Right/GoldLabel
@onready var kill_label: Label = $Panel/Right/KillLabel
@onready var panel: Panel = $Panel
@onready var left_section: HBoxContainer = $Panel/Left
@onready var center_section: VBoxContainer = $Panel/Center
@onready var right_section: HBoxContainer = $Panel/Right

var _target_hp: float = 100.0
var _target_xp: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_apply_theme()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.stats.hp_changed.connect(_on_hp_changed)
		player.stats.died.connect(_on_player_died)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.wave_timer_changed.connect(_on_wave_timer)
	GameManager.game_state_changed.connect(_on_state_changed)

func _apply_theme() -> void:
	# Dark panel background
	var ps = StyleBoxFlat.new()
	ps.bg_color = Color(0.04, 0.04, 0.06, 0.88)
	ps.border_width_bottom = 2
	ps.border_color = Color(0.25, 0.25, 0.4)
	ps.content_margin_left = 16; ps.content_margin_right = 16
	ps.content_margin_top = 6; ps.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", ps)

	# HP bar styling
	hp_bar.add_theme_color_override("font_color", Color.WHITE)
	hp_label.add_theme_color_override("font_color", Color.WHITE)
	hp_label.add_theme_font_size_override("font_size", 14)

	# Center labels
	for lbl in [wave_label, timer_label]:
		lbl.add_theme_font_size_override("font_size", 16)
		lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	wave_label.add_theme_font_size_override("font_size", 17)

	# Right labels
	material_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	material_label.add_theme_font_size_override("font_size", 15)
	kill_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	kill_label.add_theme_font_size_override("font_size", 14)
	xp_bar.add_theme_color_override("font_color", Color(0.5, 1, 0.5))

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	# Smooth HP bar
	hp_bar.value = lerpf(hp_bar.value, _target_hp, 0.2)
	# XP bar
	xp_bar.max_value = player.stats.xp_to_next
	xp_bar.value = lerpf(xp_bar.value, player.stats.xp, 0.15)
	material_label.text = "金币 %d" % player.stats.materials
	kill_label.text = "击杀 %d" % GameManager.total_kills

func _on_hp_changed(current: float, max_hp: float) -> void:
	_target_hp = current
	hp_bar.max_value = max_hp
	hp_label.text = "%d/%d" % [int(current), int(max_hp)]

func _on_wave_changed(wave: int) -> void:
	wave_label.text = "波 %d/20" % wave

func _on_wave_timer(time_left: float) -> void:
	timer_label.text = "%d 秒" % int(time_left)
	timer_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3) if time_left <= 5 else Color(0.85, 0.85, 0.85))

func _on_state_changed(state: GameManager.GameState) -> void:
	if state == GameManager.GameState.PLAYING:
		visible = true
		$Panel.modulate.a = 0
		var tween = create_tween()
		tween.tween_property($Panel, "modulate:a", 1.0, 0.25)
	else:
		var tween = create_tween()
		tween.tween_property($Panel, "modulate:a", 0.0, 0.15)
		tween.tween_callback(func(): visible = false)

func _on_player_died() -> void:
	pass
