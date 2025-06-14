extends CharacterBody2D
@export var speed: float = 100.0
@export var player: CharacterBody2D
@onready var move_cooldown: Timer = $MoveCooldown
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var _orig_pos: Vector2 = position
var spikes_packed: PackedScene = preload("res://Hazards/spikes.tscn")
const _MIN_SCOOT_DISTANCE: int = 40
const _MAX_SCOOT_DISTANCE: int = 80
const _SPIKES_SPAWN_RADIUS: float  = 15
const _HIT_SPEED = 10
const MAX_SPEED = 100
const ACCEL = 560
const FRICTION = 400
var _min_boxlets: int = 1
var _max_boxlets: int = 3
var _swing_count: int = 0
var _acceptable_swing_count: int = 3
var _min_move_cooldown: float = 0.5
var _max_move_cooldown: float = 2
var _falloff: float = 0.5
var _boxlet_spawn_chance: float = 0.5
var _target_position: Vector2 = position
var _dir: Vector2  
var _target_reached: bool = true
var _spikes_spawning: bool = false
var _bounced: bool = false

func add_upgrade(upgrade: Constants.UpgradeType):
	#Other logic
	_apply_upgrade_effect(upgrade)
	
func spawn_spikes(_new_position):
	var spikes = spikes_packed.instantiate()
	_swing_count = 0
	await get_tree().create_timer(randf_range(0.25, 0.75)).timeout
	get_tree().root.call_deferred("add_child", spikes)
	spikes.position = Vector2(player.position.x + randf_range(3, _SPIKES_SPAWN_RADIUS), player.position.y + randf_range(3, _SPIKES_SPAWN_RADIUS))
	
func increase_health():
	var health_node = $Health
	var multiplier = pow(1.75, GameManager.win_times)
	health_node.max_health = health_node.base_health * multiplier
	health_node.health = health_node.max_health
	
func _apply_upgrade_effect(upgrade):
	if upgrade == Constants.UpgradeType.BOXLET_DROP_RATE:
		_increase_drop_rate()
	elif upgrade == Constants.UpgradeType.BOXLET_DROP:
		_increase_boxlet_drop()
	elif upgrade == Constants.UpgradeType.BIGGER_BOXLETS:
		_increase_boxlet_size()
func _increase_drop_rate():
	_boxlet_spawn_chance += 0.05
#increases the falloff making bigger ones more common
func _increase_boxlet_drop():
	_falloff += 0.05
#Increases the min and max drop
func _increase_boxlet_size():
	_min_boxlets += 1
	_max_boxlets += 1
func _handle_spawns():
	if _should_drop_boxlets():
		var amount = _pick_weighted_list()
		GameManager.add_boxlets(amount)
	if not _spikes_spawning:
		_swing_count += 1
	if GameManager.win_times >= 1 and move_cooldown.is_stopped():
		var new_cooldown: float = randf_range(_min_move_cooldown, _max_move_cooldown)
		move_cooldown.wait_time = new_cooldown
		move_cooldown.start()
		
	if _should_spawn_spikes():
		spawn_spikes(player.position)

func _handle_hit():
	velocity = (position - player.position) *  _HIT_SPEED
	_handle_spawns()
		
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
	
func _pick_move_direction():
	var direction_to_player = (player.position - position).normalized()
	var angle_to_player = direction_to_player.angle() * (180 / PI)  # degrees
	
	var angle_away = fposmod(angle_to_player + 180, 360)  # Always in [0, 360]
	var rand_angle = randi_range(angle_away - 90, angle_away + 90)  # 180° arc away
	
	var radian = rand_angle * (PI / 180)
	var move_direction = Vector2(cos(radian), sin(radian))
	return move_direction.normalized()
	
func _should_spawn_spikes() -> bool:
	if _swing_count >= _acceptable_swing_count and GameManager.win_times >= 2:
		return true
	else:
		return false
		
func _should_drop_boxlets() -> bool:
	return randf() < _boxlet_spawn_chance

func _ready() -> void:
	SignalBus.received_damage.connect(_on_received_damage)
	SignalBus.health_depleted.connect(_on_health_depleted)
	SignalBus.game_restart.connect(_on_game_restart)
	SignalBus.game_reset.connect(_on_game_reset)
		
func _physics_process(delta: float) -> void:
	if position.distance_to(_target_position) > 1.0 and not _target_reached:
		_dir = _target_position - position
		_dir = _dir.normalized()
		velocity = velocity.move_toward(_dir * speed, ACCEL * delta)
	else:
		_target_reached = true

	if velocity != Vector2.ZERO:
		var collision = move_and_collide(velocity * delta)
		
		if collision and (not _bounced) :
			var is_wall = collision.get_collider()  in get_tree().get_nodes_in_group("Obstacles")
			var normal = collision.get_normal()
			velocity = velocity.bounce(normal)
			_bounced = true
			var new_mask := player.collision_mask
			new_mask &= ~2 # Turn off bit 1 (player layer)
			player.collision_mask = new_mask
	else:
		if _bounced:
			_bounced = false
			var new_mask := player.collision_mask
			new_mask |= 2  # Turn off bit 1 (player layer)
			player.collision_mask = new_mask
	# Apply friction only when not actively moving toward target
	if _target_reached:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

func _on_received_damage(damage: int, hurtbox: HurtBox) -> void:
	if hurtbox in get_children():
		_handle_hit()
		
func _on_health_depleted(health_node: Health):
	if health_node in get_children():
		SignalBus.box_died.emit()
		
func _on_game_restart():
	_min_boxlets = 1
	_max_boxlets = 3
	_falloff = 0.5
	_boxlet_spawn_chance = 0.5
	position = _orig_pos
	
func _on_game_reset():
	position = _orig_pos
	_target_position = position
	velocity = Vector2.ZERO
	
func _on_move_cooldown_timeout() -> void:
	var scoot_distance = randi_range(_MIN_SCOOT_DISTANCE, _MAX_SCOOT_DISTANCE)
	_target_position = position + _pick_move_direction() * scoot_distance
