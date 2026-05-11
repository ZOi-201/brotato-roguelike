# scripts/weapons/Shotgun.gd
class_name Shotgun
extends BaseWeapon

func attack(target: Node2D) -> void:
	var base_dir = (target.global_position - global_position).normalized()
	var spread = weapon_data.spread_angle
	for i in range(weapon_data.projectile_count):
		var angle = deg_to_rad(-spread / 2 + (spread / (weapon_data.projectile_count - 1)) * i) if weapon_data.projectile_count > 1 else 0.0
		var dir = base_dir.rotated(angle)
		var dmg = weapon_data.get_scaled_damage(player.stats.damage_mult)
		spawn_bullet(dir, weapon_data.projectile_speed, dmg,
				weapon_data.projectile_color, weapon_data.piercing, weapon_data.bounce_count)
