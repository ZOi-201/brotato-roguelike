# scripts/weapons/Staff.gd
class_name Staff
extends BaseWeapon

func attack(target: Node2D) -> void:
	var dir = (target.global_position - global_position).normalized()
	var dmg = weapon_data.get_scaled_damage(player.stats.damage_mult)
	spawn_bullet(dir, weapon_data.projectile_speed * 0.5, dmg,
			weapon_data.projectile_color, true, weapon_data.bounce_count)
