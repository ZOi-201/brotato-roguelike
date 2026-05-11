# scripts/ui/LevelUpUI.gd
class_name LevelUpUI
extends CanvasLayer

@onready var options_container: VBoxContainer = $Panel/VBox

var stat_options: Dictionary = {
	"max_hp": {"label": "Max HP", "amount": 5.0, "max_level": 999},
	"hp_regen": {"label": "HP Regen", "amount": 1.0, "max_level": 10},
	"damage_mult": {"label": "Damage %", "amount": 0.05, "max_level": 999},
	"attack_speed_mult": {"label": "Attack Speed %", "amount": 0.05, "max_level": 999},
	"speed": {"label": "Speed", "amount": 3.0, "max_level": 10},
	"dodge": {"label": "Dodge", "amount": 0.03, "max_level": 20},
	"armor": {"label": "Armor", "amount": 1.0, "max_level": 999},
	"luck": {"label": "Luck", "amount": 3.0, "max_level": 999},
	"harvesting": {"label": "Harvesting", "amount": 3.0, "max_level": 999},
}

func _ready() -> void:
	GameManager.game_state_changed.connect(_on_state_changed)
	visible = false

func _on_state_changed(state: GameManager.GameState) -> void:
	if state == GameManager.GameState.LEVEL_UP:
		show_options()
	else:
		visible = false

func show_options() -> void:
	for child in options_container.get_children():
		child.queue_free()
	visible = true
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var available = []
	for stat in stat_options.keys():
		var info = stat_options[stat]
		if player.stats.upgrade_levels.get(stat, 0) >= info["max_level"]:
			continue
		available.append(stat)
	available.shuffle()
	var count = mini(4, available.size())
	for i in range(count):
		var stat = available[i]
		var info = stat_options[stat]
		var btn = Button.new()
		btn.text = "%s  +%s  (Lv.%d)" % [info["label"], str(info["amount"]), player.stats.upgrade_levels.get(stat, 0) + 1]
		btn.pressed.connect(func(): _select(stat, info))
		options_container.add_child(btn)

func _select(stat: String, info: Dictionary) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	player.stats.apply_level_up(stat, info["amount"])
	if player.stats.check_level_up():
		show_options()
	else:
		GameManager.change_state(GameManager.GameState.PLAYING)
