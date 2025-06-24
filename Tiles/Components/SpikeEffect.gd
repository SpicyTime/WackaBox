extends Node2D
@export var animation_frames: SpriteFrames
@onready var hitbox_collider: CollisionShape2D = $HitBox/CollisionShape2D
	
func activate():
	activate_spikes()
	print("Activating")
func deactivate():
	deactivate_spikes()
	
func activate_spikes() -> void:
	hitbox_collider.disabled = false
	
func deactivate_spikes() -> void:
	hitbox_collider.disabled = true
	
func _ready() -> void:
	var parent = get_parent()
	if parent is Tile:
		parent.get_child(1).sprite_frames = animation_frames
		 
