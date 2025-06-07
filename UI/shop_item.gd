class_name ShopItem
extends VBoxContainer
@export var label_text: String = "Item"
@export var texture: Texture = null
@export var base_price: int = 0
@export var upgrade: Constants.UpgradeType = Constants.UpgradeType.STRENGTH
@onready var price: int 
func reset_price() -> void:
	
	price = base_price
	$Price/PriceLabel.text = str(price)
func disable() -> void:
	$BuyButton.disabled = true
	
func enable() -> void:
	$BuyButton.disabled = false

func update_price(value: int) -> void:
	price = value
	$Price/PriceLabel.text = str(value)
func get_upgrade() -> Constants.UpgradeType:
	return upgrade
	
func _ready() -> void:
	price = base_price
	 
	$NameLabel.text = label_text
	$TextureRect.texture = texture
	$Price/PriceLabel.text = str(base_price)
