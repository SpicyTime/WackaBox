extends Control
@onready var box: CharacterBody2D = %Box
@onready var player: CharacterBody2D = %Player
@onready var whack_o_meter: TextureProgressBar = $"Main/Meter/VBoxContainer/Whack-O-Meter"
@onready var boxlet_label: Label = $Main/Currency/HBoxContainer/BoxletLabel
var restart: bool = false

func _open_shop():
	$ShopPopup.visible = true
	$ShopPopup.check_items()
	get_tree().paused = true
	$ShopPopup.process_mode = Node.PROCESS_MODE_ALWAYS
	
func _close_shop():
	$ShopPopup.visible = false
	get_tree().paused = false
	

func _ready():
	#Signal Connections
	SignalBus.received_damage.connect(_on_damage_received)
	SignalBus.player_died.connect(_on_player_death)
	SignalBus.box_died.connect(_on_box_death)
	SignalBus.boxlet_count_changed.connect(_on_boxlet_count_changed)
	whack_o_meter.max_value = box.get_node("Health").max_health
	boxlet_label.text = str(GameManager.boxlet_count)
	
func _on_damage_received(damage: int, hurtbox: HurtBox) -> void:
	if hurtbox.get_parent() == box:
		whack_o_meter.value += damage

func _on_player_death():
	$Main.visible = false
	$DeathScreen.visible = true
	GameManager.lives_left -= 1
	if GameManager.lives_left == 0:
		restart = true
		$DeathScreen/VBoxContainer/RestartButton.text = "Restart"
	get_tree().paused = true
	$DeathScreen.process_mode = Node.PROCESS_MODE_ALWAYS
func _on_box_death():
	$Main.visible = false
	$WinScreen.visible = true
	GameManager.win_times += 1
	get_tree().paused = true
	$WinScreen.process_mode = Node.PROCESS_MODE_ALWAYS
func _on_boxlet_count_changed(new_value) -> void:
	boxlet_label.text = str(new_value)
	
func _on_button_pressed() -> void:
	GameManager.advance()
	whack_o_meter.max_value = box.get_node("Health").max_health
	whack_o_meter.value = 0
	$WinScreen.visible = false
	$Main.visible = true
	get_tree().paused = false
func _on_shop_button_pressed() -> void:
	_open_shop()

func _on_exit_shop_pressed() -> void:
	_close_shop()

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	
	if restart:
		GameManager.restart_game()
	else:
		GameManager.reset_game()
	whack_o_meter.max_value = box.get_node("Health").max_health
	whack_o_meter.value = 0
	$DeathScreen.visible = false
	$Main.visible = true
