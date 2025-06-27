extends CanvasLayer

signal gameOverScreen

@onready var blockScene = preload("res://block.tscn")
@onready var spikeScene = preload("res://spike.tscn")
@onready var area2D = $Objects/Player
@onready var player = $Objects/Player
@onready var movingObjects = $Objects


#player attribuites
var direction = Vector2(0,0)
var speed = 7000
var currentColor
var currentBlock
var difficulty = "EASY" #easy, medium, hard or extreme
var difficulties = ["EASY", "MEDIUM" , "HARD", "EXTREME"]
#game control stuff

#streaks/scroes
var trueScore
var score 
var streak 
var lastJumpStamp = 0 #gameruntime of last jump 

#spawn rates / difficulty
var baseGameSpeed  = 200
var gameSpeed = baseGameSpeed
var spawnRate = .6 # higher spawn rate = less spawn 
var blocksSpawned = 0 
var spikeSpawnRate = 50  #higher = less common
var rainbowSpawnRate = 200 # higher = less common
var randomColorRate = 3 # higher = less common
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

#rainbowFlashAnimationVariables
var flashCount =0  

func _ready() -> void:
	screen_size = Globals.screenSize #get_viewport().get_visible_rect().size
	player.connect("caughtBlock",_on_block_caught)
	for button in $UI/ColorButtons.get_children():
		button.connect("pressed",changeColor.bind(button.name))
	player.connect("screenExited",gameOver)
	var tween = create_tween().set_loops()
	tween.tween_property($UI/TouchAnywhereText, "scale", Vector2(1.1, 1.1), 0.1).set_ease(Tween.EASE_IN)
	tween.tween_property($UI/TouchAnywhereText, "scale", Vector2(1, 1), 0.4).set_ease(Tween.EASE_OUT)
	var tween2 = create_tween().set_loops()

	tween2.tween_property($UI/Logo, "position:y", $UI/Logo.position.y + 50, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween2.tween_property($UI/Logo, "position:y", $UI/Logo.position.y, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	loadGame()
	playGame()

func playGame():
	lastBlockSpawned = null
	print("playing game")
	streak = 0 
	score = 0 
	$UI/Score.text = str(0) 
	$UI/Streak.text = ""
	
	difficulty = FileManager.difficulty
	
	gameState = "READY"
	if difficulty == "EASY":
		randomColorRate = 50
		baseGameSpeed  = 700
	elif difficulty == "MEDIUM":
		randomColorRate = 30
		baseGameSpeed  = 500
	elif difficulty == "HARD":
		randomColorRate = 10
		baseGameSpeed  = 300
	else:
		baseGameSpeed  = 200
		randomColorRate = 3

func loadGame():
	player.velocity = Vector2(0,0)
	for i in movingObjects.get_children():
		if i.name != "Player" and i.name != "Trail":
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
	block.connect("nextColor", nextColor)
	blocksSpawned+=1
	
	
	#generates the rest of the starting blocks 
	for i in randi_range(10,12):
		block = blockScene.instantiate()
		block.number = blocksSpawned
		movingObjects.add_child(block)
		block.position = Vector2(randi_range(30,screen_size.x - 35),randi_range(-50,screen_size.y * (2.0/3.0) - 100))
		#block.connect("invalidBlock",spawnBlock)
		block.setColor("RED")
		block.connect("nextColor", nextColor)
		lastBlockSpawned = block
		blocksSpawned+=1
	
	player.position = Vector2(screen_size.x / 2,screen_size.y * (2.0/3.0))
	
	

func changeColor(newColor):
	
	if newColor == "RAINBOW":
		for i in range(4):
			area2D.set_collision_mask_value(i+1,true)
		player.modulate = Color(1,1,1)
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
	currentBlock.blockCaught(direction,gameSpeed)
	direction = Vector2(0,0)
	if currentBlock.get_collision_layer_value(10):
		$RainbowTimer.start()
		$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",true)
		changeColor("RAINBOW")
	if rainbowOver:
		rainbowOver = false
		$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",false)
		changeColor(currentBlock.blockColor)
	
	if gameState == "PLAYING":
		if gameRunTime - lastJumpStamp < 0.75:
			#streak continues
		
			streak +=1 
			$UI/Streak.text= "X" + str(streak)
			$StreakAnimation.play("Streak")
		else:
			#streak ends
			streak = 0 
			$UI/Streak.text = ""

		
		$ScoreAnimation.play("Score")
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		#add 20 / howmuch time u were on block * streak 
		tween.tween_property(self,"score", score + (  (20 /  (max(gameRunTime,0.2)- lastJumpStamp)) * max(streak,1) ),.1)
		
		#score += round(  (100 /  (max(gameRunTime,0.2)- lastJumpStamp)) * max(streak,1) )
		lastJumpStamp = gameRunTime
	
	

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:  #event.is_action_pressed("Tap"):
		var mousePosition = get_viewport().get_mouse_position()
		#ensure its not where the buttons are
		if mousePosition.y < $UI/ColorButtons.position.y and gameState != "OVER" and  not ( mousePosition.y < $UI/Settings.position.y +$UI/Settings.size.y  and mousePosition.x >$UI/Settings.position.x):
			
			#if player.velocity == Vector2(0,0):
			if currentBlock != null:
				#Begin game if in ready position
				if gameState == "READY":
					gameRunTime = 0 
					gameState = "PLAYING"
					$SpawnTimer.start()
					lastJumpStamp = get_process_delta_time()
					gameSpeed = baseGameSpeed
					#$"../HomeScreen".hide()
					$UI/TouchAnywhereText.hide()
					var tween = create_tween()
					tween.tween_property($UI/Logo, "modulate:a", 0.0, 0.5)
					var tween2 = create_tween()
					tween2.tween_property($UI/Settings, "modulate:a", 0.0, 0.5)
					
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
		gameSpeed = baseGameSpeed + 100*(log(gameRunTime))
		#gameSpeed += delta
		movingObjects.position.y += delta*gameSpeed
		#update score
		$UI/Score.text = str(score)
		



func spawnBlock():
	var block = blockScene.instantiate()
	movingObjects.call_deferred("add_child",block)
	block.number = blocksSpawned
	blocksSpawned += 1
	block.connect("invalidBlock",spawnBlock)
	block.connect("nextColor", nextColor)
	
	#set block position
	var blockPosition = Vector2(randi_range(30,screen_size.x-30),randi_range(-200,-250))
	block.set_deferred("global_position", blockPosition)
	
	#spawn a spike connected to the block
	if randi_range(0,spikeSpawnRate/gameRunTime) ==1 and lastBlockSpawned != null:
		print("create spike")
		var spike = spikeScene.instantiate()
		movingObjects.call_deferred("add_child",spike)
		spike.number = blocksSpawned
		blocksSpawned += 1
		
		var firstPosition  = lastBlockSpawned.get_global_position()
		var secondPosition = blockPosition
		
		var line = Line2D.new()
		movingObjects.call_deferred("add_child",line)
		print(firstPosition)
		line.call_deferred("add_point",firstPosition - Vector2(0,movingObjects.position.y))
		line.call_deferred("add_point",secondPosition - Vector2(0,movingObjects.position.y))
		#line.add_point(firstPosition+Vector2(0,-10))
		#line.add_point(secondPosition+Vector2(0,-10))
		
		
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
		print("RIANBOW")
	
	
	
	
func gameOver():
	if gameState == "PLAYING":
		$SpawnTimer.stop()
		player.hide()
		gameState = "OVER"
		$"../GameOverScreen/UI/VBoxContainer/Score".text = "Score: " + str(score)
		var index = difficulties.find(difficulty)
		var currentHighScore = FileManager.highScore[index]
		if score > currentHighScore:
			currentHighScore = score
			FileManager.setHighScore(score,index)
		$"../GameOverScreen/UI/VBoxContainer/Highscore".text = "High Score: " + str(currentHighScore)
		emit_signal("gameOverScreen")



func _on_spawn_timer_timeout() -> void:
	#should update so that wait time varys + gets faster as game goes on 
	spawnBlock()



func _on_rainbow_timer_timeout() -> void:
	$FlashTimer.wait_time = 0.3
	$FlashTimer.start()
	#this should have two timers, first timeout is normal rainbow, and then switches to flashing as a warning
	pass



func nextColor():
	print("BLOCK CLICKED")
	#reset all the other collision layer masks
	direction = Vector2(0,0)
	var colors = ["RED", "GREEN", "BLUE", "PURPLE"]
	var index = colors.find(currentBlock.blockColor)
	var newColor = colors[(index+1)%4]
	for i in range(4):
		area2D.set_collision_mask_value(i+1,false)
	area2D.set_collision_mask_value(colorToNumber[newColor],true)
	
	#change the players color
	player.modulate = colorToRGB[newColor]


func _on_flash_timer_timeout() -> void:
	if flashCount > 10: 
		if currentBlock != null:
			changeColor(currentBlock.blockColor)
			$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",false)
		else:
			rainbowOver = true
		flashCount = 0 
	else:
		#$FlashTimer.wait_time -= 0.02
		
		if $Objects/Player/ColorRect.material.get_shader_parameter("rainbow"):
			$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",false)
			$FlashTimer.wait_time = 0.1 #+ (flashCount*0.04)
		else:
			$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",true)
			$FlashTimer.wait_time = 0.3 - (flashCount*0.02)
		flashCount += 1
		$FlashTimer.start()
		
