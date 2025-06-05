extends Node2D

signal gameOverScreen

@onready var blockScene = preload("res://block.tscn")
@onready var player = $Objects/Player
@onready var movingObjects = $Objects
var currentColor
var currentBlock
var gameState = "OVER" #OVER, READY, PLAYING
var direction = Vector2(0,0)
var velocity = 300
var gameSpeed = 100
var spawnRate = .3 # higher spawn rate = less spawn 
var gameRunTime = 0 

var colorToNumber ={
	"RED": 1,
	"GREEN":2,
	"BLUE":3,
	"PURPLE":4
}

var colorToRGB ={
	"RED": Color(255,0,0),
	"GREEN":Color(0,255,0),
	"BLUE":Color(0,0,255),
	"PURPLE":Color(255,0,255)
}

func _ready() -> void:
	for button in $ColorButtons.get_children():
		button.connect("pressed",changeColor.bind(button.name))
	
	player.connect("screenExited",gameOver)

func playGame():
	print("playing game")
	gameState = "READY"

func loadGame():
	
	for i in movingObjects.get_children():
		if i.name != "Player":
			i.queue_free()
	movingObjects.position.y = 0 
	
	player.show()
	currentBlock = null
	changeColor("RED")
	player.rotation =0
	
	#generate first block which the layer is on
	var block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(240,600) + self.position
	block.setColor("RED")
	
	
	#generates the rest of the starting blocks 
	for i in randi_range(10,15):
		block = blockScene.instantiate()
		movingObjects.add_child(block)
		block.position = Vector2(randi_range(10,470),randi_range(-30,520)) + self.position
		block.setColor("RED")
	
	player.position = Vector2(240,590) + self.position

func changeColor(newColor):
	
	#change the curren block's color
	if currentBlock != null:
		currentBlock.setColor(newColor)
	
	#reset all the other collision layer masks
	for i in range(4):
		player.set_collision_mask_value(i+1,false)
	player.set_collision_mask_value(colorToNumber[newColor],true)
	
	
	
	#change the players color
	player.modulate = colorToRGB[newColor]

#player captureing block
func _on_player_area_entered(area: Area2D) -> void:

	if area.get_collision_layer_value(8):
		currentBlock = area
		direction = Vector2(0,0)



func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:  #event.is_action_pressed("Tap"):
		var mousePosition = get_global_mouse_position()
		#ensure its not where the buttons are
		#this has to be reatlive so will need to add that 
		if mousePosition.y<725:
			if currentBlock != null:
				#Begin game if in ready position
				if gameState == "READY":
					gameRunTime = 0 
					gameState = "PLAYING"
				#update direction vector
		
				var playerPosition  = player.get_global_position()
				direction = mousePosition-playerPosition
				direction = direction.normalized()
		
				#Change direction of the player to look at mouse
				player.look_at(mousePosition)
				player.rotation += deg_to_rad(90)
	

func _process(delta: float) -> void:
	if gameState == "PLAYING":
		gameRunTime += delta
		player.position += velocity*delta*direction
		movingObjects.position.y += delta*gameSpeed
		
		if randi_range(0,spawnRate/delta) == 1:
			spawnBlock()
		
		



func _on_player_area_exited(area: Area2D) -> void:
	if area == currentBlock:
		currentBlock.queue_free()
		currentBlock = null

func spawnBlock():
	
	var block = blockScene.instantiate()
	#old code wihtout deffered calls works except for respawning
	#movingObjects.add_child(block)
	#block.global_position = Vector2(randi_range(10,470),randi_range(-40,-20)) #- self.position
	movingObjects.call_deferred("add_child",block)
	block.set_deferred("global_position", Vector2(randi_range(10,470),randi_range(-40,-20)))
	block.connect("invalidBlock",spawnBlock)
	
	#set color 
	#random variance
	var random = randf_range(max(-2,-1*gameRunTime),2)
	#xvalue of the sin function based on run time; a greater constant of muliplication equals higher frequency
	var xvalue = (gameRunTime + random)*.08
	#inner function is x to some power the greater the power the quicker the frequency
	xvalue = pow(xvalue,1.4)
	if sin(xvalue) > 0:
		if cos(xvalue) > 0:
			block.setColor("RED")
		else:
			block.setColor("GREEN")
	else:
		if cos(xvalue) > 0:
			block.setColor("PURPLE")
		else:
			block.setColor("BLUE")
	
	
	
func gameOver():
	if gameState == "PLAYING":
		player.hide()
		gameState = "OVER"
		emit_signal("gameOverScreen")
