class_name HurtBox
extends Area2D

@export var health: Health = null

func _on_area_entered(area: Area2D) -> void:
	if not area is HitBox:
		return
	var hitbox = area as HitBox
	health.set_health(health.health - hitbox.damage)
	SignalBus.received_damage.emit(hitbox.damage, self)
