extends BaseEnemy

func _get_sprite_key() -> String:
	return "ranged"

var shoot_cooldown: float = 0.0
var preferred_distance: float = 200.0
var _telegraph_shoot: bool = false
var _telegraph_shoot_timer: float = 0.0

func _move_toward_player(_delta: float) -> void:
	var dist = global_position.distance_to(player.global_position)
	if dist > preferred_distance + 50:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * enemy_data.speed
	elif dist < preferred_distance - 50:
		var direction = (global_position - player.global_position).normalized()
		velocity = direction * enemy_data.speed * 0.7
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func _process(delta: float) -> void:
	if not player:
		return
	if _telegraph_shoot:
		_telegraph_shoot_timer -= delta
		if _telegraph_shoot_timer <= 0:
			_telegraph_shoot = false
			_sprite.modulate = Color(1, 1, 1, 1)
			_do_shoot()
		return
	shoot_cooldown -= delta
	if shoot_cooldown <= 0:
		_telegraph_shoot = true
		_telegraph_shoot_timer = 0.4
		_sprite.modulate = Color(2, 0.3, 0.3)
		shoot_cooldown = 2.0

func _do_shoot() -> void:
	var bullet = preload("res://scenes/projectiles/Bullet.tscn").instantiate()
	bullet.global_position = global_position
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.speed = 250.0
	bullet.damage = enemy_data.damage
	bullet.color = Color(1, 0.2, 0.5)
	bullet.piercing = false
	bullet.bounces = 0
	bullet.scale = Vector2(2.5, 2.5)
	get_tree().current_scene.add_child(bullet)
