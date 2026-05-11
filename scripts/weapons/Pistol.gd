# scripts/weapons/Pistol.gd
class_name Pistol
extends BaseWeapon

func attack(target: Node2D) -> void:
	var direction = target.global_position - global_position
	for i in range(weapon_data.projectile_count):
		var dir = direction
		if i > 0:
			dir = direction.rotated(deg_to_rad(randf_range(-5, 5)))
		var dmg = weapon_data.get_scaled_damage(player.stats.damage_mult)
		spawn_bullet(dir, weapon_data.projectile_speed, dmg,
				weapon_data.projectile_color, weapon_data.piercing, weapon_data.bounce_count)
