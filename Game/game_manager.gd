extends Node
@onready var tree_root = get_tree().root
@onready var player = get_tree().root.get_node("Game/Player")
var boxlet_count: int = 0 : set = set_boxlets
var win_times: int = 0
var lives_left: int = 3

func get_player_position() -> Vector2:
	return player.position
	
func set_boxlets(new_value: int) -> void:
	boxlet_count = new_value
	SignalBus.boxlet_count_changed.emit(new_value)
	
func add_boxlets(amount: int) -> void:
	set_boxlets(boxlet_count + amount)
	
func restart_game() -> void:
	SignalBus.game_restart.emit()
	set_boxlets(0)
	lives_left = 3
	win_times = 0

func reset_game() -> void:
	var spikes = get_tree().get_nodes_in_group("Spikes")
	for spike in spikes:
		spike.queue_free()
	
func advance():
	var box_health_node: Health = tree_root.get_node("Game/Box/Health")
	box_health_node.max_health += roundi(box_health_node.max_health / 2)
	box_health_node.health = box_health_node.max_health
	reset_game()
func add_upgrade_to_player(upgrade) -> void:
	player.add_upgrade(upgrade)
