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
var _sprite: Sprite2D

func _ready() -> void:
	add_to_group("player")
	stats.hp_changed.connect(_on_hp_changed)
	stats.died.connect(_on_died)
	_last_hp = stats.hp
	_setup_sprite()

func _setup_sprite() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = SpriteAssets.textures.get("player")
	_sprite.centered = true
	add_child(_sprite)
	# Remove old ColorRect if present
	var cr = get_node_or_null("ColorRect")
	if cr: cr.queue_free()

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * stats.speed
	if input_dir.x != 0:
		_facing_right = input_dir.x > 0
		_sprite.flip_h = not _facing_right
	move_and_slide()

func _process(delta: float) -> void:
	if stats.hp_regen > 0:
		stats.heal(stats.hp_regen * delta)
	if stats.invincible:
		_invincible_timer -= delta
		_flash_timer -= delta
		if _flash_timer <= 0:
			_sprite.visible = not _sprite.visible
			_flash_timer = 0.08
		if _invincible_timer <= 0:
			stats.invincible = false
			_sprite.visible = true
	# Aim sprite at nearest enemy
	var nearest = get_nearest_enemy()
	if nearest:
		_sprite.flip_h = nearest.global_position.x < global_position.x
	elif not _facing_right:
		_sprite.flip_h = true
	else:
		_sprite.flip_h = false

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

func _on_died() -> void:
	GameManager.change_state(GameManager.GameState.GAME_OVER)
	queue_free()
