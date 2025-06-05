extends PanelContainer
@onready var grid_container: GridContainer = $GridContainer


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
	GameManager.add_effect_to_player(item.get_effect())
	check_items()
	
func _on_buy_button_pressed(item: ShopItem):
	buy_item(item)
	
func _ready():
	var items = grid_container.get_children()
	for item in items:
		var item_buy_button = item.get_node("BuyButton")
		item_buy_button.pressed.connect(func (): _on_buy_button_pressed(item))
