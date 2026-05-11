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

func _on_state_changed(state: GameManager.GameState) -> void:
	if state == GameManager.GameState.GAME_OVER:
		visible = true
		var player = get_tree().get_first_node_in_group("player")
		if GameManager.current_wave >= 20:
			title_label.text = "VICTORY!"
		else:
			title_label.text = "DEFEAT"
		stats_label.text = "Waves: %d\nKills: %d\nMaterials: %d" % [
			GameManager.current_wave, GameManager.total_kills,
			player.stats.materials if player else 0
		]

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
