class_name ShopItem
extends VBoxContainer
@export var label_text: String = "Item"
@export var texture: Texture = null
@export var price: int = 0
@export var effect: Constants.PowerupType = Constants.PowerupType.STRENGTH
func disable():
	$BuyButton.disabled = true
	
func enable():
	$BuyButton.disabled = false

func update_price(value: int):
	price = value
	$Price/PriceLabel.text = str(value)
func get_effect() -> Constants.PowerupType:
	return effect
	
func _ready() -> void:
	$NameLabel.text = label_text
	$TextureRect.texture = texture
	$Price/PriceLabel.text = str(price)
	
