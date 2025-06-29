class_name Tile
extends Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var should_activate: bool = false
var flipped: bool = false
var hazard_component: Node2D
func flip(component, direction:int) -> void:
	hazard_component = component
	 
	if direction == 1:
		if flipped:
			return
		scale.x = 1
		rotation = 0
		call_deferred("add_child", component)
		
		animated_sprite_2d.call_deferred("play", "Flip")
		if component.has_method("handle_flip"):
			component.call_deferred("handle_flip", 1)
		should_activate = true
		flipped = true
		
		await get_tree().create_timer(5).timeout
		flip(component, 0)
	else:
		scale.x = -1
		animated_sprite_2d.play("Flip")
		if component.has_method("handle_flip"):
			component.handle_flip(0)
		should_activate = false
		flipped = false
		for child in get_children():
			if child.has_method("deactivate"):
				child.deactivate()
		
		 
	#Play flipping sound

func play_sound(path: String, bus: String, volume: float = 10.0, pitch: float = 10.0) -> void:
	var sound_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	sound_player.bus = bus
	sound_player.volume_linear = volume
	sound_player.pitch = pitch
	var sound: AudioStream = load(path)
	sound_player.stream = sound
	get_tree().root.add_child(sound_player)
	sound_player.play()
	await sound_player.finished
	sound_player.queue_free()
 
	
func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "Flip":
		if should_activate:
			for child in get_children():
				if child.has_method("activate"):
					child.activate()
		else:
			remove_child(hazard_component)
