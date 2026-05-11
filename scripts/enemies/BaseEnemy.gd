# scripts/enemies/BaseEnemy.gd
class_name BaseEnemy
extends CharacterBody2D

@export var enemy_data: EnemyData
var hp: float
var player: Player

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
	if hp <= 0:
		die()

func die() -> void:
	GameManager.on_enemy_killed(self)
	queue_free()
