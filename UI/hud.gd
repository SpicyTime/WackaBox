extends Control
@onready var box: StaticBody2D = %Box
@onready var whack_o_meter: TextureProgressBar = $"Main/Meter/VBoxContainer/Whack-O-Meter"
@onready var boxlet_label: Label = $Main/Currency/HBoxContainer/BoxletLabel

func _open_shop():
	$ShopPopup.visible = true
	$ShopPopup.check_items()
	get_tree().paused = true
	$ShopPopup.process_mode = Node.PROCESS_MODE_ALWAYS
	
func _close_shop():
	$ShopPopup.visible = false
	get_tree().paused = false
	
func _on_damage_received(damage: int, hurtbox: HurtBox) -> void:
	if hurtbox.get_parent() == box:
		whack_o_meter.value += damage

func _on_health_depleted(health_node: Health) -> void:
	if health_node.get_parent() == box:
		$Main.visible = false
		$WinScreen.visible = true
		
func _on_boxlet_count_changed(new_value) -> void:
	 
	boxlet_label.text = str(new_value)
func _ready():
	#Signal Connections
	SignalBus.received_damage.connect(_on_damage_received)
	SignalBus.health_depleted.connect(_on_health_depleted)
	SignalBus.boxlet_count_changed.connect(_on_boxlet_count_changed)
	whack_o_meter.max_value = box.get_node("Health").max_health
	boxlet_label.text = str(GameManager.boxlet_count)
	
func _on_button_pressed() -> void:
	GameManager.reset_game()
	whack_o_meter.max_value = box.get_node("Health").max_health
	whack_o_meter.value = 0
	$WinScreen.visible = false
	$Main.visible = true


func _on_shop_button_pressed() -> void:
	_open_shop()

func _on_exit_shop_pressed() -> void:
	_close_shop()
