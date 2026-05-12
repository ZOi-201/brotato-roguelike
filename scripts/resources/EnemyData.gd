# scripts/resources/EnemyData.gd
class_name EnemyData
extends Resource

@export var enemy_name: String = ""
@export var max_hp: float = 30.0
@export var hp_per_wave: float = 2.0
@export var speed: float = 80.0
@export var damage: int = 8
@export var damage_per_wave: float = 0.3
@export var xp_reward: float = 5.0
@export var material_drop_chance: float = 0.2
@export var color: Color = Color.RED
@export var size: float = 12.0
@export var is_elite: bool = false
@export var is_boss: bool = false
