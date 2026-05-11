extends BaseEnemy

func _draw_enemy_shape() -> void:
	var s = enemy_data.size
	var c = enemy_data.color
	draw_rect(Rect2(-s, -s, s * 2, s * 2), c)
	draw_rect(Rect2(s * 0.5, -3, s, 6), c.lightened(0.2))
	draw_rect(Rect2(-s * 0.7, -s * 0.7, s * 1.4, s * 1.4), Color.WHITE, false, 1.0)
	draw_line(Vector2(-s * 0.4, 0), Vector2(s * 0.4, 0), Color.BLACK, 1)
	draw_line(Vector2(0, -s * 0.4), Vector2(0, s * 0.4), Color.BLACK, 1)

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
