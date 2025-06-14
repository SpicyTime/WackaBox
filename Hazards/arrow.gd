extends Sprite2D
@export var speed = 0
var direction = Vector2.RIGHT  # or set it to any direction you want

func _on_health_depleted(health_node: Health) -> void:
	if health_node in get_children():
		queue_free()
		
func _ready() -> void:
	SignalBus.health_depleted.connect(_on_health_depleted)
	SignalBus.game_reset.connect(_on_game_reset)
	
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
func _on_game_reset() -> void:
	if is_instance_valid(self):
		queue_free()
