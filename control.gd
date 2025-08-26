extends Control

var backgroundMoveSpeed 
@onready var backgrounds = [$TextureBG1,$TextureBG2,$TextureBG3,$TextureBG4]

func _process(delta: float) -> void:
	for b in backgrounds:
		if b.position.y > Globals.screenSize.y:
			b.position.y = -1* (Globals.screenSize.y * (len(backgrounds)-1))
		b.position.y += backgroundMoveSpeed*delta 

func resetBackgroundPositions():
	backgroundMoveSpeed = 0
	for i in range(len(backgrounds)):
		backgrounds[i].position.y = (i *Globals.screenSize.y)*-1

func _ready():
	resetBackgroundPositions()
