# scripts/player/Player.gd
class_name Player
extends CharacterBody2D

@export var stats: PlayerStats

var weapons: Array[BaseWeapon] = []
var items: Array[ItemData] = []
var _last_hp: float
var _invincible_timer: float = 0.0
var _flash_timer: float = 0.08
var _facing_right: bool = true

func _ready() -> void:
	add_to_group("player")
	stats.hp_changed.connect(_on_hp_changed)
	stats.died.connect(_on_died)
	_last_hp = stats.hp
	for child in get_children():
		if child is ColorRect:
			child.queue_free()
	queue_redraw()

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * stats.speed
	if input_dir.x != 0:
		_facing_right = input_dir.x > 0
	move_and_slide()

func _process(delta: float) -> void:
	if stats.hp_regen > 0:
		stats.heal(stats.hp_regen * delta)
	if stats.invincible:
		_invincible_timer -= delta
		_flash_timer -= delta
		if _flash_timer <= 0:
			visible = not visible
			_flash_timer = 0.08
		if _invincible_timer <= 0:
			stats.invincible = false
			visible = true

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

func _on_hp_changed(current: float, _max_hp: float) -> void:
	if current < _last_hp:
		_start_invincibility()
		_trigger_camera_shake()
	_last_hp = current

func _start_invincibility() -> void:
	stats.invincible = true
	_invincible_timer = 0.5
	_flash_timer = 0.08

func _trigger_camera_shake() -> void:
	var main = get_parent()
	if main.has_method("camera_shake"):
		main.camera_shake()

func _draw() -> void:
	var gun_offset_x = 14 if _facing_right else -14
	# Body
	draw_circle(Vector2.ZERO, 14, Color(0.27, 0.53, 1))
	draw_circle(Vector2(0, 3), 10, Color(0.4, 0.65, 1))
	# Eyes
	draw_circle(Vector2(-4, -4), 3, Color.WHITE)
	draw_circle(Vector2(4, -4), 3, Color.WHITE)
	var pupil_dir = 1 if _facing_right else -1
	draw_circle(Vector2(-4 + pupil_dir, -4), 1.5, Color.BLACK)
	draw_circle(Vector2(4 + pupil_dir, -4), 1.5, Color.BLACK)
	# Gun
	draw_rect(Rect2(gun_offset_x - (2 if _facing_right else -8), -3, 10, 5), Color(0.8, 0.8, 0.8))
	draw_circle(Vector2(gun_offset_x + (8 if _facing_right else -6), -0.5), 2, Color.WHITE, false, 1)

func _on_died() -> void:
	GameManager.change_state(GameManager.GameState.GAME_OVER)
	queue_free()
