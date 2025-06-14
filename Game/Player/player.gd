extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_cool_down: Timer = $SwingCoolDown
@onready var bat_hitbox_collider: CollisionShape2D = $BatHitBox/CollisionShape2D
@onready var _orig_pos = position

const MAX_SPEED = 100
const ACCEL = 560
const FRICTION = 375
var _can_swing: bool = true
var _swinging: bool = false
var _orig_bat_hitbox_pos: Vector2 = Vector2.ZERO
var upgrades_counter: Dictionary
var _base_cooldown_time: float

func clear_upgrades() -> void:
	upgrades_counter.clear()
	
func handle_flip(dir: int) -> void:
	if dir == -1:
		animated_sprite_2d.flip_h = true
		bat_hitbox_collider.position = - _orig_bat_hitbox_pos
		
	elif dir == 1:
		animated_sprite_2d.flip_h = false
		bat_hitbox_collider.position = _orig_bat_hitbox_pos
		
func add_upgrade(upgrade: Constants.UpgradeType):
	if upgrade in upgrades_counter.keys()  :
		upgrades_counter[upgrade] += 1
	else:
		upgrades_counter[upgrade] = 1
	apply_upgrade_effect(upgrade)
	
func apply_upgrade_effect(upgrade):
	if upgrade == Constants.UpgradeType.STRENGTH:
		_add_strength($BatHitBox.base_damage * pow(1.5, upgrades_counter[upgrade]))
	elif upgrade == Constants.UpgradeType.SWING_SPEED:
		_reduce_swing_speed(0.15)
 
func _add_strength(amount: int):
	$BatHitBox.damage = amount 
	
func _reduce_swing_speed(amount: float):
	$SwingCoolDown.wait_time -= $SwingCoolDown.wait_time *  amount
	
func _get_input_vector() -> Vector2:
	var input_vector = Vector2.ZERO
	#Gets the direction for the player
	if Input.is_action_pressed("Up"):
		input_vector.y -= 1
	elif Input.is_action_pressed("Down"):
		input_vector.y += 1
	if Input.is_action_pressed("Right"):
		input_vector.x += 1
	elif Input.is_action_pressed("Left"):
		input_vector.x -= 1
	return input_vector
func _ready() -> void:
	_orig_bat_hitbox_pos = bat_hitbox_collider.position
	_base_cooldown_time = get_node("SwingCoolDown").wait_time
	SignalBus.health_depleted.connect(_on_health_depleted)
	SignalBus.game_restart.connect(_on_game_restart)
	SignalBus.game_reset.connect(_on_game_reset)
	
func _physics_process(delta: float) -> void:
	var input_vector = _get_input_vector()
	handle_flip(input_vector.x)
	
	if Input.is_action_just_pressed("Swing"):
		if _can_swing: 
			_can_swing = false
			_swinging = true
			swing_cool_down.start()
			animated_sprite_2d.play("Swing")   
			 
	input_vector = input_vector.normalized()
 	
	# Apply acceleration or friction
	if input_vector != Vector2.ZERO :
		if not _swinging:
			animated_sprite_2d.play("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCEL * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	if velocity == Vector2.ZERO and not _swinging:
		animated_sprite_2d.play("Idle")
		
	move_and_slide()
	
func _on_health_depleted(health_node):
	if health_node in get_children():
		SignalBus.player_died.emit()
		
func _on_game_restart():
	clear_upgrades()
	$SwingCoolDown.wait_time = _base_cooldown_time
	
func _on_game_reset():
	position = _orig_pos
	
func _on_swing_cool_down_timeout() -> void:
	_can_swing = true
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "Swing":
		bat_hitbox_collider.disabled = true
		_swinging = false
		
func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite_2d.frame == 2:
		bat_hitbox_collider.disabled = false
