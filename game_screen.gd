extends CanvasLayer

signal gameOverScreen

@onready var blockScene = preload("res://block.tscn")
@onready var spikeScene = preload("res://spike.tscn")
@onready var area2D = $Objects/Player
@onready var player = $Objects/Player
@onready var movingObjects = $Objects



#player attribuites
var direction = Vector2(0,0)
var speed = 4000
var currentColor
var currentBlock

#game control stuff

#streaks/scroes
var score 
var streak 
var lastJumpStamp = 0 #gameruntime of last jump 

#spawn rates / difficulty
var baseGameSpeed  = 500
var gameSpeed = baseGameSpeed
var spawnRate = .6 # higher spawn rate = less spawn 
var blocksSpawned = 0 
var spikeSpawnRate = 1000  #higher = less common
var rainbowSpawnRate = 100 # higher = less common
var randomColorRate = 100 # higher = less common
var rainbowOver = false
var lastBlockSpawned = null


var gameState = "OVER" #OVER, READY, PLAYING
var gameRunTime = 0 
var screen_size

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
	screen_size = Globals.screenSize #get_viewport().get_visible_rect().size
	player.connect("caughtBlock",_on_block_caught)
	for button in $UI/ColorButtons.get_children():
		button.connect("pressed",changeColor.bind(button.name))
	
	player.connect("screenExited",gameOver)

func playGame():
	lastBlockSpawned = null
	print("playing game")
	streak = 0 
	score = 0 
	$UI/Score.text = str(0) 
	$UI/Streak.text = ""
	gameState = "READY"

func loadGame():
	player.velocity = Vector2(0,0)
	for i in movingObjects.get_children():
		if i.name != "Player":
			i.queue_free()
	movingObjects.position.y = 0 
	
	player.show()
	blocksSpawned = 0 
	currentBlock = null
	changeColor("RED")
	player.rotation =0
	
	#generate first block which the layer is on
	var block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x / 2,screen_size.y * (2.0/3.0))
	block.setColor("RED")
	block.number = blocksSpawned
	blocksSpawned+=1
	
	
	#generates the rest of the starting blocks 
	for i in randi_range(10,12):
		block = blockScene.instantiate()
		block.number = blocksSpawned
		movingObjects.add_child(block)
		block.position = Vector2(randi_range(30,screen_size.x - 35),randi_range(-50,screen_size.y * (2.0/3.0) - 100))
		#block.connect("invalidBlock",spawnBlock)
		block.setColor("RED")
		lastBlockSpawned = block
		blocksSpawned+=1
	
	player.position = Vector2(screen_size.x / 2,screen_size.y * (2.0/3.0))
	
	

func changeColor(newColor):
	
	if newColor == "RAINBOW":
		for i in range(4):
			area2D.set_collision_mask_value(i+1,true)
		player.modulate = Color(0,0,0)
		return
	
	#change the curren block's color
	if currentBlock != null:
		currentBlock.setColor(newColor)
	
	#reset all the other collision layer masks
	for i in range(4):
		area2D.set_collision_mask_value(i+1,false)
	area2D.set_collision_mask_value(colorToNumber[newColor],true)
	
	#change the players color
	player.modulate = colorToRGB[newColor]
	
	

#player captureing block
func _on_block_caught():
	currentBlock = player.blockOn
	direction = Vector2(0,0)
	if currentBlock.get_collision_layer_value(10):
		$RainbowTimer.start()
		changeColor("RAINBOW")
	if rainbowOver:
		rainbowOver = false
		changeColor(currentBlock.blockColor)
	
	if gameState == "PLAYING":
		if gameRunTime - lastJumpStamp < 0.75:
			#streak continues
		
			streak +=1 
			$UI/Streak.text= "X" + str(streak)
			$AnimationPlayer2.play("Streak")
		else:
			#streak ends
			streak = 0 
			$UI/Streak.text = ""

		
		$AnimationPlayer.play("Score")
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		#add 100 / howmuch time u were on block * streak 
		tween.tween_property(self,"score", score + (  (100 /  (max(gameRunTime,0.2)- lastJumpStamp)) * max(streak,1) ),.1)
		
		#score += round(  (100 /  (max(gameRunTime,0.2)- lastJumpStamp)) * max(streak,1) )
		lastJumpStamp = gameRunTime
	
		print("Runtime")
		print(gameRunTime)
		print("last jump time")
		print(lastJumpStamp)
	

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:  #event.is_action_pressed("Tap"):
		var mousePosition = get_viewport().get_mouse_position()
		#ensure its not where the buttons are
		if mousePosition.y < $UI/ColorButtons.position.y and gameState != "OVER":
			#if player.velocity == Vector2(0,0):
			if currentBlock != null:
				#Begin game if in ready position
				if gameState == "READY":
					gameRunTime = 0 
					gameState = "PLAYING"
					$SpawnTimer.start()
					lastJumpStamp = get_process_delta_time()
					gameSpeed = baseGameSpeed
				#update direction vector
				var playerPosition  = player.get_global_position()
				direction = mousePosition-playerPosition
				direction = direction.normalized()
				player.blockOn.collision_layer = 0
				player.blockOn.delete()
				player.blockOn = null
				currentBlock = null
				
				#Change direction of the player to look at mouse
				player.look_at(mousePosition)
				player.rotation += deg_to_rad(90)
				

func _process(delta: float) -> void:
	if gameState == "PLAYING":
		#updates player movement
		player.velocity = speed*direction
		#updates game time and moves background down
		gameRunTime += delta
		gameSpeed += delta
		movingObjects.position.y += delta*gameSpeed
		#update score
		$UI/Score.text = str(score)
		



func spawnBlock():
	var block = blockScene.instantiate()
	movingObjects.call_deferred("add_child",block)
	block.number = blocksSpawned
	blocksSpawned += 1
	block.connect("invalidBlock",spawnBlock)
	
	#set block position
	var blockPosition = Vector2(randi_range(30,screen_size.x-30),randi_range(-200,-250))
	block.set_deferred("global_position", blockPosition)
	
	#spawn a spike connected to the block
	if randi_range(0,spikeSpawnRate/gameRunTime) ==1:
		print("create spike")
		var spike = spikeScene.instantiate()
		movingObjects.call_deferred("add_child",spike)
		spike.number = blocksSpawned
		blocksSpawned += 1
		var firstPosition  = lastBlockSpawned.get_global_position()
		var secondPosition = blockPosition
		#puts the spike half way between itself and the next one
		var spikePosition = (secondPosition-firstPosition)/2 + firstPosition
		spike.set_deferred("global_position", spikePosition)
		

		
	lastBlockSpawned = block
			
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
	
	#random chance of making it a random color
	if randi_range(0,randomColorRate) ==1:
		var colors  = ["RED","GREEN","BLUE","PURPLE"]
		block.setColor(colors[randi_range(0,3)])
	#random chance of making it rainbow
	if randi_range(0,rainbowSpawnRate) ==1 :
		block.setColor("RAINBOW")
	
	
	
	
func gameOver():
	if gameState == "PLAYING":
		$SpawnTimer.stop()
		player.hide()
		gameState = "OVER"
		emit_signal("gameOverScreen")


func _on_spawn_timer_timeout() -> void:
	#should update so that wait time varys + gets faster as game goes on 
	spawnBlock()



func _on_rainbow_timer_timeout() -> void:
	#this should have two timers, first timeout is normal rainbow, and then switches to flashing as a warning
	if currentBlock != null:
		changeColor(currentBlock.blockColor)
	else:
		rainbowOver = true
