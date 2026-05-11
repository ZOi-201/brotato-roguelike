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
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.stats.hp_changed.connect(_on_hp_changed)
		player.stats.died.connect(_on_player_died)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.wave_timer_changed.connect(_on_wave_timer)
	GameManager.game_state_changed.connect(_on_state_changed)

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

func _on_wave_changed(wave: int) -> void:
	wave_label.text = "Wave: %d/20" % wave

func _on_wave_timer(time_left: float) -> void:
	timer_label.text = "%d s" % int(time_left)

func _on_state_changed(state: GameManager.GameState) -> void:
	visible = (state == GameManager.GameState.PLAYING)

func _on_player_died() -> void:
	pass
