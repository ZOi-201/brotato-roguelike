extends BaseEnemy

var shoot_cooldown: float = 0.0
var preferred_distance: float = 200.0

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
	shoot_cooldown -= delta
	if shoot_cooldown <= 0:
		shoot_cooldown = 2.0
		var bullet = preload("res://scenes/projectiles/Bullet.tscn").instantiate()
		bullet.global_position = global_position
		bullet.direction = (player.global_position - global_position).normalized()
		bullet.speed = 200.0
		bullet.damage = enemy_data.damage
		bullet.color = Color.PURPLE
		bullet.piercing = false
		bullet.bounces = 0
		get_tree().current_scene.add_child(bullet)
