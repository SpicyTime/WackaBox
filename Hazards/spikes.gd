extends AnimatedSprite2D
var despawn_time = 3

func despawn():
	play_backwards("Popup")
	await animation_finished
	queue_free()
	
func _ready() -> void:
	play("Popup")
	await get_tree().create_timer(despawn_time).timeout
	despawn()
	
func _on_frame_changed() -> void:
	if frame == 1:
		$HitBox/CollisionShape2D.disabled = false
	elif frame == 0:
		$HitBox/CollisionShape2D.disabled = true
