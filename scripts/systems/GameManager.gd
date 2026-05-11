# scripts/systems/GameManager.gd
extends Node

enum GameState { MENU, PLAYING, PAUSED, SHOP, LEVEL_UP, GAME_OVER }

signal wave_changed(wave: int)
signal wave_timer_changed(time_left: float)
signal game_state_changed(state: GameState)
signal enemy_killed(enemy_data: EnemyData, position: Vector2, is_elite: bool, is_boss: bool)

var current_state: GameState = GameState.MENU
var current_wave: int = 1
var wave_timer: float = 0.0
var wave_duration: float = 0.0
var enemies_to_spawn: int = 0
var enemies_spawned: int = 0
var spawn_timer: float = 0.0
var spawn_interval: float = 1.5
var arena_size: Vector2 = Vector2(1024, 768)
var total_kills: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if current_state != GameState.PLAYING:
		return
	wave_timer -= delta
	wave_timer_changed.emit(wave_timer)
	if wave_timer <= 0:
		if current_wave >= 20:
			end_wave()
		else:
			end_wave()

func start_game() -> void:
	current_wave = 1
	total_kills = 0
	change_state(GameState.PLAYING)
	start_wave()

func start_wave() -> void:
	wave_duration = 20.0 + current_wave * 2.0
	wave_timer = wave_duration
	enemies_to_spawn = 8 + current_wave * 2
	enemies_spawned = 0
	spawn_interval = maxf(0.3, 1.5 - current_wave * 0.05)
	spawn_timer = 0.0
	wave_changed.emit(current_wave)

func end_wave() -> void:
	if current_wave >= 20:
		change_state(GameState.GAME_OVER)
		return
	change_state(GameState.SHOP)
	current_wave += 1

func start_next_wave() -> void:
	change_state(GameState.PLAYING)
	start_wave()

func change_state(new_state: GameState) -> void:
	current_state = new_state
	game_state_changed.emit(new_state)
	if new_state == GameState.PLAYING:
		get_tree().paused = false
	else:
		get_tree().paused = true

func on_enemy_killed(enemy: BaseEnemy) -> void:
	total_kills += 1
	enemy_killed.emit(enemy.enemy_data, enemy.global_position,
			enemy.enemy_data.is_elite, enemy.enemy_data.is_boss)

func get_random_spawn_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	var center = player.global_position if player else Vector2(512, 384)
	var angle = randf() * TAU
	var distance = randf_range(300, 500)
	return center + Vector2.RIGHT.rotated(angle) * distance
