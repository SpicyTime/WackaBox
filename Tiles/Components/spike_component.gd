extends Node2D
@onready var hitbox_collider: CollisionShape2D = $HitBox/CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func handle_flip()-> void:
	animated_sprite_2d.play("Flip")
	print("Handling Flip")
func activate():
	activate_spikes()
	
func deactivate():
	deactivate_spikes()
	
func activate_spikes() -> void:
	hitbox_collider.disabled = false
	
func deactivate_spikes() -> void:
	hitbox_collider.disabled = true
	
		 
