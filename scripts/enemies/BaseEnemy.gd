# scripts/enemies/BaseEnemy.gd
class_name BaseEnemy
extends CharacterBody2D

@export var enemy_data: EnemyData
var hp: float
var player: Player
var flash_tween: Tween

func _ready() -> void:
	add_to_group("enemies")
	hp = enemy_data.max_hp * (1.0 if not enemy_data.is_elite else 3.0)
	if enemy_data.is_boss:
		hp *= 10.0
	_setup_visual()

func _setup_visual() -> void:
	var shape = ColorRect.new()
	shape.size = Vector2(enemy_data.size * 2, enemy_data.size * 2)
	shape.color = enemy_data.color
	shape.position = -shape.size / 2
	add_child(shape)

func _physics_process(_delta: float) -> void:
	player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		return
	_move_toward_player(_delta)

func _move_toward_player(_delta: float) -> void:
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * enemy_data.speed
	move_and_slide()

func take_damage(amount: float) -> void:
	hp -= amount
	_flash_hit()
	if hp <= 0:
		die()

func _flash_hit() -> void:
	for child in get_children():
		if child is ColorRect:
			if flash_tween and flash_tween.is_running():
				flash_tween.kill()
			child.modulate = Color.WHITE
			flash_tween = create_tween()
			flash_tween.tween_property(child, "modulate", Color.WHITE, 0.05)
			flash_tween.tween_property(child, "modulate", Color(1, 1, 1, 1), 0.1)
			break

func die() -> void:
	_spawn_death_particles()
	GameManager.on_enemy_killed(self)
	queue_free()

func _spawn_death_particles() -> void:
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 8
	particles.lifetime = 0.4
	particles.global_position = global_position
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.initial_velocity_min = 60.0
	particles.initial_velocity_max = 120.0
	particles.gravity = Vector2(0, 100)
	particles.color = enemy_data.color
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 5.0
	particles.finished.connect(particles.queue_free)
	get_tree().current_scene.add_child(particles)
