class_name ShopItem
extends VBoxContainer
@export var label_text: String = "Item"
@export var texture: Texture = null
@export var base_price: int = 0
@export var max_vert_texture: int
@export var upgrade: Constants.UpgradeType
@onready var price: int 
var times_bought = 0
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
	times_bought += 1
func get_upgrade() -> Constants.UpgradeType:
	return upgrade
	
func _ready() -> void:
	price = base_price
	$NameLabel.text = label_text
	$TextureRect.texture = texture
	$Price/PriceLabel.text = str(base_price)
	var texture_height = $TextureRect.texture.get_height()
	if texture_height < max_vert_texture:
		$TextureRect.texture = pad_texture_vertically($TextureRect.texture, texture_height / 2, texture_height/ 2)
	
func pad_texture_vertically(texture: Texture2D, top: int, bottom: int) -> Texture2D:
	var image := texture.get_image()
	var original_size := image.get_size()

	var new_width := original_size.x
	var new_height := original_size.y + top + bottom

	var new_image := Image.create(new_width, new_height, false, image.get_format())
	new_image.fill(Color(0, 0, 0, 0)) 

	new_image.blit_rect(
		image,
		Rect2i(Vector2i.ZERO, original_size),
		Vector2i(0, top)
	)

	return ImageTexture.create_from_image(new_image)
