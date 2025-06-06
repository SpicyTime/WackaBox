extends PanelContainer
@onready var grid_container: GridContainer = $GridContainer

func reset_prices():
	for item in grid_container.get_children():
		item.reset_price()
func check_items():
	var items = grid_container.get_children()
	for item in items:
		if item.price > GameManager.boxlet_count:
			item.disable()
		else:
			item.enable()
	
func buy_item(item: ShopItem):
	GameManager.set_boxlets(GameManager.boxlet_count - item.price)
	item.update_price(item.price + roundi(item.price / 2))
	GameManager.add_upgrade_to_player(item.get_upgrade())
	check_items()
	
func _on_buy_button_pressed(item: ShopItem):
	buy_item(item)
	
func _ready():
	SignalBus.game_restart.connect(_on_game_restart)
	var items = grid_container.get_children()
	for item in items:
		var item_buy_button = item.get_node("BuyButton")
		item_buy_button.pressed.connect(func (): _on_buy_button_pressed(item))
func _on_game_restart():
	reset_prices()
