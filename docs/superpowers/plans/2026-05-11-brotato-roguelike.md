# 土豆兄弟 Roguelike 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现土豆兄弟风格 2D 俯视角 roguelike 生存游戏核心玩法（1角色 + 5武器 + 10道具 + 20波）

**Architecture:** GameManager Autoload 管理全局状态和波次调度，Player/Enemy 为 CharacterBody2D，武器为 Node2D 子节点，投射物为 Area2D，属性用 Resource 存储，UI 用 CanvasLayer

**Tech Stack:** Godot 4.6, GDScript, 2D 物理（GodotPhysics2D）

---

## 文件规划

| 文件 | 职责 |
|---|---|
| `project.godot` | 项目配置（改为 2D） |
| `scripts/resources/PlayerStats.gd` | Resource，玩家属性数据 |
| `scripts/resources/WeaponData.gd` | Resource，武器数据 |
| `scripts/resources/ItemData.gd` | Resource，道具数据 |
| `scripts/resources/EnemyData.gd` | Resource，敌人数据 |
| `scripts/player/Player.gd` | CharacterBody2D，移动 + 武器管理 |
| `scripts/weapons/BaseWeapon.gd` | Node2D，武器基类 |
| `scripts/weapons/Pistol.gd` | 手枪 |
| `scripts/weapons/Shotgun.gd` | 霰弹枪 |
| `scripts/weapons/Staff.gd` | 法杖 |
| `scripts/weapons/Dagger.gd` | 匕首 |
| `scripts/weapons/Slingshot.gd` | 弹弓 |
| `scripts/projectiles/Bullet.gd` | Area2D，子弹/投射物 |
| `scripts/enemies/BaseEnemy.gd` | CharacterBody2D，敌人基类 |
| `scripts/systems/GameManager.gd` | Autoload，游戏状态 + 波次 |
| `scripts/systems/DropManager.gd` | Node，掉落物管理 |
| `scripts/components/HealthComponent.gd` | Node，独立血量管理 |
| `scripts/ui/HUD.gd` | CanvasLayer，战斗 HUD |
| `scripts/ui/ShopUI.gd` | CanvasLayer，商店界面 |
| `scripts/ui/LevelUpUI.gd` | CanvasLayer，升级选择界面 |
| `scripts/ui/GameOverUI.gd` | CanvasLayer，结束界面 |
| `scripts/ui/MainMenuUI.gd` | CanvasLayer，主菜单 |
| `scenes/main.tscn` | 主场景（竞技场 + HUD + 玩家） |
| `scenes/player/Player.tscn` | 玩家场景 |
| `scenes/enemies/BasicEnemy.tscn` | 普通小怪场景 |
| `scenes/enemies/ChargerEnemy.tscn` | 冲锋怪场景 |
| `scenes/enemies/RangedEnemy.tscn` | 远程怪场景 |
| `scenes/ui/ShopUI.tscn` | 商店 UI 场景 |
| `scenes/ui/LevelUpUI.tscn` | 升级 UI 场景 |
| `scenes/ui/GameOverUI.tscn` | 结束 UI 场景 |
| `scenes/ui/MainMenuUI.tscn` | 主菜单场景 |

---

### Task 1: 项目 2D 化 + 目录创建 + 输入映射

**Files:**
- Modify: `project.godot`
- Create: `scripts/resources/`, `scripts/player/`, `scripts/weapons/`, `scripts/projectiles/`, `scripts/enemies/`, `scripts/systems/`, `scripts/components/`, `scripts/ui/`, `scenes/player/`, `scenes/enemies/`, `scenes/ui/`

- [ ] **Step 1: 创建目录结构**

```bash
mkdir -p "D:/AI PROJECTS/godot_test/scripts/resources"
mkdir -p "D:/AI PROJECTS/godot_test/scripts/player"
mkdir -p "D:/AI PROJECTS/godot_test/scripts/weapons"
mkdir -p "D:/AI PROJECTS/godot_test/scripts/projectiles"
mkdir -p "D:/AI PROJECTS/godot_test/scripts/enemies"
mkdir -p "D:/AI PROJECTS/godot_test/scripts/systems"
mkdir -p "D:/AI PROJECTS/godot_test/scripts/components"
mkdir -p "D:/AI PROJECTS/godot_test/scripts/ui"
mkdir -p "D:/AI PROJECTS/godot_test/scenes/player"
mkdir -p "D:/AI PROJECTS/godot_test/scenes/enemies"
mkdir -p "D:/AI PROJECTS/godot_test/scenes/ui"
```

- [ ] **Step 2: 修改 project.godot 为 2D 项目**

```ini
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[application]

config/name="godot_test"
config/features=PackedStringArray("4.6", "Forward Plus")
config/icon="res://icon.svg"

[input]

move_left={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":65,"key_label":0,"unicode":97,"location":0,"echo":false,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194319,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
move_right={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":68,"key_label":0,"unicode":100,"location":0,"echo":false,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194321,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
move_up={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":87,"key_label":0,"unicode":119,"location":0,"echo":false,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194320,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
move_down={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":83,"key_label":0,"unicode":115,"location":0,"echo":false,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194322,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}

[physics]

common/max_physics_steps_per_frame=8
2d/physics_engine="GodotPhysics2D"

[rendering]

renderer/rendering_method="forward_plus"
rendering_device/driver.windows="d3d12"
```

- [ ] **Step 3: 提交**

```bash
git add -A
git commit -m "chore: convert project to 2D, create directory structure, add input map"
```

---

### Task 2: PlayerStats Resource

**Files:**
- Create: `scripts/resources/PlayerStats.gd`

- [ ] **Step 1: 创建 PlayerStats Resource**

```gdscript
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

# 升级等级追踪
var upgrade_levels: Dictionary = {
	"max_hp": 0, "hp_regen": 0, "damage_mult": 0,
	"attack_speed_mult": 0, "speed": 0, "dodge": 0,
	"armor": 0, "luck": 0, "harvesting": 0
}

func take_damage(amount: int) -> void:
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
```

- [ ] **Step 2: 提交**

```bash
git add scripts/resources/PlayerStats.gd
git commit -m "feat: add PlayerStats resource"
```

---

### Task 3: Player 场景 + 移动

**Files:**
- Create: `scripts/player/Player.gd`
- Create: `scenes/player/Player.tscn`

- [ ] **Step 1: 创建 Player 脚本**

```gdscript
# scripts/player/Player.gd
class_name Player
extends CharacterBody2D

@export var stats: PlayerStats

var weapons: Array[BaseWeapon] = []
var items: Array[ItemData] = []

func _ready() -> void:
	add_to_group("player")
	stats.hp_changed.connect(_on_hp_changed)
	stats.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * stats.speed
	move_and_slide()

func _process(delta: float) -> void:
	if stats.hp_regen > 0:
		stats.heal(stats.hp_regen * delta)

func add_weapon(weapon: BaseWeapon) -> void:
	if weapons.size() >= 6:
		return
	weapons.append(weapon)
	add_child(weapon)

func get_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
	var nearest: Node2D = null
	var nearest_dist = INF
	for enemy in enemies:
		var dist = global_position.distance_squared_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest

func _on_hp_changed(_current: float, _max_hp: float) -> void:
	pass

func _on_died() -> void:
	queue_free()
```

- [ ] **Step 2: 在 Godot 编辑器中创建 Player 场景**

在 Godot 编辑器中：
1. 创建 `scenes/player/Player.tscn`，根节点为 `CharacterBody2D`
2. 挂载 `Player.gd` 脚本
3. 添加子节点 `CollisionShape2D`（CircleShape2D，半径 15）
4. 添加子节点 `ColorRect`（32×32, 蓝色 `#4488ff`，锚点居中）作为占位视觉
5. 添加子节点 `WeaponHolder`（Node2D），武器将挂载在此节点下

- [ ] **Step 3: 提交**

```bash
git add scripts/player/Player.gd scenes/player/Player.tscn
git commit -m "feat: add player movement and basic scene"
```

---

### Task 4: WeaponData Resource + BaseWeapon + Pistol

**Files:**
- Create: `scripts/resources/WeaponData.gd`
- Create: `scripts/weapons/BaseWeapon.gd`
- Create: `scripts/weapons/Pistol.gd`

- [ ] **Step 1: 创建 WeaponData Resource**

```gdscript
# scripts/resources/WeaponData.gd
class_name WeaponData
extends Resource

@export var weapon_name: String = ""
@export var base_damage: float = 10.0
@export var attack_speed: float = 1.0
@export var range: float = 300.0
@export var projectile_speed: float = 400.0
@export var projectile_color: Color = Color.YELLOW
@export var projectile_count: int = 1
@export var spread_angle: float = 0.0  # 散射角度（度）
@export var piercing: bool = false
@export var bounce_count: int = 0
@export var level: int = 1

func get_scaled_damage(damage_mult: float) -> float:
	return base_damage * damage_mult

func get_level_up_data() -> Dictionary:
	var next = duplicate()
	next.level = level + 1
	match level + 1:
		2:
			next.base_damage *= 1.2
			next.attack_speed *= 1.1
		3:
			next.base_damage *= 1.5
			next.attack_speed *= 1.2
			if weapon_name == "Pistol":
				next.projectile_count = 2
		4:
			next.base_damage *= 1.8
			next.attack_speed *= 1.3
			if weapon_name == "Pistol":
				next.piercing = true
	return {"damage": next.base_damage, "attack_speed": next.attack_speed,
			"projectile_count": next.projectile_count, "piercing": next.piercing}
```

- [ ] **Step 2: 创建 BaseWeapon 基类**

```gdscript
# scripts/weapons/BaseWeapon.gd
class_name BaseWeapon
extends Node2D

@export var weapon_data: WeaponData
var cooldown_timer: float = 0.0
var player: Player
var bullet_scene: PackedScene = preload("res://scenes/projectiles/Bullet.tscn")

func _ready() -> void:
	player = get_parent().get_parent() as Player

func _process(delta: float) -> void:
	cooldown_timer -= delta
	if cooldown_timer > 0:
		return
	var target = player.get_nearest_enemy()
	if not target:
		return
	var dist = global_position.distance_to(target.global_position)
	if dist > weapon_data.range:
		return
	attack(target)
	cooldown_timer = 1.0 / (weapon_data.attack_speed * player.stats.attack_speed_mult)

func attack(target: Node2D) -> void:
	# 子类覆盖
	pass

func spawn_bullet(direction: Vector2, speed: float, damage: float, color: Color, piercing: bool, bounce: int) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = direction.normalized()
	bullet.speed = speed
	bullet.damage = damage
	bullet.color = color
	bullet.piercing = piercing
	bullet.bounces = bounce
	get_tree().current_scene.add_child(bullet)
```

- [ ] **Step 3: 创建 Pistol 手枪脚本**

```gdscript
# scripts/weapons/Pistol.gd
class_name Pistol
extends BaseWeapon

func attack(target: Node2D) -> void:
	var direction = target.global_position - global_position
	for i in range(weapon_data.projectile_count):
		var dir = direction
		if i > 0:
			dir = direction.rotated(deg_to_rad(randf_range(-5, 5)))
		var dmg = weapon_data.get_scaled_damage(player.stats.damage_mult)
		spawn_bullet(dir, weapon_data.projectile_speed, dmg,
				weapon_data.projectile_color, weapon_data.piercing, weapon_data.bounce_count)
```

- [ ] **Step 4: 提交**

```bash
git add scripts/resources/WeaponData.gd scripts/weapons/BaseWeapon.gd scripts/weapons/Pistol.gd
git commit -m "feat: add WeaponData resource, BaseWeapon, and Pistol"
```

---

### Task 5: Bullet 投射物

**Files:**
- Create: `scripts/projectiles/Bullet.gd`
- Create: `scenes/projectiles/Bullet.tscn`

- [ ] **Step 1: 创建 Bullet 脚本**

```gdscript
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
```

- [ ] **Step 2: 创建 Bullet 场景**

在 Godot 编辑器中：
1. 创建 `scenes/projectiles/Bullet.tscn`，根节点 `Area2D`
2. 挂载 `Bullet.gd`
3. 添加 `CollisionShape2D`（RectangleShape2D，8×4）
4. 碰撞层 mask 设为 enemy 所在的层

- [ ] **Step 3: 提交**

```bash
git add scripts/projectiles/Bullet.gd scenes/projectiles/Bullet.tscn
git commit -m "feat: add Bullet projectile with piercing and bounce"
```

---

### Task 6: EnemyData + BaseEnemy + 普通小怪

**Files:**
- Create: `scripts/resources/EnemyData.gd`
- Create: `scripts/enemies/BaseEnemy.gd`
- Create: `scenes/enemies/BasicEnemy.tscn`

- [ ] **Step 1: 创建 EnemyData Resource**

```gdscript
# scripts/resources/EnemyData.gd
class_name EnemyData
extends Resource

@export var enemy_name: String = ""
@export var max_hp: float = 30.0
@export var speed: float = 80.0
@export var damage: int = 8
@export var xp_reward: float = 5.0
@export var material_drop_chance: float = 0.2
@export var color: Color = Color.RED
@export var size: float = 12.0
@export var is_elite: bool = false
@export var is_boss: bool = false
```

- [ ] **Step 2: 创建 BaseEnemy 基类**

```gdscript
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
```

- [ ] **Step 3: 创建 BasicEnemy 场景**

在 Godot 编辑器中：
1. 创建 `scenes/enemies/BasicEnemy.tscn`，根节点 `CharacterBody2D`
2. 挂载 `BaseEnemy.gd`
3. 添加 `CollisionShape2D`（CircleShape2D，半径 12）
4. 碰撞层设为 enemy 层
5. 创建 EnemyData 资源：name="Grunt", hp=30, speed=80, damage=8, color=Red

- [ ] **Step 4: 提交**

```bash
git add scripts/resources/EnemyData.gd scripts/enemies/BaseEnemy.gd scenes/enemies/BasicEnemy.tscn
git commit -m "feat: add EnemyData, BaseEnemy, and BasicEnemy"
```

---

### Task 7: GameManager Autoload + 主场景

**Files:**
- Create: `scripts/systems/GameManager.gd`
- Create: `scenes/main.tscn`
- Modify: `project.godot`（添加 Autoload）

- [ ] **Step 1: 创建 GameManager Autoload**

```gdscript
# scripts/systems/GameManager.gd
extends Node

enum GameState { MENU, PLAYING, PAUSED, SHOP, LEVEL_UP, GAME_OVER }

signal wave_changed(wave: int)
signal wave_timer_changed(time_left: float)
signal game_state_changed(state: GameState)
signal enemy_killed(enemy_data: EnemyData, position: Vector2, is_elite: bool, is_boss: bool)

var current_state: GameState = GameState.MENU
var current_wave: int = 1
var wave_timer: float = 0.0
var wave_duration: float = 0.0
var enemies_to_spawn: int = 0
var enemies_spawned: int = 0
var spawn_timer: float = 0.0
var spawn_interval: float = 1.5
var arena_size: Vector2 = Vector2(800, 600)
var total_kills: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if current_state != GameState.PLAYING:
		return
	wave_timer -= delta
	wave_timer_changed.emit(wave_timer)
	if wave_timer <= 0:
		if current_wave >= 20:
			end_wave()
		else:
			end_wave()

func start_game() -> void:
	current_wave = 1
	total_kills = 0
	change_state(GameState.PLAYING)
	start_wave()

func start_wave() -> void:
	wave_duration = 20.0 + current_wave * 2.0
	wave_timer = wave_duration
	enemies_to_spawn = 8 + current_wave * 2
	enemies_spawned = 0
	spawn_interval = maxf(0.3, 1.5 - current_wave * 0.05)
	spawn_timer = 0.0
	wave_changed.emit(current_wave)

func end_wave() -> void:
	if current_wave >= 20:
		change_state(GameState.GAME_OVER)
		return
	change_state(GameState.SHOP)
	current_wave += 1

func start_next_wave() -> void:
	change_state(GameState.PLAYING)
	start_wave()

func change_state(new_state: GameState) -> void:
	current_state = new_state
	game_state_changed.emit(new_state)
	if new_state == GameState.PLAYING:
		get_tree().paused = false
	else:
		get_tree().paused = true

func on_enemy_killed(enemy: BaseEnemy) -> void:
	total_kills += 1
	enemy_killed.emit(enemy.enemy_data, enemy.global_position,
			enemy.enemy_data.is_elite, enemy.enemy_data.is_boss)

func get_random_spawn_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	var center = player.global_position if player else Vector2(400, 300)
	var angle = randf() * TAU
	var distance = randf_range(300, 500)
	return center + Vector2.RIGHT.rotated(angle) * distance
```

- [ ] **Step 2: 注册 Autoload**

在 `project.godot` 中添加 Autoload：

```ini
[autoload]

GameManager="*res://scripts/systems/GameManager.gd"
```

- [ ] **Step 3: 创建主场景**

在 Godot 编辑器中：
1. 创建 `scenes/main.tscn`，根节点 `Node2D`
2. 添加 `ColorRect` 背景（黑色或深灰，1024×768）
3. 添加 `Camera2D`（设置为 current）
4. 子场景化 Player 实例
5. 添加 `Timer` 用于敌人生成
6. 在 `_ready` 中调用 `GameManager.start_game()`

主场景脚本挂载在根节点：

```gdscript
# (attached to main.tscn root Node2D)
extends Node2D

@onready var player = $Player
@onready var spawn_timer = $SpawnTimer

var enemy_scenes = {
	"basic": preload("res://scenes/enemies/BasicEnemy.tscn"),
	"charger": preload("res://scenes/enemies/ChargerEnemy.tscn"),
	"ranged": preload("res://scenes/enemies/RangedEnemy.tscn")
}

func _ready() -> void:
	GameManager.game_state_changed.connect(_on_game_state_changed)
	GameManager.enemy_killed.connect(_on_enemy_killed)
	_give_starter_weapon()
	# MainMenu 的 Start 按钮负责调用 GameManager.start_game()

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

func spawn_enemy() -> void:
	var pos = GameManager.get_random_spawn_position()
	var enemy_type = "basic"
	var is_elite = false
	if GameManager.current_wave in [5, 10, 15] and randf() < 0.3:
		is_elite = true
	var roll = randf()
	if GameManager.current_wave >= 10 and roll < 0.15:
		enemy_type = "ranged"
	elif GameManager.current_wave >= 5 and roll < 0.3:
		enemy_type = "charger"
	var enemy = enemy_scenes[enemy_type].instantiate()
	enemy.global_position = pos
	if is_elite:
		enemy.enemy_data = enemy.enemy_data.duplicate()
		enemy.enemy_data.is_elite = true
		enemy.scale = Vector2(1.5, 1.5)
	add_child(enemy)
	GameManager.enemies_spawned += 1

func _on_game_state_changed(state: GameManager.GameState) -> void:
	match state:
		GameManager.GameState.SHOP:
			# show shop UI
			pass

func _on_enemy_killed(ed: EnemyData, pos: Vector2, is_elite: bool, is_boss: bool) -> void:
	_spawn_xp_drop(pos, ed.xp_reward)
	if randf() < ed.material_drop_chance or is_elite or is_boss:
		_spawn_material_drop(pos, 1 + int(is_elite) * 2 + int(is_boss) * 5)

func _spawn_xp_drop(pos: Vector2, amount: float) -> void:
	var drop = Area2D.new()
	drop.add_to_group("xp_drops")
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 5
	drop.add_child(shape)
	var rect = ColorRect.new()
	rect.size = Vector2(8, 8)
	rect.color = Color.GREEN
	rect.position = -rect.size / 2
	drop.add_child(rect)
	drop.global_position = pos
	drop.set_meta("xp_amount", amount)
	drop.body_entered.connect(func(b): if b.is_in_group("player"): _collect_xp(drop)))
	add_child(drop)

func _spawn_material_drop(pos: Vector2, amount: int) -> void:
	var drop = Area2D.new()
	drop.add_to_group("material_drops")
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 6
	drop.add_child(shape)
	var rect = ColorRect.new()
	rect.size = Vector2(10, 10)
	rect.color = Color.YELLOW
	rect.position = -rect.size / 2
	drop.add_child(rect)
	drop.global_position = pos
	drop.set_meta("material_amount", amount)
	drop.body_entered.connect(func(b): if b.is_in_group("player"): _collect_material(drop)))
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
```

- [ ] **Step 4: 提交**

```bash
git add scripts/systems/GameManager.gd scenes/main.tscn project.godot
git commit -m "feat: add GameManager autoload and main arena scene"
```

---

### Task 8: HUD

**Files:**
- Create: `scripts/ui/HUD.gd`
- Create: `scenes/ui/HUD.tscn`

- [ ] **Step 1: 创建 HUD 脚本**

```gdscript
# scripts/ui/HUD.gd
class_name HUD
extends CanvasLayer

@onready var hp_bar: ProgressBar = $Panel/HBox/HPBar
@onready var hp_label: Label = $Panel/HBox/HPBar/HP_Label
@onready var xp_bar: ProgressBar = $Panel/HBox/XPBar
@onready var wave_label: Label = $Panel/HBox/WaveLabel
@onready var timer_label: Label = $Panel/HBox/TimerLabel
@onready var material_label: Label = $Panel/HBox/MaterialLabel
@onready var kill_label: Label = $Panel/HBox/KillLabel

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.stats.hp_changed.connect(_on_hp_changed)
		player.stats.died.connect(_on_player_died)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.wave_timer_changed.connect(_on_wave_timer)
	GameManager.game_state_changed.connect(_on_state_changed)

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	xp_bar.max_value = player.stats.xp_to_next
	xp_bar.value = player.stats.xp
	material_label.text = "Mat: %d" % player.stats.materials
	kill_label.text = "Kills: %d" % GameManager.total_kills

func _on_hp_changed(current: float, max_hp: float) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current
	hp_label.text = "%d / %d" % [int(current), int(max_hp)]

func _on_wave_changed(wave: int) -> void:
	wave_label.text = "Wave: %d/20" % wave

func _on_wave_timer(time_left: float) -> void:
	timer_label.text = "%d s" % int(time_left)

func _on_state_changed(state: GameManager.GameState) -> void:
	visible = (state == GameManager.GameState.PLAYING)

func _on_player_died() -> void:
	pass
```

- [ ] **Step 2: 创建 HUD 场景**

在 Godot 编辑器中：
1. 创建 `scenes/ui/HUD.tscn`，根节点 `CanvasLayer`
2. 挂载 `HUD.gd`
3. 添加 `Panel`（顶部水平）包含：
   - `HPBar`（ProgressBar，红色）
   - `XPBar`（ProgressBar，绿色）
   - `WaveLabel`（Label）
   - `TimerLabel`（Label）
   - `MaterialLabel`（Label）
   - `KillLabel`（Label）

- [ ] **Step 3: 提交**

```bash
git add scripts/ui/HUD.gd scenes/ui/HUD.tscn
git commit -m "feat: add HUD with HP, XP, wave timer, materials"
```

---

### Task 9: LevelUpUI

**Files:**
- Create: `scripts/ui/LevelUpUI.gd`
- Create: `scenes/ui/LevelUpUI.tscn`

- [ ] **Step 1: 创建 LevelUpUI 脚本**

```gdscript
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
```

- [ ] **Step 2: 创建 LevelUpUI 场景**

在 Godot 编辑器中：
1. 创建 `scenes/ui/LevelUpUI.tscn`，根节点 `CanvasLayer`
2. 挂载 `LevelUpUI.gd`
3. 添加 `ColorRect`（全屏半透明遮罩 `Color(0,0,0,0.5)`）
4. 添加居中 `Panel` 含 `VBoxContainer`（用于放置升级选项按钮）

- [ ] **Step 3: 提交**

```bash
git add scripts/ui/LevelUpUI.gd scenes/ui/LevelUpUI.tscn
git commit -m "feat: add level-up UI with random stat choices"
```

---

### Task 10: ShopUI

**Files:**
- Create: `scripts/resources/ItemData.gd`
- Create: `scripts/ui/ShopUI.gd`
- Create: `scenes/ui/ShopUI.tscn`

- [ ] **Step 1: 创建 ItemData Resource**

```gdscript
# scripts/resources/ItemData.gd
class_name ItemData
extends Resource

@export var item_name: String = ""
@export var description: String = ""
@export var price: int = 20
@export var stat_mod: String = ""
@export var amount: float = 0.0
@export var stackable: bool = true
@export var max_stacks: int = 999
```

- [ ] **Step 2: 创建 ShopUI 脚本**

```gdscript
# scripts/ui/ShopUI.gd
class_name ShopUI
extends CanvasLayer

@onready var items_container: HBoxContainer = $Panel/HBox
@onready var refresh_btn: Button = $Panel/RefreshBtn
@onready var close_btn: Button = $Panel/CloseBtn

var current_offers: Array = []  # [Variant(ItemData) or WeaponData]

var all_items: Array[ItemData]
var all_weapons: Array[WeaponData]
var refresh_cost: int = 1

func _ready() -> void:
	GameManager.game_state_changed.connect(_on_state_changed)
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
	# 手动创建武器数据以供商店出售
	var pistoldata = WeaponData.new()
	pistoldata.weapon_name = "Pistol"
	pistoldata.base_damage = 10.0; pistoldata.attack_speed = 1.0
	pistoldata.range = 300.0; pistoldata.projectile_speed = 400.0
	pistoldata.projectile_color = Color.YELLOW
	all_weapons.append(pistoldata)

func _on_state_changed(state: GameManager.GameState) -> void:
	if state == GameManager.GameState.SHOP:
		generate_offers()
		visible = true
	else:
		visible = false

func generate_offers() -> void:
	current_offers.clear()
	for _i in range(4):
		if randf() < 0.5:
			current_offers.append(all_items.pick_random())
		else:
			current_offers.append(all_weapons.pick_random())
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
	refresh_btn.pressed.connect(_on_refresh)
	close_btn.pressed.connect(_on_close)

func _weapon_level_text(player: Player, wd: WeaponData) -> String:
	for w in player.weapons:
		if w.weapon_data.weapon_name == wd.weapon_name:
			return "(Lv.%d → Lv.%d)" % [w.weapon_data.level, w.weapon_data.level + 1]
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
	return Pistol.new()

func _on_refresh() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.stats.materials >= refresh_cost:
		player.stats.materials -= refresh_cost
		generate_offers()

func _on_close() -> void:
	GameManager.start_next_wave()
```

- [ ] **Step 3: 创建 ShopUI 场景**

在 Godot 编辑器中：
1. 创建 `scenes/ui/ShopUI.tscn`，根节点 `CanvasLayer`
2. 挂载 `ShopUI.gd`
3. 添加全屏半透明遮罩 `ColorRect`
4. 添加居中 `Panel` → `VBoxContainer`
   - `HBoxContainer`（商品按钮 4 个）
   - `HBoxContainer`（RefreshBtn + CloseBtn）

- [ ] **Step 4: 提交**

```bash
git add scripts/resources/ItemData.gd scripts/ui/ShopUI.gd scenes/ui/ShopUI.tscn
git commit -m "feat: add shop system with items and weapon upgrades"
```

---

### Task 11: 其余武器（Shotgun, Staff, Dagger, Slingshot）

**Files:**
- Create: `scripts/weapons/Shotgun.gd`
- Create: `scripts/weapons/Staff.gd`
- Create: `scripts/weapons/Dagger.gd`
- Create: `scripts/weapons/Slingshot.gd`
- Modify: `scripts/ui/ShopUI.gd`（更新武器池）

- [ ] **Step 1: Shotgun 霰弹枪**

```gdscript
# scripts/weapons/Shotgun.gd
class_name Shotgun
extends BaseWeapon

func attack(target: Node2D) -> void:
	var base_dir = (target.global_position - global_position).normalized()
	var spread = weapon_data.spread_angle
	for i in range(weapon_data.projectile_count):
		var angle = deg_to_rad(-spread / 2 + (spread / (weapon_data.projectile_count - 1)) * i) if weapon_data.projectile_count > 1 else 0.0
		var dir = base_dir.rotated(angle)
		var dmg = weapon_data.get_scaled_damage(player.stats.damage_mult)
		spawn_bullet(dir, weapon_data.projectile_speed, dmg,
				weapon_data.projectile_color, weapon_data.piercing, weapon_data.bounce_count)
```

- [ ] **Step 2: Staff 法杖**

```gdscript
# scripts/weapons/Staff.gd
class_name Staff
extends BaseWeapon

func attack(target: Node2D) -> void:
	var dir = (target.global_position - global_position).normalized()
	var dmg = weapon_data.get_scaled_damage(player.stats.damage_mult)
	spawn_bullet(dir, weapon_data.projectile_speed * 0.5, dmg,
			weapon_data.projectile_color, true, weapon_data.bounce_count)
```

- [ ] **Step 3: Dagger 匕首**

```gdscript
# scripts/weapons/Dagger.gd
class_name Dagger
extends BaseWeapon

func attack(target: Node2D) -> void:
	var dir = (target.global_position - global_position).normalized()
	var dmg = weapon_data.get_scaled_damage(player.stats.damage_mult)
	spawn_bullet(dir, weapon_data.projectile_speed * 2.0, dmg,
			weapon_data.projectile_color, weapon_data.piercing, weapon_data.bounce_count)
```

- [ ] **Step 4: Slingshot 弹弓**

```gdscript
# scripts/weapons/Slingshot.gd
class_name Slingshot
extends BaseWeapon

func attack(target: Node2D) -> void:
	var dir = (target.global_position - global_position).normalized()
	var dmg = weapon_data.get_scaled_damage(player.stats.damage_mult)
	spawn_bullet(dir, weapon_data.projectile_speed, dmg,
			weapon_data.projectile_color, weapon_data.piercing, 1)
```

- [ ] **Step 5: 更新 ShopUI 武器池**

在 `ShopUI._setup_weapon_pool` 中添加其余 4 种武器：

```gdscript
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
```

然后在 `_instantiate_weapon` 中添加对应 case。

- [ ] **Step 6: 提交**

```bash
git add scripts/weapons/Shotgun.gd scripts/weapons/Staff.gd scripts/weapons/Dagger.gd scripts/weapons/Slingshot.gd scripts/ui/ShopUI.gd
git commit -m "feat: add all 5 weapons to pool"
```

---

### Task 12: 其余敌人类型 + Boss

**Files:**
- Modify: `scripts/enemies/BaseEnemy.gd`（添加冲锋和远程行为）
- Create: `scenes/enemies/ChargerEnemy.tscn`
- Create: `scenes/enemies/RangedEnemy.tscn`
- Modify: `scenes/main.tscn`（添加 boss 逻辑）

- [ ] **Step 1: 修改 BaseEnemy 支持子类行为**

在 BaseEnemy 中添加虚方法供子类覆盖：

```gdscript
func _physics_process(_delta: float) -> void:
	player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		return
	_move_toward_player(_delta)

func _move_toward_player(_delta: float) -> void:
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * enemy_data.speed
	move_and_slide()
```

- [ ] **Step 2: 创建 ChargerEnemy（覆盖 BaseEnemy 脚本重载 _move_toward_player）**

```gdscript
# (附着于 ChargerEnemy.tscn 的 BaseEnemy 实例的脚本覆盖)
extends BaseEnemy

func _move_toward_player(_delta: float) -> void:
	var dist = global_position.distance_to(player.global_position)
	var effective_speed = enemy_data.speed
	if dist > 200:
		effective_speed = enemy_data.speed * 2.5
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * effective_speed
	move_and_slide()
```

在 Godot 编辑器中：创建 `scenes/enemies/ChargerEnemy.tscn`，复制 BasicEnemy 结构，挂载此覆盖脚本。EnemyData 设为 name="Charger"，color=橙色 `Color.ORANGE`，size=14。`_setup_visual` 中画三角形。

- [ ] **Step 3: 创建 RangedEnemy**

```gdscript
# 附着于 RangedEnemy.tscn，覆盖 BaseEnemy 脚本
extends BaseEnemy

var shoot_cooldown: float = 0.0
var preferred_distance: float = 200.0

func _move_toward_player(_delta: float) -> void:
	var dist = global_position.distance_to(player.global_position)
	if dist > preferred_distance + 50:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * enemy_data.speed
	elif dist < preferred_distance - 50:
		var direction = (global_position - player.global_position).normalized()
		velocity = direction * enemy_data.speed * 0.7
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func _process(delta: float) -> void:
	if not player:
		return
	shoot_cooldown -= delta
	if shoot_cooldown <= 0:
		shoot_cooldown = 2.0
		var bullet = preload("res://scenes/projectiles/Bullet.tscn").instantiate()
		bullet.global_position = global_position
		bullet.direction = (player.global_position - global_position).normalized()
		bullet.speed = 200.0
		bullet.damage = enemy_data.damage
		bullet.color = Color.PURPLE
		bullet.piercing = false
		bullet.bounces = 0
		get_tree().current_scene.add_child(bullet)
```

在 Godot 编辑器中：创建 `scenes/enemies/RangedEnemy.tscn`，EnemyData name="Sniper"，color=紫色 `Color.PURPLE`，size=14。

- [ ] **Step 4: Boss 波逻辑**

在 `scenes/main.tscn` 脚本中添加 boss 生成：

```gdscript
func spawn_enemy() -> void:
	if GameManager.current_wave == 20 and GameManager.enemies_spawned == 0:
		_spawn_boss()
		return
	var pos = GameManager.get_random_spawn_position()
	var enemy_type = "basic"
	if GameManager.current_wave >= 15 and randf() < 0.15:
		enemy_type = "ranged" if randf() < 0.5 else "charger"
	elif GameManager.current_wave >= 5 and randf() < 0.3:
		enemy_type = "charger" if randf() < 0.6 else "ranged"
	var enemy = enemy_scenes[enemy_type].instantiate()
	enemy.global_position = pos
	add_child(enemy)
	GameManager.enemies_spawned += 1

func _spawn_boss() -> void:
	var boss = enemy_scenes["basic"].instantiate()
	boss.enemy_data = _create_boss_data()
	boss.global_position = Vector2(400, 300)  # 从中央出现
	boss.scale = Vector2(3, 3)
	add_child(boss)
	GameManager.enemies_spawned += 1

func _create_boss_data() -> EnemyData:
	var bd = EnemyData.new()
	bd.enemy_name = "Boss"; bd.max_hp = 500.0; bd.speed = 60.0
	bd.damage = 25; bd.xp_reward = 100.0; bd.material_drop_chance = 1.0
	bd.color = Color.RED; bd.size = 36.0; bd.is_boss = true
	return bd
```

- [ ] **Step 5: 提交**

```bash
git add scenes/enemies/ChargerEnemy.tscn scenes/enemies/RangedEnemy.tscn scripts/enemies/BaseEnemy.gd scenes/main.tscn
git commit -m "feat: add Charger, Ranged enemies and Boss wave"
```

---

### Task 13: 掉落物磁铁 + GameOver/胜利逻辑 + 主菜单

**Files:**
- Modify: `scenes/main.tscn`（掉落物吸附）
- Create: `scripts/ui/GameOverUI.gd` + `scenes/ui/GameOverUI.tscn`
- Create: `scripts/ui/MainMenuUI.gd` + `scenes/ui/MainMenuUI.tscn`

- [ ] **Step 1: 掉落物磁铁**

在主场景 `_process` 中添加磁铁逻辑：

```gdscript
func _process(_delta: float) -> void:
	# ... 现有代码 ...
	_magnet_drops(_delta)

func _magnet_drops(delta: float) -> void:
	if not player:
		return
	for group_name in ["xp_drops", "material_drops"]:
		for drop in get_tree().get_nodes_in_group(group_name):
			if drop.get_meta("spawn_time", 0.0) == 0.0:
				drop.set_meta("spawn_time", Time.get_ticks_msec() / 1000.0)
			var age = Time.get_ticks_msec() / 1000.0 - drop.get_meta("spawn_time")
			if age < 0.5:
				continue
			var dir = (player.global_position - drop.global_position).normalized()
			var dist = player.global_position.distance_to(drop.global_position)
			var speed = clampf(500.0 / maxf(dist, 1), 100, 500)
			drop.global_position += dir * speed * delta
```

- [ ] **Step 2: GameOverUI**

```gdscript
# scripts/ui/GameOverUI.gd
class_name GameOverUI
extends CanvasLayer

@onready var title_label: Label = $Panel/Title
@onready var stats_label: Label = $Panel/Stats
@onready var restart_btn: Button = $Panel/RestartBtn

func _ready() -> void:
	GameManager.game_state_changed.connect(_on_state_changed)
	visible = false

func _on_state_changed(state: GameManager.GameState) -> void:
	if state == GameManager.GameState.GAME_OVER:
		visible = true
		var player = get_tree().get_first_node_in_group("player")
		if GameManager.current_wave > 20:
			title_label.text = "VICTORY!"
		else:
			title_label.text = "DEFEAT"
		stats_label.text = "Waves: %d\nKills: %d\nMaterials: %d" % [
			GameManager.current_wave, GameManager.total_kills,
			player.stats.materials if player else 0
		]
	restart_btn.pressed.connect(func(): get_tree().reload_current_scene())
```

Godot 编辑器中创建 `scenes/ui/GameOverUI.tscn`：CanvasLayer → 全屏遮罩 → 居中 Panel → VBox(title + stats + restart button)

- [ ] **Step 3: MainMenuUI**

```gdscript
# scripts/ui/MainMenuUI.gd
class_name MainMenuUI
extends CanvasLayer

func _ready() -> void:
	var start_btn = $Panel/StartBtn
	start_btn.pressed.connect(func():
		visible = false
		GameManager.start_game()
	)
```

Godot 编辑器中创建 `scenes/ui/MainMenuUI.tscn`：CanvasLayer → 全屏 → 居中 Panel → "土豆兄弟 Roguelike" 标题 + Start 按钮

- [ ] **Step 4: 玩家死亡触发 GameOver**

在 Player 的 `_on_died` 中：

```gdscript
func _on_died() -> void:
	GameManager.change_state(GameManager.GameState.GAME_OVER)
	queue_free()
```

- [ ] **Step 5: 提交**

```bash
git add scenes/main.tscn scripts/ui/GameOverUI.gd scenes/ui/GameOverUI.tscn scripts/ui/MainMenuUI.gd scenes/ui/MainMenuUI.tscn scripts/player/Player.gd
git commit -m "feat: add drop magnet, game over, victory, and main menu"
```

---

### Task 14: 最终集成与验证

- [ ] **Step 1: 确保主场景包含所有 UI 子场景**

主场景 `scenes/main.tscn` 应包含：
```
Node2D (主脚本)
├── Camera2D
├── Player (子场景实例)
├── HUD (子场景实例)
├── ShopUI (子场景实例)
├── LevelUpUI (子场景实例)
├── GameOverUI (子场景实例)
├── MainMenuUI (子场景实例)
└── SpawnTimer (Timer)
```

- [ ] **Step 2: 启动 Godot 编辑器验证**

1. 用 Godot 4.6 打开项目
2. 确认所有场景可正常打开无报错
3. 运行主场景，验证：
   - 主菜单显示 → 点击 Start
   - 玩家 WASD 移动
   - 敌人生成并追踪玩家
   - 武器自动攻击
   - 击杀获得经验 → 升级弹窗
   - 波次结束 → 商店
   - 购买武器/道具生效
   - 死亡/通关显示结算

- [ ] **Step 3: 修复编译错误**

如果 Godot 编辑器报错，逐一排查脚本中的类型引用是否一致。

- [ ] **Step 4: 提交**

```bash
git add -A
git commit -m "feat: final integration, full game loop functional"
```
