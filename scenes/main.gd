# scenes/main.gd
extends Node2D

@onready var player = $Player
@onready var camera: Camera2D = $Camera2D

var enemy_scenes = {
	"basic": preload("res://scenes/enemies/BasicEnemy.tscn"),
	"charger": preload("res://scenes/enemies/ChargerEnemy.tscn"),
	"ranged": preload("res://scenes/enemies/RangedEnemy.tscn"),
}

func _ready() -> void:
	GameManager.game_state_changed.connect(_on_game_state_changed)
	GameManager.enemy_killed.connect(_on_enemy_killed)
	_give_starter_weapon()

func _give_starter_weapon() -> void:
	var data = WeaponData.new()
	data.weapon_name = "Pistol"; data.base_damage = 10.0; data.attack_speed = 1.0
	data.range = 300.0; data.projectile_speed = 400.0; data.projectile_color = Color.YELLOW
	var pistol = Pistol.new()
	pistol.weapon_data = data
	player.add_weapon(pistol)

func _process(_delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	GameManager.spawn_timer -= get_process_delta_time()
	if GameManager.spawn_timer <= 0 and GameManager.enemies_spawned < GameManager.enemies_to_spawn:
		spawn_enemy()
		GameManager.spawn_timer = GameManager.spawn_interval
	_magnet_drops(_delta)

func spawn_enemy() -> void:
	if GameManager.current_wave == 20 and GameManager.enemies_spawned == 0:
		_spawn_boss()
		return
	var pos = GameManager.get_random_spawn_position()
	var enemy_type = "basic"
	var is_elite = false
	if GameManager.current_wave in [5, 10, 15] and randf() < 0.3:
		is_elite = true
	if GameManager.current_wave >= 15 and randf() < 0.2:
		enemy_type = "ranged" if randf() < 0.5 else "charger"
	elif GameManager.current_wave >= 5 and randf() < 0.3:
		enemy_type = "charger" if randf() < 0.6 else "ranged"
	var enemy = enemy_scenes[enemy_type].instantiate()
	enemy.global_position = pos
	if is_elite:
		enemy.enemy_data = enemy.enemy_data.duplicate()
		enemy.enemy_data.is_elite = true
		enemy.scale = Vector2(1.5, 1.5)
	add_child(enemy)
	GameManager.enemies_spawned += 1

func _spawn_boss() -> void:
	var boss = enemy_scenes["basic"].instantiate()
	boss.enemy_data = _create_boss_data()
	boss.global_position = Vector2(512, 384)
	boss.scale = Vector2(3, 3)
	add_child(boss)
	GameManager.enemies_spawned += 1

func _create_boss_data() -> EnemyData:
	var bd = EnemyData.new()
	bd.enemy_name = "Boss"; bd.max_hp = 500.0; bd.speed = 60.0
	bd.damage = 25; bd.xp_reward = 100.0; bd.material_drop_chance = 1.0
	bd.color = Color.RED; bd.size = 36.0; bd.is_boss = true
	return bd

func _on_game_state_changed(state: GameManager.GameState) -> void:
	pass

func _on_enemy_killed(ed: EnemyData, pos: Vector2, is_elite: bool, is_boss: bool) -> void:
	_spawn_xp_drop(pos, ed.xp_reward)
	if randf() < ed.material_drop_chance or is_elite or is_boss:
		_spawn_material_drop(pos, 1 + int(is_elite) * 2 + int(is_boss) * 5)

func _spawn_xp_drop(pos: Vector2, amount: float) -> void:
	var drop = Area2D.new()
	drop.add_to_group("xp_drops")
	var cs = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 5
	cs.shape = circle
	drop.add_child(cs)
	var rect = ColorRect.new()
	rect.size = Vector2(8, 8)
	rect.color = Color.GREEN
	rect.position = -rect.size / 2
	drop.add_child(rect)
	drop.global_position = pos
	drop.set_meta("xp_amount", amount)
	drop.body_entered.connect(func(b): if b.is_in_group("player"): _collect_xp(drop))
	add_child(drop)

func _spawn_material_drop(pos: Vector2, amount: int) -> void:
	var drop = Area2D.new()
	drop.add_to_group("material_drops")
	var cs = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 6
	cs.shape = circle
	drop.add_child(cs)
	var rect = ColorRect.new()
	rect.size = Vector2(10, 10)
	rect.color = Color.YELLOW
	rect.position = -rect.size / 2
	drop.add_child(rect)
	drop.global_position = pos
	drop.set_meta("material_amount", amount)
	drop.body_entered.connect(func(b): if b.is_in_group("player"): _collect_material(drop))
	add_child(drop)

func _collect_xp(drop: Area2D) -> void:
	var amount = drop.get_meta("xp_amount", 5.0)
	player.stats.add_xp(amount)
	if player.stats.check_level_up():
		GameManager.change_state(GameManager.GameState.LEVEL_UP)
	drop.queue_free()

func _collect_material(drop: Area2D) -> void:
	player.stats.materials += drop.get_meta("material_amount", 1)
	drop.queue_free()

func _magnet_drops(delta: float) -> void:
	if not player:
		return
	for group_name in ["xp_drops", "material_drops"]:
		for drop in get_tree().get_nodes_in_group(group_name):
			if not drop.has_meta("spawn_time"):
				drop.set_meta("spawn_time", Time.get_ticks_msec() / 1000.0)
			var age = Time.get_ticks_msec() / 1000.0 - drop.get_meta("spawn_time")
			if age < 0.5:
				continue
			var dir = (player.global_position - drop.global_position).normalized()
			var dist = player.global_position.distance_to(drop.global_position)
			var speed = clampf(500.0 / maxf(dist, 1), 100, 500)
			drop.global_position += dir * speed * delta

func camera_shake() -> void:
	var tween = create_tween()
	tween.tween_property(camera, "offset", Vector2(6, 0), 0.03)
	tween.tween_property(camera, "offset", Vector2(-5, 2), 0.03)
	tween.tween_property(camera, "offset", Vector2(3, -3), 0.03)
	tween.tween_property(camera, "offset", Vector2(-2, 1), 0.03)
	tween.tween_property(camera, "offset", Vector2(0, 0), 0.03)
