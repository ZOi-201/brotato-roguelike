# scripts/ui/ShopUI.gd
class_name ShopUI
extends CanvasLayer

@onready var items_container: HBoxContainer = $Panel/VBox/ItemRow
@onready var refresh_btn: Button = $Panel/VBox/BtnRow/RefreshBtn
@onready var close_btn: Button = $Panel/VBox/BtnRow/CloseBtn
@onready var material_display: Label = $Panel/VBox/MaterialLabel

var current_offers: Array = []
var all_items: Array[ItemData] = []
var all_weapons: Array[WeaponData] = []
var refresh_cost: int = 1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.game_state_changed.connect(_on_state_changed)
	refresh_btn.pressed.connect(_on_refresh)
	close_btn.pressed.connect(_on_close)
	visible = false
	_style_panel()
	_setup_item_pool()
	_setup_weapon_pool()

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
	# Style buttons
	for btn in [refresh_btn, close_btn]:
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.2, 0.2, 0.3, 1)
		btn_style.corner_radius_top_left = 6; btn_style.corner_radius_top_right = 6
		btn_style.corner_radius_bottom_left = 6; btn_style.corner_radius_bottom_right = 6
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_font_size_override("font_size", 16)
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.3, 0.3, 0.45, 1)
	hover_style.corner_radius_top_left = 6; hover_style.corner_radius_top_right = 6
	hover_style.corner_radius_bottom_left = 6; hover_style.corner_radius_bottom_right = 6
	close_btn.add_theme_stylebox_override("hover", hover_style)
	refresh_btn.add_theme_stylebox_override("hover", hover_style)
	material_display.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	material_display.add_theme_font_size_override("font_size", 18)

func _setup_item_pool() -> void:
	var item_defs = [
		{"name": "急救包", "desc": "+5 HP Regen", "price": 25, "stat": "hp_regen", "amt": 5.0},
		{"name": "咖啡", "desc": "+10% Atk Speed", "price": 20, "stat": "attack_speed_mult", "amt": 0.1},
		{"name": "肌肉护腕", "desc": "+15% Damage", "price": 30, "stat": "damage_mult", "amt": 0.15},
		{"name": "跑鞋", "desc": "+20 Speed", "price": 25, "stat": "speed", "amt": 20.0, "stackable": false},
		{"name": "幸运草", "desc": "+5 Luck", "price": 20, "stat": "luck", "amt": 5.0},
		{"name": "铁盾", "desc": "+3 Armor", "price": 30, "stat": "armor", "amt": 3.0},
		{"name": "园艺手套", "desc": "+8 Harvesting", "price": 25, "stat": "harvesting", "amt": 8.0},
		{"name": "肾上腺素", "desc": "Kill: 3s +30% Spd", "price": 35, "stat": "", "amt": 0, "stackable": false},
		{"name": "吸血牙", "desc": "+5% Lifesteal", "price": 40, "stat": "lifesteal", "amt": 0.05, "max_stacks": 10},
		{"name": "反伤甲", "desc": "Reflect 5 dmg", "price": 35, "stat": "", "amt": 0, "stackable": false},
	]
	for def in item_defs:
		var item = ItemData.new()
		item.item_name = def["name"]
		item.description = def["desc"]
		item.price = def["price"]
		item.stat_mod = def["stat"]
		item.amount = def["amt"]
		item.stackable = def.get("stackable", true)
		item.max_stacks = def.get("max_stacks", 999)
		all_items.append(item)

func _setup_weapon_pool() -> void:
	var pistoldata = WeaponData.new()
	pistoldata.weapon_name = "Pistol"; pistoldata.base_damage = 10.0; pistoldata.attack_speed = 1.0
	pistoldata.range = 300.0; pistoldata.projectile_speed = 400.0; pistoldata.projectile_color = Color.YELLOW
	all_weapons.append(pistoldata)
	var sg = WeaponData.new()
	sg.weapon_name = "Shotgun"; sg.base_damage = 6.0; sg.attack_speed = 0.6
	sg.range = 200.0; sg.projectile_speed = 350.0; sg.projectile_color = Color.ORANGE
	sg.projectile_count = 3; sg.spread_angle = 30.0
	all_weapons.append(sg)
	var st = WeaponData.new()
	st.weapon_name = "Staff"; st.base_damage = 15.0; st.attack_speed = 0.5
	st.range = 350.0; st.projectile_speed = 250.0; st.projectile_color = Color.PURPLE; st.piercing = true
	all_weapons.append(st)
	var dg = WeaponData.new()
	dg.weapon_name = "Dagger"; dg.base_damage = 20.0; dg.attack_speed = 2.0
	dg.range = 80.0; dg.projectile_speed = 600.0; dg.projectile_color = Color.CYAN
	all_weapons.append(dg)
	var sl = WeaponData.new()
	sl.weapon_name = "Slingshot"; sl.base_damage = 8.0; sl.attack_speed = 0.8
	sl.range = 280.0; sl.projectile_speed = 380.0; sl.projectile_color = Color.GREEN_YELLOW; sl.bounce_count = 1
	all_weapons.append(sl)

func _on_state_changed(state: GameManager.GameState) -> void:
	if state == GameManager.GameState.SHOP:
		generate_offers()
		_show_with_fade()
	else:
		visible = false

func _show_with_fade() -> void:
	visible = true
	_refresh_material_display()
	$ColorRect.modulate.a = 0
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, 0.15)

func _refresh_material_display() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		material_display.text = "金币: %d" % player.stats.materials

func generate_offers() -> void:
	current_offers.clear()
	for _i in range(4):
		if randf() < 0.5 and not all_weapons.is_empty():
			current_offers.append(all_weapons.pick_random())
		else:
			current_offers.append(all_items.pick_random())
	_update_display()

func _update_display() -> void:
	for child in items_container.get_children():
		child.queue_free()
	var player = get_tree().get_first_node_in_group("player")
	_refresh_material_display()
	for offer in current_offers:
		var card = _create_offer_card(player, offer)
		items_container.add_child(card)

func _create_offer_card(player: Player, offer: Variant) -> Control:
	var card = Panel.new()
	card.custom_minimum_size = Vector2(135, 95)
	card.size_flags_horizontal = Control.SIZE_EXPAND
	var is_weapon = offer is WeaponData
	var border_color = Color.ORANGE if is_weapon else Color(0.3, 0.6, 1)
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.12, 0.12, 0.18, 1)
	card_style.border_width_left = 2; card_style.border_width_right = 2
	card_style.border_width_top = 2; card_style.border_width_bottom = 2
	card_style.border_color = border_color
	card_style.corner_radius_top_left = 8; card_style.corner_radius_top_right = 8
	card_style.corner_radius_bottom_left = 8; card_style.corner_radius_bottom_right = 8
	card.add_theme_stylebox_override("panel", card_style)

	var vbox = VBoxContainer.new()
	vbox.anchors_preset = Control.PRESET_FULL_RECT
	vbox.offset_left = 8; vbox.offset_top = 8; vbox.offset_right = -8; vbox.offset_bottom = -8
	vbox.add_theme_constant_override("separation", 4)

	if is_weapon:
		var wd = offer as WeaponData
		var name_lbl = Label.new()
		name_lbl.text = wd.weapon_name
		name_lbl.add_theme_color_override("font_color", Color.ORANGE)
		name_lbl.add_theme_font_size_override("font_size", 16)
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var level_lbl = Label.new()
		level_lbl.text = _weapon_level_text(player, wd)
		level_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		level_lbl.add_theme_font_size_override("font_size", 12)
		level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var price_lbl = Label.new()
		price_lbl.text = "%d 金币" % _weapon_price(player, wd)
		price_lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
		price_lbl.add_theme_font_size_override("font_size", 18)
		price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(name_lbl)
		vbox.add_child(level_lbl)
		vbox.add_child(price_lbl)
	else:
		var item = offer as ItemData
		var name_lbl = Label.new()
		name_lbl.text = item.item_name
		name_lbl.add_theme_color_override("font_color", Color(0.4, 0.7, 1))
		name_lbl.add_theme_font_size_override("font_size", 16)
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var desc_lbl = Label.new()
		desc_lbl.text = item.description
		desc_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		desc_lbl.add_theme_font_size_override("font_size", 11)
		desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var price_lbl = Label.new()
		price_lbl.text = "%d 金币" % item.price
		price_lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
		price_lbl.add_theme_font_size_override("font_size", 18)
		price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(name_lbl)
		vbox.add_child(desc_lbl)
		vbox.add_child(price_lbl)

	card.add_child(vbox)
	# Color price based on affordability
	var current_player = get_tree().get_first_node_in_group("player")
	var price = 0
	if is_weapon:
		price = _weapon_price(current_player, offer as WeaponData)
	else:
		price = (offer as ItemData).price
	if current_player and current_player.stats.materials < price:
		_card_price_label(vbox).add_theme_color_override("font_color", Color(1, 0.3, 0.3))

	card.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			var p = get_tree().get_first_node_in_group("player")
			var cost = 0
			if is_weapon:
				cost = _weapon_price(p, offer as WeaponData)
			else:
				cost = (offer as ItemData).price
			if not p or p.stats.materials < cost:
				_flash_insufficient(card)
				return
			if is_weapon: _buy_weapon(p, offer as WeaponData)
			else: _buy_item(offer as ItemData)
	)
	return card

func _card_price_label(vbox: VBoxContainer) -> Label:
	for c in vbox.get_children():
		if c is Label:
			var t: String = c.text
			if "Mat" in t or "金币" in t:
				return c
	return vbox.get_child(vbox.get_child_count() - 1)

func _flash_insufficient(card: Panel) -> void:
	var tween = card.create_tween()
	card.modulate = Color(1, 0.3, 0.3)
	tween.tween_property(card, "modulate", Color(1, 1, 1, 1), 0.3)

func _weapon_level_text(player: Player, wd: WeaponData) -> String:
	for w in player.weapons:
		if w.weapon_data.weapon_name == wd.weapon_name:
			return "Lv.%d → Lv.%d" % [w.weapon_data.level, w.weapon_data.level + 1]
	return "Lv.1"

func _weapon_price(player: Player, wd: WeaponData) -> int:
	var cl = 0
	for w in player.weapons:
		if w.weapon_data.weapon_name == wd.weapon_name:
			cl = w.weapon_data.level
			break
	return 15 + cl * 10

func _buy_item(item: ItemData) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player or player.stats.materials < item.price:
		return
	player.stats.materials -= item.price
	if item.stat_mod == "hp_regen": player.stats.hp_regen += item.amount
	elif item.stat_mod == "attack_speed_mult": player.stats.attack_speed_mult += item.amount
	elif item.stat_mod == "damage_mult": player.stats.damage_mult += item.amount
	elif item.stat_mod == "speed": player.stats.speed += item.amount
	elif item.stat_mod == "luck": player.stats.luck += int(item.amount)
	elif item.stat_mod == "armor": player.stats.armor += int(item.amount)
	elif item.stat_mod == "harvesting": player.stats.harvesting += int(item.amount)
	elif item.stat_mod == "lifesteal": player.stats.lifesteal = minf(0.5, player.stats.lifesteal + item.amount)
	player.items.append(item)
	_update_display()

func _buy_weapon(player: Player, wd: WeaponData) -> void:
	var price = _weapon_price(player, wd)
	if player.stats.materials < price:
		return
	for w in player.weapons:
		if w.weapon_data.weapon_name == wd.weapon_name:
			var ud = w.weapon_data.get_level_up_data()
			w.weapon_data.base_damage = ud["damage"]
			w.weapon_data.attack_speed = ud["attack_speed"]
			w.weapon_data.projectile_count = ud["projectile_count"]
			w.weapon_data.piercing = ud.get("piercing", w.weapon_data.piercing)
			w.weapon_data.level += 1
			player.stats.materials -= price
			_update_display()
			return
	if player.weapons.size() >= 6:
		return
	player.stats.materials -= price
	var weapon = _instantiate_weapon(wd)
	player.add_weapon(weapon)
	_update_display()

func _instantiate_weapon(wd: WeaponData) -> BaseWeapon:
	var data = WeaponData.new()
	match wd.weapon_name:
		"Pistol":
			data.weapon_name = "Pistol"; data.base_damage = 10.0; data.attack_speed = 1.0
			data.range = 300.0; data.projectile_speed = 400.0; data.projectile_color = Color.YELLOW; data.projectile_count = 1
			var p = Pistol.new(); p.weapon_data = data; return p
		"Shotgun":
			data.weapon_name = "Shotgun"; data.base_damage = 6.0; data.attack_speed = 0.6
			data.range = 200.0; data.projectile_speed = 350.0; data.projectile_color = Color.ORANGE
			data.projectile_count = 3; data.spread_angle = 30.0
			var s = Shotgun.new(); s.weapon_data = data; return s
		"Staff":
			data.weapon_name = "Staff"; data.base_damage = 15.0; data.attack_speed = 0.5
			data.range = 350.0; data.projectile_speed = 250.0; data.projectile_color = Color.PURPLE; data.piercing = true
			var st = Staff.new(); st.weapon_data = data; return st
		"Dagger":
			data.weapon_name = "Dagger"; data.base_damage = 20.0; data.attack_speed = 2.0
			data.range = 80.0; data.projectile_speed = 600.0; data.projectile_color = Color.CYAN
			var d = Dagger.new(); d.weapon_data = data; return d
		"Slingshot":
			data.weapon_name = "Slingshot"; data.base_damage = 8.0; data.attack_speed = 0.8
			data.range = 280.0; data.projectile_speed = 380.0; data.projectile_color = Color.GREEN_YELLOW; data.bounce_count = 1
			var sl = Slingshot.new(); sl.weapon_data = data; return sl
	return Pistol.new()

func _on_refresh() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.stats.materials >= refresh_cost:
		player.stats.materials -= refresh_cost
		generate_offers()

func _on_close() -> void:
	GameManager.start_next_wave()
