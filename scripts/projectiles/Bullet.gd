# scripts/projectiles/Bullet.gd
class_name Bullet
extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 400.0
var damage: float = 10.0
var color: Color = Color.YELLOW
var piercing: bool = false
var bounces: int = 0
var lifetime: float = 2.0
var hit_enemies: Array = []

func _ready() -> void:
	add_to_group("projectiles")
	SFX.play("shoot", -12.0)
	body_entered.connect(_on_body_entered)
	var spr = Sprite2D.new()
	spr.texture = SpriteAssets.textures.get("bullet")
	spr.modulate = color
	spr.centered = true
	add_child(spr)
	look_at(global_position + direction)

func _process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemies"):
		return
	if body in hit_enemies:
		return
	body.take_damage(damage)
	_spawn_damage_number(body.global_position, damage)
	hit_enemies.append(body)
	if not piercing and bounces <= 0:
		queue_free()
	elif bounces > 0:
		bounces -= 1
		var nearest = _find_nearest_enemy_except(body)
		if nearest:
			direction = (nearest.global_position - global_position).normalized()
			look_at(global_position + direction)
		else:
			queue_free()

func _spawn_damage_number(pos: Vector2, amount: float) -> void:
	var label = Label.new()
	label.text = str(int(amount))
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 16)
	label.position = pos + Vector2(randf_range(-10, 10), -20)
	label.scale = Vector2.ZERO
	get_tree().current_scene.add_child(label)
	var tween = label.create_tween()
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(label, "scale", Vector2(1, 1), 0.1)
	tween.parallel().tween_property(label, "position:y", label.position.y - 30, 0.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.4).set_delay(0.2)
	tween.finished.connect(label.queue_free)

func _find_nearest_enemy_except(exclude: Node2D) -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_dist = INF
	for e in enemies:
		if e == exclude:
			continue
		var d = global_position.distance_squared_to(e.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = e
	return nearest
