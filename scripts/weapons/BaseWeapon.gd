# scripts/weapons/BaseWeapon.gd
class_name BaseWeapon
extends Node2D

@export var weapon_data: WeaponData
var cooldown_timer: float = 0.0
var player: Player
var bullet_scene: PackedScene = preload("res://scenes/projectiles/Bullet.tscn")

func _ready() -> void:
	player = get_parent().get_parent() as Player

func _process(delta: float) -> void:
	cooldown_timer -= delta
	if cooldown_timer > 0:
		return
	var target = player.get_nearest_enemy()
	if not target:
		return
	var dist = global_position.distance_to(target.global_position)
	if dist > weapon_data.range:
		return
	attack(target)
	cooldown_timer = 1.0 / (weapon_data.attack_speed * player.stats.attack_speed_mult)

func attack(target: Node2D) -> void:
	pass

func spawn_bullet(direction: Vector2, speed: float, damage: float, color: Color, piercing: bool, bounce: int) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = direction.normalized()
	bullet.speed = speed
	bullet.damage = damage
	bullet.color = color
	bullet.piercing = piercing
	bullet.bounces = bounce
	get_tree().current_scene.add_child(bullet)
