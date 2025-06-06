class_name HitBox
extends Area2D

@export var damage: int = 1 : set = set_damage, get = get_damage
@onready var _base_damage: int = damage
func set_damage(value : int):
	damage = value
	
func get_damage() -> int:
	return damage
	
func _ready():
	SignalBus.game_restart.connect(_on_game_restart)
	
func _on_game_restart():
	damage = _base_damage
