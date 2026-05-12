# scripts/ui/LevelUpUI.gd
class_name LevelUpUI
extends CanvasLayer

@onready var options_container: HBoxContainer = $Panel/VBox/HBox

var stat_options: Dictionary = {
	"max_hp":          {"label": "最大生命",  "icon": "♥",  "color": Color(1, 0.2, 0.2)},
	"hp_regen":        {"label": "生命回复",  "icon": "♻",  "color": Color(1, 0.5, 0.5)},
	"damage_mult":     {"label": "伤害",      "icon": "⚔",  "color": Color(1, 0.5, 0)},
	"attack_speed_mult":{"label":"攻击速度",  "icon": "⚡",  "color": Color(1, 0.7, 0)},
	"speed":           {"label": "移动速度",  "icon": "»",  "color": Color(0.3, 0.6, 1)},
	"dodge":           {"label": "闪避",      "icon": "◎",  "color": Color(0.4, 0.8, 1)},
	"armor":           {"label": "护甲",      "icon": "▣",  "color": Color(0.6, 0.6, 0.65)},
	"luck":            {"label": "幸运",      "icon": "✦",  "color": Color(0.3, 1, 0.4)},
	"harvesting":      {"label": "收获",      "icon": "✦",  "color": Color(0.5, 1, 0.3)},
}
var stat_amounts: Dictionary = {
	"max_hp": 12.0, "hp_regen": 2.0, "damage_mult": 0.20,
	"attack_speed_mult": 0.20, "speed": 8.0, "dodge": 0.05,
	"armor": 2.0, "luck": 5.0, "harvesting": 5.0,
}
var stat_max: Dictionary = {
	"hp_regen": 10, "speed": 10, "dodge": 20,
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_style_panel()
	GameManager.game_state_changed.connect(_on_state_changed)
	visible = false

func _style_panel() -> void:
	var panel = $Panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	style.border_width_left = 2; style.border_width_right = 2
	style.border_width_top = 2; style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.4, 0.6)
	style.corner_radius_top_left = 12; style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12; style.corner_radius_bottom_right = 12
	style.content_margin_left = 16; style.content_margin_right = 16
	style.content_margin_top = 12; style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)

func _on_state_changed(state: GameManager.GameState) -> void:
	if state == GameManager.GameState.LEVEL_UP:
		show_options()
		_animate_in()
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
		var max_lvl = stat_max.get(stat, 999)
		if player.stats.upgrade_levels.get(stat, 0) >= max_lvl:
			continue
		available.append(stat)
	available.shuffle()
	var count = mini(4, available.size())
	for i in range(count):
		var stat = available[i]
		var info = stat_options[stat]
		var amount = stat_amounts[stat]
		var lvl = player.stats.upgrade_levels.get(stat, 0)
		var card = _create_card(stat, info, amount, lvl)
		options_container.add_child(card)

func _create_card(stat: String, info: Dictionary, amount: float, current_lvl: int) -> Control:
	var card = Panel.new()
	card.custom_minimum_size = Vector2(140, 90)
	card.size_flags_horizontal = Control.SIZE_EXPAND
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.12, 0.12, 0.18, 1)
	card_style.border_width_left = 2; card_style.border_width_right = 2
	card_style.border_width_top = 2; card_style.border_width_bottom = 2
	card_style.border_color = info["color"].darkened(0.3)
	card_style.corner_radius_top_left = 8; card_style.corner_radius_top_right = 8
	card_style.corner_radius_bottom_left = 8; card_style.corner_radius_bottom_right = 8
	card.add_theme_stylebox_override("panel", card_style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	vbox.anchors_preset = Control.PRESET_FULL_RECT
	vbox.offset_left = 8; vbox.offset_top = 8; vbox.offset_right = -8; vbox.offset_bottom = -8

	var icon_label = Label.new()
	icon_label.text = info["icon"]
	icon_label.add_theme_color_override("font_color", info["color"])
	icon_label.add_theme_font_size_override("font_size", 22)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var name_label = Label.new()
	name_label.text = info["label"]
	name_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var value_label = Label.new()
	var amt_str = "+%.0f" % amount if amount >= 1 else "+%d%%" % int(amount * 100)
	value_label.text = "%s  Lv.%d→%d" % [amt_str, current_lvl, current_lvl + 1]
	value_label.add_theme_color_override("font_color", info["color"].lightened(0.2))
	value_label.add_theme_font_size_override("font_size", 12)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	vbox.add_child(icon_label)
	vbox.add_child(name_label)
	vbox.add_child(value_label)
	card.add_child(vbox)

	card.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			_select(stat)
	)
	return card

func _select(stat: String) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var amount = stat_amounts[stat]
	player.stats.apply_level_up(stat, amount)
	if player.stats.check_level_up():
		show_options()
		_animate_in()
	else:
		GameManager.change_state(GameManager.GameState.PLAYING)

func _animate_in() -> void:
	$ColorRect.modulate.a = 0
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, 0.15)
