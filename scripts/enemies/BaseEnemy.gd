# scripts/enemies/BaseEnemy.gd
class_name BaseEnemy
extends CharacterBody2D

@export var enemy_data: EnemyData
var hp: float
var max_hp: float
var player: Player
var flash_tween: Tween
var _damage_cooldown: float = 0.0
var _telegraph_timer: float = 0.0
var _is_telegraphing: bool = false

func _ready() -> void:
	add_to_group("enemies")
	max_hp = enemy_data.max_hp * (1.0 if not enemy_data.is_elite else 3.0)
	if enemy_data.is_boss:
		max_hp *= 10.0
	hp = max_hp
	_setup_visual()

func _setup_visual() -> void:
	queue_redraw()

func _draw() -> void:
	_draw_enemy_shape()
	_draw_health_bar()

func _draw_enemy_shape() -> void:
	var s = enemy_data.size
	var c = enemy_data.color
	draw_circle(Vector2.ZERO, s, c)
	draw_circle(Vector2(-s * 0.3, -s * 0.3), 1.5, Color.WHITE)
	draw_circle(Vector2(s * 0.3, -s * 0.3), 1.5, Color.WHITE)
	draw_circle(Vector2(-s * 0.5, -s * 0.8), s * 0.25, c.darkened(0.3))
	draw_circle(Vector2(s * 0.5, -s * 0.8), s * 0.25, c.darkened(0.3))

func _draw_health_bar() -> void:
	var bar_w = enemy_data.size * 2.5
	var bar_h = 3.0
	var bar_y = -enemy_data.size - 8
	var ratio = hp / maxf(max_hp, 1)
	draw_rect(Rect2(-bar_w / 2, bar_y, bar_w, bar_h), Color.BLACK, false, 1.0)
	draw_rect(Rect2(-bar_w / 2, bar_y, bar_w * ratio, bar_h), Color.RED if ratio > 0.5 else Color.ORANGE_RED if ratio > 0.25 else Color.DARK_RED)

func _physics_process(_delta: float) -> void:
	player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		return
	_move_toward_player(_delta)
	_check_contact(_delta)

func _check_contact(delta: float) -> void:
	_damage_cooldown -= delta
	_telegraph_timer -= delta
	
	if _is_telegraphing and _telegraph_timer <= 0:
		_is_telegraphing = false
		modulate = Color(1, 1, 1, 1)
		# Deal damage
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			if col.get_collider() and col.get_collider().is_in_group("player"):
				player.stats.take_damage(enemy_data.damage)
				_attack_lunge()
				_damage_cooldown = 0.8
				break
	
	if _damage_cooldown > 0:
		return
	
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		if col.get_collider() and col.get_collider().is_in_group("player"):
			# Start telegraph
			_is_telegraphing = true
			_telegraph_timer = 0.35
			modulate = Color(1, 0.8, 0.2)
			_damage_cooldown = 0.8
			break

func _attack_lunge() -> void:
	var lunge_dir = (player.global_position - global_position).normalized()
	global_position -= lunge_dir * 8

func _move_toward_player(_delta: float) -> void:
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * enemy_data.speed
	move_and_slide()

func take_damage(amount: float) -> void:
	hp -= amount
	_flash_hit()
	queue_redraw()
	if hp <= 0:
		die()

func _flash_hit() -> void:
	if flash_tween and flash_tween.is_running():
		flash_tween.kill()
	modulate = Color.WHITE
	flash_tween = create_tween()
	flash_tween.tween_property(self, "modulate", Color.WHITE, 0.05)
	flash_tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.1)

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
