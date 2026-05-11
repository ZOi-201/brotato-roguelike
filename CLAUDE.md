# godot_test

Godot 4.6 项目，Jolt Physics 3D，D3D12 渲染。

## GDD（策划案目录）
- 所有策划案放在 `GDD/` 下，格式为 `.md`
- 文件命名：`{编号}_{系统名}.md`，如 `01_核心玩法.md`、`02_战斗系统.md`
- 每个文件描述一个独立系统，包含：目标、核心机制、数值参考、关联系统
- 不要用 Word/PDF 存放策划案

## 项目目录约定
- `scenes/` — 场景文件（`.tscn`）
- `scripts/` — GDScript 脚本（`.gd`）
- `assets/` — 美术、音效等资源
  - `assets/sprites/`
  - `assets/sounds/`
  - `assets/models/`（3D 模型）

目录按需创建，不要提前建空目录。

## 编码约定
- 代码、命令、变量名用英文
- GDScript 规范遵循 `godot-best-practices` skill
- 游戏设计讨论遵循 `game-design-theory` skill

## 用户背景
- Godot 新手，独立游戏开发者
- 重实用轻理论，简单方案优先
- 不要引入不必要的抽象和架构
