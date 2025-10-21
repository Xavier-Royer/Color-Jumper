extends Resource

class_name Collectible

@export var type: StringName
@export var id: StringName
@export var name: String
@export var price: int
@export var icon: Texture2D

func _init(_type := "", _id := &"", _name := "", _price := 0, _icon: Texture2D = null) -> void:
	type = _type
	id = _id
	name = _name
	price = _price
	icon = _icon
	
static func from_dict(data: Dictionary) -> Collectible:
	return Collectible.new(
		data["type"],
		data["id"],
		data["name"],
		data["price"],
		load(data["icon"]) as Texture2D
	)
