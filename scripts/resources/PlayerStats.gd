# scripts/resources/PlayerStats.gd
class_name PlayerStats
extends Resource

signal hp_changed(current_hp, max_hp)
signal died()

@export var max_hp: float = 100.0
@export var hp: float = 100.0:
	set(v):
		hp = clampf(v, 0, max_hp)
		hp_changed.emit(hp, max_hp)
		if hp <= 0:
			died.emit()
@export var hp_regen: float = 0.0
@export var damage_mult: float = 1.0
@export var attack_speed_mult: float = 1.0
@export var speed: float = 150.0
@export var dodge: float = 0.0
@export var armor: int = 0
@export var luck: int = 0
@export var harvesting: int = 0
@export var lifesteal: float = 0.0

var level: int = 1
var xp: float = 0.0
var xp_to_next: float = 50.0
var kills: int = 0
var materials: int = 0
var invincible: bool = false

# upgrade level tracking
var upgrade_levels: Dictionary = {
	"max_hp": 0, "hp_regen": 0, "damage_mult": 0,
	"attack_speed_mult": 0, "speed": 0, "dodge": 0,
	"armor": 0, "luck": 0, "harvesting": 0
}

func take_damage(amount: int) -> void:
	if invincible:
		return
	if randf() * 100 < dodge:
		return
	var reduced = maxi(1, amount - armor)
	hp -= reduced

func heal(amount: float) -> void:
	hp = minf(hp + amount, max_hp)

func add_xp(amount: float) -> void:
	xp += amount

func check_level_up() -> bool:
	return xp >= xp_to_next

func apply_level_up(stat: String, amount: float) -> void:
	xp -= xp_to_next
	level += 1
	xp_to_next = level * 20 + 30
	upgrade_levels[stat] = upgrade_levels.get(stat, 0) + 1
	match stat:
		"max_hp": max_hp += amount; hp = mini(hp + amount, max_hp)
		"hp_regen": hp_regen += amount
		"damage_mult": damage_mult += amount
		"attack_speed_mult": attack_speed_mult += amount
		"speed": speed += amount
		"dodge": dodge += amount
		"armor": armor += int(amount)
		"luck": luck += int(amount)
		"harvesting": harvesting += int(amount)
