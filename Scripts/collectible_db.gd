'''
[
{ "type": "skin", "id": "knight_red", "name": "Red Knight", "price": 500,
	  "icon": "res://art/skins/knight_red.png", "tint": "#ff4d4d" },
	
]
'''
class_name CollectibleDB
static var COLLECTIBLES := [
	
	#SKINS
	Collectible.from_dict({ "type": "skin", "id": "spaceship", "name": "Spaceship", "price": 500,
	"icon": "res://Textures/playerskins/spaceship.png" }),
	
	Collectible.from_dict({ "type": "skin", "id": "snowman", "name": "Snowman", "price": 1000,
	"icon": "res://Textures/playerskins/snowman.png" }),
	
	Collectible.from_dict({ "type": "skin", "id": "pigking", "name": "Pig King", "price": 17500,
	"icon": "res://Textures/playerskins/pigking.png" }),
	
	Collectible.from_dict({ "type": "skin", "id": "ghost", "name": "Ghost", "price": 500,
	"icon": "res://Textures/playerskins/ghost.png" }),
	
	Collectible.from_dict({ "type": "skin", "id": "firework", "name": "Firework", "price": 500,
	"icon": "res://Textures/playerskins/firework.png" }),
	
	Collectible.from_dict({ "type": "skin", "id": "cursor", "name": "Cursor", "price": 500,
	"icon": "res://Textures/playerskins/cursor.png" }),
	
	Collectible.from_dict({ "type": "skin", "id": "seventeen", "name": "17", "price": 500,
	"icon": "res://Textures/playerskins/17.png" }),
	
	#TRAILS
	
]

static var OWNED := [
	"snowman",
	"pigking"
]
