extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_cool_down: Timer = $SwingCoolDown
@onready var bat_hitbox_collider: CollisionShape2D = $BatHitBox/CollisionShape2D

const MAX_SPEED = 100
const ACCEL = 560
const FRICTION = 375
var _can_swing: bool = true
var _swinging: bool = false
var _orig_bat_hitbox_pos: Vector2 = Vector2.ZERO
var effect_counter: Dictionary
func add_effect(effect: Constants.PowerupType):
	if effect in effect_counter.keys()  :
		effect_counter[effect] += 1
	else:
		effect_counter[effect] = 1
	if effect == Constants.PowerupType.STRENGTH:
		_add_strength(3)
	elif effect == Constants.PowerupType.SWING_SPEED:
		_reduce_swing_speed(0.15)
func _add_strength(amount: int):
	$BatHitBox.damage += amount
	
func _reduce_swing_speed(amount: float):
	$SwingCoolDown.wait_time -= $SwingCoolDown.wait_time *  amount
func handle_flip(dir: int) -> void:
	if dir == -1:
		animated_sprite_2d.flip_h = true
		bat_hitbox_collider.position = - _orig_bat_hitbox_pos
		
	elif dir == 1:
		animated_sprite_2d.flip_h = false
		bat_hitbox_collider.position = _orig_bat_hitbox_pos
func _ready() -> void:
	_orig_bat_hitbox_pos = bat_hitbox_collider.position
func _physics_process(delta: float) -> void:
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
	handle_flip(input_vector.x)
	if Input.is_action_just_pressed("Swing"):
		if _can_swing: 
			_can_swing = false
			_swinging = true
			swing_cool_down.start()
			animated_sprite_2d.play("Swing")   
			bat_hitbox_collider.disabled = false    
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

func _on_swing_cool_down_timeout() -> void:
	_can_swing = true
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "Swing":
		bat_hitbox_collider.disabled = true
		_swinging = false
