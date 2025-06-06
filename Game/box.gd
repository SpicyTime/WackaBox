extends StaticBody2D
var spikes_packed = preload("res://Hazards/spikes.tscn")
var acceptable_swing_range: int = 10
var _swing_count: int = 0
var _acceptable_swing_count: int = 0


func handle_hit(damage):
	GameManager.add_boxlets(_calc_boxlets(damage))
	_swing_count += 1
	if _should_spawn_spikes():
		spawn_spikes(GameManager.get_player_position())
		
func spawn_spikes(new_position):
	var spikes = spikes_packed.instantiate()
	spikes.position = new_position
	_swing_count = 0
	get_tree().root.call_deferred("add_child", spikes)
	 
	
func _should_spawn_spikes() -> bool:
	if _swing_count >= _acceptable_swing_count : #and GameManager.win_times > 2:
		return true
	else:
		_swing_count = 0
		return false
		
func _calc_boxlets(damage) -> int:
	return 10
	print(damage)
	var rand = randf()
	if rand > 0.35:
		return damage
	return 0
	

		
func _ready() -> void:
	SignalBus.received_damage.connect(_on_received_damage)
	SignalBus.health_depleted.connect(_on_health_depleted)
	
func _on_received_damage(damage: int, hurtbox: HurtBox) -> void:
	if hurtbox in get_children():
		handle_hit(damage)
		
func _on_health_depleted(health_node: Health):
	if health_node in get_children():
		SignalBus.box_died.emit()
