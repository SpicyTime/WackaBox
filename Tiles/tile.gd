class_name Tile
extends Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var should_activate: bool = false

 
	
func flip(direction:int) -> void:
	if direction == 1:
		animated_sprite_2d.play("Flip")
		should_activate = true
	else:
		animated_sprite_2d.play_backwards("Flip")
		should_activate = false
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

func _ready() -> void:
	flip(1)
	
func _on_animation_finished() -> void:
	print(animated_sprite_2d.animation)
	if animated_sprite_2d.animation == "Flip":
		if should_activate:
		
			for child in get_children():
				
				if child.has_method("activate"):
					child.activate()
