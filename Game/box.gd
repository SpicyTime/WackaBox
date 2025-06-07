extends StaticBody2D
var spikes_packed = preload("res://Hazards/spikes.tscn")
var _min_boxlets: int = 1
var _max_boxlets: int = 100
var _boxlet_spawn_chance: float = 1
var _swing_count: int = 0
var _acceptable_swing_count: int = 0
var _falloff: float = 0.5

func handle_hit(damage):
	if _should_drop_boxlets():
		var amount = _pick_weighted_list()
		GameManager.add_boxlets(amount)
	_swing_count += 1
	if _should_spawn_spikes():
		spawn_spikes(GameManager.get_player_position())
		
func spawn_spikes(new_position):
	var spikes = spikes_packed.instantiate()
	spikes.position = new_position
	_swing_count = 0
	get_tree().root.call_deferred("add_child", spikes)
	
func _pick_weighted_list() -> int:
	var weights: Array = []
	var total_weight: float = 0.0
	for i in range(_min_boxlets, _max_boxlets + 1):
		var weight = pow(_falloff, i - _min_boxlets)
		weights.append(weight)
		total_weight += weight
	
	var rand = randf() * total_weight
	var running_total = 0.0
	for i in range(weights.size()):
		running_total += weights[i]
		if rand <= running_total:
			return _min_boxlets + i
	return _max_boxlets
func _should_spawn_spikes() -> bool:
	if _swing_count >= _acceptable_swing_count : #and GameManager.win_times > 2:
		return true
	else:
		_swing_count = 0
		return false
		
 
		
func _should_drop_boxlets() -> bool:
	return randf() < _boxlet_spawn_chance

	
func _ready() -> void:
	SignalBus.received_damage.connect(_on_received_damage)
	SignalBus.health_depleted.connect(_on_health_depleted)
	
func _on_received_damage(damage: int, hurtbox: HurtBox) -> void:
	if hurtbox in get_children():
		handle_hit(damage)
		
func _on_health_depleted(health_node: Health):
	if health_node in get_children():
		SignalBus.box_died.emit()
