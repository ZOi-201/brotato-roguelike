# scripts/ui/ShopUI.gd
class_name ShopUI
extends CanvasLayer

@onready var items_container: HBoxContainer = $Panel/VBox/ItemRow
@onready var refresh_btn: Button = $Panel/VBox/BtnRow/RefreshBtn
@onready var close_btn: Button = $Panel/VBox/BtnRow/CloseBtn

var current_offers: Array = []
var all_items: Array[ItemData] = []
var all_weapons: Array[WeaponData] = []
var refresh_cost: int = 1

func _ready() -> void:
	GameManager.game_state_changed.connect(_on_state_changed)
	refresh_btn.pressed.connect(_on_refresh)
	close_btn.pressed.connect(_on_close)
	visible = false
	_setup_item_pool()
	_setup_weapon_pool()

func _setup_item_pool() -> void:
	var item_defs = [
		{"name": "急救包", "desc": "+5 HP Regen", "price": 25, "stat": "hp_regen", "amt": 5.0},
		{"name": "咖啡", "desc": "+10% Attack Speed", "price": 20, "stat": "attack_speed_mult", "amt": 0.1},
		{"name": "肌肉护腕", "desc": "+15% Damage", "price": 30, "stat": "damage_mult", "amt": 0.15},
		{"name": "跑鞋", "desc": "+20 Speed", "price": 25, "stat": "speed", "amt": 20.0, "stackable": false},
		{"name": "幸运草", "desc": "+5 Luck", "price": 20, "stat": "luck", "amt": 5.0},
		{"name": "铁盾", "desc": "+3 Armor", "price": 30, "stat": "armor", "amt": 3.0},
		{"name": "园艺手套", "desc": "+8 Harvesting", "price": 25, "stat": "harvesting", "amt": 8.0},
		{"name": "肾上腺素", "desc": "Kill: 3s +30% Speed", "price": 35, "stat": "", "amt": 0, "stackable": false},
		{"name": "吸血牙", "desc": "+5% Lifesteal", "price": 40, "stat": "lifesteal", "amt": 0.05, "max_stacks": 10},
		{"name": "反伤甲", "desc": "Reflect 5 dmg on hit", "price": 35, "stat": "", "amt": 0, "stackable": false},
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
	# Pistol
	var pistoldata = WeaponData.new()
	pistoldata.weapon_name = "Pistol"; pistoldata.base_damage = 10.0; pistoldata.attack_speed = 1.0
	pistoldata.range = 300.0; pistoldata.projectile_speed = 400.0; pistoldata.projectile_color = Color.YELLOW
	all_weapons.append(pistoldata)
	# Shotgun
	var sg = WeaponData.new()
	sg.weapon_name = "Shotgun"; sg.base_damage = 6.0; sg.attack_speed = 0.6
	sg.range = 200.0; sg.projectile_speed = 350.0; sg.projectile_color = Color.ORANGE
	sg.projectile_count = 3; sg.spread_angle = 30.0
	all_weapons.append(sg)
	# Staff
	var st = WeaponData.new()
	st.weapon_name = "Staff"; st.base_damage = 15.0; st.attack_speed = 0.5
	st.range = 350.0; st.projectile_speed = 250.0; st.projectile_color = Color.PURPLE; st.piercing = true
	all_weapons.append(st)
	# Dagger
	var dg = WeaponData.new()
	dg.weapon_name = "Dagger"; dg.base_damage = 20.0; dg.attack_speed = 2.0
	dg.range = 80.0; dg.projectile_speed = 600.0; dg.projectile_color = Color.CYAN
	all_weapons.append(dg)
	# Slingshot
	var sl = WeaponData.new()
	sl.weapon_name = "Slingshot"; sl.base_damage = 8.0; sl.attack_speed = 0.8
	sl.range = 280.0; sl.projectile_speed = 380.0; sl.projectile_color = Color.GREEN_YELLOW; sl.bounce_count = 1
	all_weapons.append(sl)

func _on_state_changed(state: GameManager.GameState) -> void:
	if state == GameManager.GameState.SHOP:
		generate_offers()
		visible = true
	else:
		visible = false

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
	for offer in current_offers:
		var btn = Button.new()
		if offer is ItemData:
			btn.text = "%s - %d Mat\n%s" % [offer.item_name, offer.price, offer.description]
			btn.pressed.connect(func(): _buy_item(offer as ItemData))
		elif offer is WeaponData:
			var level_text = _weapon_level_text(player, offer)
			btn.text = "%s %s - %d Mat" % [offer.weapon_name, level_text, _weapon_price(player, offer)]
			btn.pressed.connect(func(): _buy_weapon(player, offer))
		btn.size_flags_horizontal = Control.SIZE_EXPAND
		items_container.add_child(btn)
	refresh_btn.text = "Refresh (%d Mat)" % refresh_cost

func _weapon_level_text(player: Player, wd: WeaponData) -> String:
	for w in player.weapons:
		if w.weapon_data.weapon_name == wd.weapon_name:
			return "(Lv.%d -> Lv.%d)" % [w.weapon_data.level, w.weapon_data.level + 1]
	return "(Lv.1)"

func _weapon_price(player: Player, wd: WeaponData) -> int:
	var current_level = 0
	for w in player.weapons:
		if w.weapon_data.weapon_name == wd.weapon_name:
			current_level = w.weapon_data.level
			break
	return 15 + current_level * 10

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
			var upgrade_data = w.weapon_data.get_level_up_data()
			w.weapon_data.base_damage = upgrade_data["damage"]
			w.weapon_data.attack_speed = upgrade_data["attack_speed"]
			w.weapon_data.projectile_count = upgrade_data["projectile_count"]
			w.weapon_data.piercing = upgrade_data.get("piercing", w.weapon_data.piercing)
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
			data.range = 300.0; data.projectile_speed = 400.0; data.projectile_color = Color.YELLOW
			data.projectile_count = 1
			var p = Pistol.new(); p.weapon_data = data; return p
		"Shotgun":
			data.weapon_name = "Shotgun"; data.base_damage = 6.0; data.attack_speed = 0.6
			data.range = 200.0; data.projectile_speed = 350.0; data.projectile_color = Color.ORANGE
			data.projectile_count = 3; data.spread_angle = 30.0
			var s = Shotgun.new(); s.weapon_data = data; return s
		"Staff":
			data.weapon_name = "Staff"; data.base_damage = 15.0; data.attack_speed = 0.5
			data.range = 350.0; data.projectile_speed = 250.0; data.projectile_color = Color.PURPLE
			data.piercing = true
			var st = Staff.new(); st.weapon_data = data; return st
		"Dagger":
			data.weapon_name = "Dagger"; data.base_damage = 20.0; data.attack_speed = 2.0
			data.range = 80.0; data.projectile_speed = 600.0; data.projectile_color = Color.CYAN
			var d = Dagger.new(); d.weapon_data = data; return d
		"Slingshot":
			data.weapon_name = "Slingshot"; data.base_damage = 8.0; data.attack_speed = 0.8
			data.range = 280.0; data.projectile_speed = 380.0; data.projectile_color = Color.GREEN_YELLOW
			data.bounce_count = 1
			var sl = Slingshot.new(); sl.weapon_data = data; return sl
		_:
			return Pistol.new()

func _on_refresh() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.stats.materials >= refresh_cost:
		player.stats.materials -= refresh_cost
		generate_offers()

func _on_close() -> void:
	GameManager.start_next_wave()
