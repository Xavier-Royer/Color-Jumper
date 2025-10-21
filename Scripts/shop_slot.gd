extends ColorRect
class_name ShopSlot

var data: Collectible
func setup(_data: Collectible):
	data = _data
	$Icon.texture = _data.icon
	$Name.text = _data.name
	$Price.text = "$" + str(data.price)
