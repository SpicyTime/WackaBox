extends AnimatedSprite2D
var despawn_time = 3

func despawn():
	play_backwards("Popup")
	await animation_finished
	queue_free()
	
func _ready() -> void:
	SignalBus.game_reset.connect(_on_game_reset)
	play("Popup")
	await get_tree().create_timer(despawn_time).timeout
	despawn()
	
func _on_frame_changed() -> void:
	if frame == 1:
		$HitBox/CollisionShape2D.disabled = false
	elif frame == 0:
		$HitBox/CollisionShape2D.disabled = true
		
func _on_game_reset() -> void:
	if is_instance_valid(self):
		queue_free()
