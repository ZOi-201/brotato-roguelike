extends BaseEnemy

func _draw_enemy_shape() -> void:
	var s = enemy_data.size
	var c = enemy_data.color
	var pts = PackedVector2Array([
		Vector2(s, 0), Vector2(-s, -s * 0.7), Vector2(-s * 0.5, 0), Vector2(-s, s * 0.7)
	])
	draw_colored_polygon(pts, c)
	draw_circle(Vector2(s * 0.2, -2), 1.5, Color.WHITE)
	draw_circle(Vector2(s * 0.2, 2), 1.5, Color.WHITE)

func _move_toward_player(_delta: float) -> void:
	var dist = global_position.distance_to(player.global_position)
	var effective_speed = enemy_data.speed
	if dist > 200:
		effective_speed = enemy_data.speed * 2.5
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * effective_speed
	move_and_slide()
