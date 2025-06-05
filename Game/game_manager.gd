extends Node

var boxlet_count: int = 0 : set = set_boxlets
@onready var tree_root = get_tree().root
func set_boxlets(new_value: int):
	boxlet_count = new_value
	SignalBus.boxlet_count_changed.emit(new_value)
func add_boxlets(amount: int):
	set_boxlets(boxlet_count + amount)
	
func reset_game():
	var box_health_node: Health = tree_root.get_node("Game/Box/Health")
	box_health_node.max_health += roundi(box_health_node.max_health / 2)
	box_health_node.health = box_health_node.max_health
func add_effect_to_player(effect):
	tree_root.get_node("Game/Player").add_effect(effect)
	
func _ready() -> void:
	#get_tree().root.get_node("Game").get_node("Background").visible = true
	pass
