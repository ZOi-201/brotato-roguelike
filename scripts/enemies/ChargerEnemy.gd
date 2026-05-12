extends BaseEnemy

func _get_sprite_key() -> String:
	return "charger"

func _move_toward_player(_delta: float) -> void:
	var dist = global_position.distance_to(player.global_position)
	var effective_speed = enemy_data.speed
	if dist > 200:
		effective_speed = enemy_data.speed * 2.5
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * effective_speed
	move_and_slide()
