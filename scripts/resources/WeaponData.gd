# scripts/resources/WeaponData.gd
class_name WeaponData
extends Resource

@export var weapon_name: String = ""
@export var base_damage: float = 10.0
@export var attack_speed: float = 1.0
@export var range: float = 300.0
@export var projectile_speed: float = 400.0
@export var projectile_color: Color = Color.YELLOW
@export var projectile_count: int = 1
@export var spread_angle: float = 0.0
@export var piercing: bool = false
@export var bounce_count: int = 0
@export var level: int = 1

func get_scaled_damage(damage_mult: float) -> float:
	return base_damage * damage_mult

func get_level_up_data() -> Dictionary:
	var next = duplicate()
	next.level = level + 1
	match level + 1:
		2:
			next.base_damage *= 1.2
			next.attack_speed *= 1.1
		3:
			next.base_damage *= 1.5
			next.attack_speed *= 1.2
			if weapon_name == "Pistol":
				next.projectile_count = 2
		4:
			next.base_damage *= 1.8
			next.attack_speed *= 1.3
			if weapon_name == "Pistol":
				next.piercing = true
	return {"damage": next.base_damage, "attack_speed": next.attack_speed,
			"projectile_count": next.projectile_count, "piercing": next.piercing}
