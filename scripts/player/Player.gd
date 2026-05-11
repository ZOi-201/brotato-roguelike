# scripts/player/Player.gd
class_name Player
extends CharacterBody2D

@export var stats: PlayerStats

var weapons: Array[BaseWeapon] = []
var items: Array[ItemData] = []

func _ready() -> void:
	add_to_group("player")
	stats.hp_changed.connect(_on_hp_changed)
	stats.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * stats.speed
	move_and_slide()

func _process(delta: float) -> void:
	if stats.hp_regen > 0:
		stats.heal(stats.hp_regen * delta)

func add_weapon(weapon: BaseWeapon) -> void:
	if weapons.size() >= 6:
		return
	weapons.append(weapon)
	add_child(weapon)

func get_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
	var nearest: Node2D = null
	var nearest_dist = INF
	for enemy in enemies:
		var dist = global_position.distance_squared_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest

func _on_hp_changed(_current: float, _max_hp: float) -> void:
	pass

func _on_died() -> void:
	GameManager.change_state(GameManager.GameState.GAME_OVER)
	queue_free()
