'''
[
{ "type": "skin", "id": "knight_red", "name": "Red Knight", "price": 500,
	  "icon": "res://art/skins/knight_red.png", "tint": "#ff4d4d" },
	
]
'''
class_name CollectibleDB
static var COLLECTIBLES := [
	
	#Default Skin in spot 1
	Collectible.from_dict({ "type": "skin", "id": "spaceship", "name": "Spaceship", "price": 0,
	"icon": "res://Textures/playerskins/spaceship.png" }),
	
	#Default trail in spot 2
	Collectible.from_dict({ "type": "trail", "id": "defaulttrail", "name": "Default", "price": 0,
	"icon": "res://Textures/playertrails/default.png" }),
	
	#Default theme in spot 3
	Collectible.from_dict({ "type": "theme", "id": "defaulttheme", "name": "Default", "price": 0,
	"icon": "res://Textures/playerskins/heart.png" }),
	
	
	#SKINS
	Collectible.from_dict({ "type": "skin", "id": "snowman", "name": "Snowman", "price": 50,
	"icon": "res://Textures/playerskins/snowman.png" }),
	
	Collectible.from_dict({ "type": "skin", "id": "firework", "name": "Firework", "price": 50,
	"icon": "res://Textures/playerskins/firework.png" }),
	
	Collectible.from_dict({ "type": "skin", "id": "cursor", "name": "Cursor", "price": 50,
	"icon": "res://Textures/playerskins/cursor.png" }),
	
	Collectible.from_dict({ "type": "skin", "id": "pigking", "name": "Pig King", "price": 250,
	"icon": "res://Textures/playerskins/pigking.png" }),
	
	Collectible.from_dict({ "type": "skin", "id": "ghost", "name": "Ghost", "price": 250,
	"icon": "res://Textures/playerskins/ghost.png" }),
	
	Collectible.from_dict({ "type": "skin", "id": "hearts", "name": "Hearts", "price": 250,
	"icon": "res://Textures/playerskins/heart.png" }),

	Collectible.from_dict({ "type": "skin", "id": "seventeen", "name": "17", "price": 1000,
	"icon": "res://Textures/playerskins/17.png" }),
	
	
	#TRAILS
	Collectible.from_dict({ "type": "trail", "id": "heart", "name": "Hearts", "price": 50,
	"icon": "res://Textures/playertrails/heart.png" }),
	
	Collectible.from_dict({ "type": "trail", "id": "line", "name": "Line", "price": 50,
	"icon": "res://Textures/playertrails/line.png" }),
	
	Collectible.from_dict({ "type": "trail", "id": "plus", "name": "Plus", "price": 50,
	"icon": "res://Textures/playertrails/plus.png" }),
	
	Collectible.from_dict({ "type": "trail", "id": "x", "name": "X", "price": 50,
	"icon": "res://Textures/playertrails/x.png" }),
	
	
	Collectible.from_dict({ "type": "trail", "id": "box", "name": "Box", "price": 250,
	"icon": "res://Textures/playertrails/box.png" }),
	
	Collectible.from_dict({ "type": "trail", "id": "lightning", "name": "Lightning", "price": 250,
	"icon": "res://Textures/playertrails/lightning.png" }),
	

	

	
	Collectible.from_dict({ "type": "trail", "id": "snowflake", "name": "Snowflake", "price": 250,
	"icon": "res://Textures/playertrails/snowflake.png" }),
	
	Collectible.from_dict({ "type": "trail", "id": "star", "name": "Star", "price": 250,
	"icon": "res://Textures/playertrails/star.png" }),
	
	Collectible.from_dict({ "type": "trail", "id": "67", "name": "67", "price": 1000,
	"icon": "res://Textures/playertrails/sixseven.png" }),

	
	#THEMES
	
	
]

#need to store this variable 
static var OWNED := [
	"spaceship",
	"defaulttrail",
	"defaulttheme",
	"snowman",
	"pigking",
	"heart"
]

#need to store this variable 
#doing it by index now because reading filemanger problems 
static var CURRENT := {
	"skin": 0, # COLLECTIBLES[0], #get_default_skin(),
	"trail": 1, #COLLECTIBLES[1],
	"theme": 2, #COLLECTIBLES[2]
}

static func get_default_skin():# -> Collectible:
	return 0
	#return COLLECTIBLES[0]
	
static func get_default_trail():# -> Collectible:
	return 1
	#return COLLECTIBLES[1]
	
static func get_default_theme(): #-> Collectible:
	return 2
	#return COLLECTIBLES[2]
