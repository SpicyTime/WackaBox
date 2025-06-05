extends StaticBody2D
func _calc_boxlets(damage) -> int:
	var rand = randf()
	if rand > 0.35:
		return damage
	return 0
func _on_received_damage(diff: int, hurtbox: HurtBox):
	if hurtbox in get_children():
		GameManager.add_boxlets(_calc_boxlets(diff))
func _ready() -> void:
	SignalBus.received_damage.connect(_on_received_damage)
