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
