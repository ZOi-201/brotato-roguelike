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
	body_entered.connect(_on_body_entered)
	var rect = ColorRect.new()
	rect.size = Vector2(8, 4)
	rect.color = color
	rect.position = -rect.size / 2
	add_child(rect)
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
