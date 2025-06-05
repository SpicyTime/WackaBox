class_name Health
extends Node
@export var max_health: int = 10 : set = set_max_health
@export var health: int = 10 : set = set_health

func set_max_health(value: int):
	max_health = value
	SignalBus.max_health_changed.emit(max_health, self)
	
func set_health(value: int):
	health = value
	SignalBus.health_changed.emit(health, self)
	if health <= 0:
		SignalBus.health_depleted.emit(self)
