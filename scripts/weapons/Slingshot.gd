# scripts/weapons/Slingshot.gd
class_name Slingshot
extends BaseWeapon

func attack(target: Node2D) -> void:
	var dir = (target.global_position - global_position).normalized()
	var dmg = weapon_data.get_scaled_damage(player.stats.damage_mult)
	spawn_bullet(dir, weapon_data.projectile_speed, dmg,
			weapon_data.projectile_color, weapon_data.piercing, 1)
