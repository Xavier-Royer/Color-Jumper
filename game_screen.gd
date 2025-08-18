extends CanvasLayer

#change block hitbox done
#make player move down w screen done
#make spikes have cool down
#make blocks less common after spike
#make blocks not be able to be on edge
#change game modes, easy, classic, extreme/colorful and rainbow
#make tutorial
#add sound?


signal gameOverScreen

@onready var blockScene = preload("res://block.tscn")
@onready var itemScene = preload("res://Item.tscn")
@onready var area2D = $Objects/Player
@onready var player = $Objects/Player
@onready var movingObjects = $Objects


#player attribuites
var direction = Vector2(0,0)
var speed = 7000
var currentColor
var currentBlock
#game control stuff
var difficulty = "EASY" #easy, medium, hard or extreme
var difficulties = ["EASY", "MEDIUM" , "HARD", "EXTREME"]


#streaks/scroes
var trueScore
var score 
var streak 
var blockStreak
var lastJumpStamp = 0 #gameruntime of last jump 
var coins = 0 
var changedColor = false
var colorChangeBonus = 0.3

#spawn rates / difficulty
var baseGameSpeed  = 200
var gameSpeed = baseGameSpeed
var blocksSpawned = 0 

var spikeSpawnRate = 70 # percentage out of 1000 that one spawns
var coinSpawnRate = 100 # percentage out of 1000 that one spawns
var rainbowSpawnRate = 5 # percentage out of 1000 that one spawns
var randomColorRate = 300 # percentage out of 1000 that one spawns
var spikeSpawnStreak = 1
var randomColorStreak = 1

var rainbowOver = true
var particleSpeed = 3
var lastBlockSpawned = null


var gameState = "OVER" #OVER, READY, PLAYING
var gameRunTime = 0 
var blockSpawnTime = 0 
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
var pastColor = Color()

var oldRainbowTweenBar
var oldRainbowTweenParticles


func _ready() -> void:
	screen_size = Globals.screenSize #get_viewport().get_visible_rect().size
	player.connect("caughtBlock",_on_block_caught)
	player.connect("collectCoin", coinCollected)
	for button in $UI/ColorButtons.get_children():
		button.connect("pressed",changeColor.bind(button.name))
	player.connect("screenExited",gameOver)
	
	#animating text on menu screen
	var tween = create_tween().set_loops()
	tween.tween_property($UI/TouchAnywhereText, "scale", Vector2(1.1, 1.1), 0.1).set_ease(Tween.EASE_IN)
	tween.tween_property($UI/TouchAnywhereText, "scale", Vector2(1, 1), 0.4).set_ease(Tween.EASE_OUT)
	var tween2 = create_tween().set_loops()

	tween2.tween_property($UI/Logo, "position:y", $UI/Logo.position.y + 50, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween2.tween_property($UI/Logo, "position:y", $UI/Logo.position.y, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	#rainbowTweenBar = create_tween()
	#rainbowTweenParticles = create_tween()
	
	loadGame()






func loadGame():
	#resets everything 
	player.reset()
	#rest rainbow
	$RainbowTimer.stop()
	$FlashTimer.stop()
	$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",false)
	$UI/RainBowBar.hide()
	$UI/RainbowParticles.position = $UI/RainBowBar.position + Vector2(60,885)#$UI/RainBowBar.size.y*2)
	$UI/RainbowParticles.hide()
	rainbowOver = true
	#reset velocity and delete game screen objects 
	player.velocity = Vector2(0,0)
	for i in movingObjects.get_children():
		if i.name != "Player":
			i.queue_free()
	movingObjects.position.y = 0 
	
	#show the player 
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
	for i in randi_range(15,18):
		block = blockScene.instantiate()
		block.number = blocksSpawned
		movingObjects.add_child(block)
		block.position = Vector2(randi_range(30,screen_size.x - 35),randi_range(-600,screen_size.y * (2.0/3.0) - 100))
		#block.connect("invalidBlock",spawnBlock)
		block.setColor("RAINBOW")
		block.connect("blockMissed",gameOver)
		lastBlockSpawned = block
		blocksSpawned+=1
	
	player.position = Vector2(screen_size.x / 2,screen_size.y * (21.0/30.0))
	player.velocity = Vector2(0, -7000)
	
	lastBlockSpawned = null
	streak = 0 
	blockStreak = 0 
	score = 0 
	$UI/Score.text = str(0) 
	$UI/Streak.text = ""
	
	difficulty = FileManager.difficulty
	
	
	if difficulty == "EASY":
		randomColorRate = 100
		baseGameSpeed  = 200#200
		blockSpawnTime = 1
		$SpawnTimer.wait_time = 1
	elif difficulty == "MEDIUM":
		randomColorRate = 250
		baseGameSpeed  = 500
		blockSpawnTime = 0.75
		$SpawnTimer.wait_time = 0.75
	elif difficulty == "HARD":
		randomColorRate = 200
		baseGameSpeed  = 730
		blockSpawnTime = 0.4
		$SpawnTimer.wait_time = 0.4
	else: #EXTREME
		randomColorRate = 750
		baseGameSpeed  = 800
		blockSpawnTime = 0.4
		$SpawnTimer.wait_time = 0.4
		
	gameState = "READY"

func changeColor(newColor):
	
	#update collision masks and color to netural for trail
	if newColor == "RAINBOW":
		for i in range(4):
			area2D.set_collision_mask_value(i+1,true)
		pastColor = player.modulate
		player.rainbowOn()
		player.modulate = Color(1,1,1)
		return
	
	#change the curren block's color
	if currentBlock != null:
		currentBlock.setColor(newColor)
		changedColor = true
	
	#reset all the other collision layer masks
	for i in range(4):
		area2D.set_collision_mask_value(i+1,false)
	area2D.set_collision_mask_value(colorToNumber[newColor],true)
	
	#change the players color
	player.modulate = colorToRGB[newColor]
	
	

#player captureing block
func _on_block_caught():
	
	#play block animation
	currentBlock = player.blockOn
	currentBlock.blockCaught(direction,gameSpeed,player.blockPosition)
	direction = Vector2(0,0)
	#make rainbow happen
	if currentBlock.get_collision_layer_value(10) :
		$UI/RainbowScreenOverLay.rainbowStart()

		$RainbowTimer.start()
		$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",true)
		changeColor("RAINBOW")
		$UI/RainBowBar.show()
		$UI/RainbowParticles.show()
		$UI/RainBowBar.value = 100 
		$UI/RainbowParticles.position =  $UI/RainBowBar.position + Vector2(984,-40)
		
		#if rainbowTweenBar.is_running:
			#rainbowTweenBar.stop()
			#rainbowTweenParticles.stop()
		if oldRainbowTweenParticles != null:
			oldRainbowTweenBar.stop()
			oldRainbowTweenParticles.stop()
		
		$UI/RainbowParticles.restart()
		
		var rainbowTweenBar = create_tween()
		var rainbowTweenParticles = create_tween()
		rainbowTweenParticles.connect("finished",hideRainbowParticles)
		
		
		
		var endPosition = ( $UI/RainBowBar.position + Vector2(0, -40))
		rainbowTweenParticles.tween_property($UI/RainbowParticles, "position", endPosition, 5)
		rainbowTweenBar.tween_property($UI/RainBowBar, "value", 0,5)
		
		oldRainbowTweenBar = rainbowTweenBar
		oldRainbowTweenParticles = rainbowTweenParticles
		
		
		
		
	#if rainbow over set color to block color
	if rainbowOver:
		$UI/RainBowBar.hide()
		$UI/RainbowParticles.hide()
		rainbowOver = false
		player.rainbowOff()
		
		#$UI/RainbowScreenOverLay.hide()
		$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",false)
		changeColor(currentBlock.blockColor)
		if currentBlock.blockColor != "RAINBOW" and gameRunTime >0.0:
			$UI/RainbowScreenOverLay.flashColor(currentBlock.modulate)
	
	if gameState == "PLAYING":
		#update streak
		var streakTime = 0.75
		if changedColor:
			streakTime += colorChangeBonus
		changedColor = false
		blockStreak +=1 
		if gameRunTime - lastJumpStamp < streakTime:
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
		tween.tween_property(self,"score", (streak *20)+ score + (  (20 /  (max(gameRunTime,0.2)- lastJumpStamp)) * max(blockStreak,1) ),.1)
		
		#score += round(  (100 /  (max(gameRunTime,0.2)- lastJumpStamp)) * max(streak,1) )
		lastJumpStamp = gameRunTime
	
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mousePosition = get_viewport().get_mouse_position()
		#ensure its not where the buttons are
		#mouse position over buttons check shouldnt be needed anymore as now were using mouse emulation and passthrough fitlers
		#hi dominic that is a pretty cool comment
		if mousePosition.y < $UI/ColorButtons.position.y and gameState != "OVER":
			#if player.velocity == Vector2(0,0):
			if currentBlock != null:
				#Begin game if in ready position
				if gameState == "READY":
					#start palying the game
					gameRunTime = 0 
					gameState = "PLAYING"
					$SpawnTimer.start()
					lastJumpStamp = get_process_delta_time()
					gameSpeed = baseGameSpeed
					
					#hide all the start screen buttons
					$UI/TouchAnywhereText.hide()
					var tween = create_tween().set_parallel(true)
					tween.tween_property($UI/Logo, "modulate:a", 0.0, 0.5)
					$UI/Settings.disabled = true
					$UI/Leaderboard.disabled = true
					$UI/Shop.disabled = true
					$UI/Settings.mouse_filter = 1 #Passthrough
					$UI/Leaderboard.mouse_filter = 1 #Passthrough
					$UI/Shop.mouse_filter = 1 #Passthrough
					tween.tween_property($UI/Settings, "modulate:a", 0.0, 0.5)
					tween.tween_property($UI/Leaderboard, "modulate:a", 0.0, 0.5)
					tween.tween_property($UI/Shop, "modulate:a", 0.0, 0.5)
					
					
				#update direction vector of the player
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
	
	if rainbowOver == false:
		$UI/RainbowParticles.speed_scale = particleSpeed
	
	if gameState == "PLAYING":
		#updates player movement
		player.velocity = speed*direction
		player.gameSpeed = gameSpeed
		#updates game time and moves background down
		gameRunTime += delta
		spikeSpawnRate += delta/5.0
		gameSpeed = baseGameSpeed + 100*(log(gameRunTime))
		#gameSpeed += delta
		movingObjects.position.y += delta*gameSpeed
		#update score
		$UI/Score.text = str(comma_format(str(score)))
		
#nice function
func comma_format(num_str: String) -> String:
	var result := ""
	var count := 0
	for i in range(num_str.length() - 1, -1, -1):
		result = num_str[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result
	return result





func spawnBlock():
	var block2
	var block = blockScene.instantiate()
	movingObjects.call_deferred("add_child",block)
	block.number = blocksSpawned
	blocksSpawned += 1
	block.connect("invalidBlock",spawnBlock)
	block.connect("blockMissed",gameOver)
	
	
	#set block position
	var blockPosition = Vector2(randi_range(40,screen_size.x-40),randi_range(-750,-700))
	
	block.set_deferred("global_position", blockPosition)
	
	#spawn a spike connected to the block
	
	var spikeSpawn = randi_range(0,1000*spikeSpawnStreak) < spikeSpawnRate
	var coinSpawn = randi_range(0,1000) < coinSpawnRate
	spikeSpawnStreak = 1
	var lastBlockExists = lastBlockSpawned != null
	var firstPosition = Vector2.ZERO
	if lastBlockExists:
		lastBlockExists = ! lastBlockSpawned.deleted
		firstPosition  = lastBlockSpawned.get_global_position()
	var secondPosition = blockPosition
	#if both blocks exist and its time to spawn coin/spike
	$SpawnTimer.wait_time = blockSpawnTime
	if (spikeSpawn or coinSpawn) and lastBlockExists and (firstPosition.distance_to(secondPosition) >250):
		setBlockColor(block,true)
		setBlockColor(lastBlockSpawned,true)
	
		lastBlockSpawned.number = -1#blocksSpawned-10 #-1
		block.number = -1#blocksSpawned-10 #-1
		#print("SPIKE OR COIN SPAWN")
		#spawn the item
		var item = itemScene.instantiate()
		item.number =-1# blocksSpawned-10 
		movingObjects.call_deferred("add_child",item)
		blocksSpawned += 1
		#set the item type
		var type
		if coinSpawn: 
			type = "COIN"
		else:
			type = "SPIKE"
		item.call_deferred("createHitBox",firstPosition,secondPosition, movingObjects,  lastBlockSpawned, block,type)
		
		
		#spawn another block
		if coinSpawn == false:
			spikeSpawnStreak *=10
			$SpawnTimer.wait_time = (blockSpawnTime *1.3)
			block2 = blockScene.instantiate()
			movingObjects.call_deferred("add_child",block2)
			block2.number = blocksSpawned#-1
			blocksSpawned += 1
			block2.connect("invalidBlock",spawnBlock)
			block2.connect("blockMissed",gameOver)
			var block2Position = Vector2(0,0)
			var spikeSlope = (secondPosition.y-firstPosition.y) / (secondPosition.x -firstPosition.x)
			var inverseSlope  = 1
			if spikeSlope != 0:
				inverseSlope = -1/spikeSlope
			var distanceFromSpike = randf_range(250,400)
			var spikePosition = (firstPosition + secondPosition) /2.0
	
			block2Position = spikePosition
			var spikeDirection = Vector2(1,inverseSlope)
			spikeDirection = spikeDirection.normalized()
			block2Position += spikeDirection *distanceFromSpike  #Vector2(distanceFromSpike, distanceFromSpike*inverseSlope)
			
			
			if block2Position.y > -50 or (block2Position.x < 45) or (block2Position.x > screen_size.x -45):
				block2Position -= spikeDirection *distanceFromSpike
			block2Position += Vector2(randf_range(-70,70),randf_range(-70,70))
			block2Position.x = clamp(block2Position.x,40,screen_size.x-40)
			block2Position.y = clamp(block2Position.y,-1000,-200)
			block2.set_deferred("global_position", block2Position)
			setBlockColor(block2,true)
	else:
		setBlockColor(block,false)
	
	
	lastBlockSpawned = block
	
	
	
	
	
func setBlockColor(block,itemAttached):
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
	
	#if an item is attached, its more likely to be the same color
	var maxRange = 1000
	if itemAttached:
		maxRange = 10000
	
	#random chance of making it a random color
	if randi_range(1,maxRange *randomColorStreak) <= randomColorRate:
		var colors  = ["RED","GREEN","BLUE","PURPLE"]
		block.setColor(colors[randi_range(0,3)])
		randomColorStreak*=2
	else:
		randomColorStreak = 1
	#random chance of making it rainbow
	if randi_range(0,1000) <= rainbowSpawnRate:
		block.setColor("RAINBOW")
	
func gameOver():
	if gameState == "PLAYING":
		$SpawnTimer.stop()
		$UI/RainbowScreenOverLay.hide()
		$UI/RainbowScreenOverLay.gameOver = true
		$UI/RainBowBar.hide()
		$UI/RainbowParticles.hide()
		$UI/FlashScreen.hide()
		#player.hide()
		player.disappear()
		gameState = "OVER"
		$"../GameOverScreen/UI/VBoxContainer/Score".text = "Score: " + (comma_format(str(score)))
		var index = difficulties.find(difficulty)
		var currentHighScore = FileManager.highScore[index]
		if score > currentHighScore:
			currentHighScore = score
			FileManager.setHighScore(score,index)
		$"../GameOverScreen/UI/VBoxContainer/Highscore".text = "High Score: " + (comma_format(str(currentHighScore)))
		emit_signal("gameOverScreen")
		for c in $UI/ColorButtons.get_children():
			c.disabled = true



func _on_spawn_timer_timeout() -> void:
	#should update so that wait time varys + gets faster as game goes on 
	spawnBlock()



func _on_rainbow_timer_timeout() -> void:
	#start flash animation bc rainbow is starting to wear off
	#if currentBlock != null:
		#if currentBlock.blockColor != "RAINBOW":
			#$UI/RainbowScreenOverLay.flashColor(currentBlock.modulate)
		#player.rainbowOff()
		#$UI/RainbowScreenOverLay.hide()
		#changeColor(currentBlock.blockColor)
		#$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",false)
	#else:
		rainbowOver = true
	
	
	#$FlashTimer.wait_time = 0.3
	#$FlashTimer.start()




#does nothing rn i think
func _on_flash_timer_timeout() -> void:
	#rainbow flashing animation
	if flashCount > 10: 
		if currentBlock != null:
			player.rainbowOff()
			$UI/RainbowScreenOverLay.hide()
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
			player.modulate = pastColor
			player.rainbowOff()
			$UI/RainbowScreenOverLay.hide()
		else:
			player.rainbowOn()
			$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",true)
			$FlashTimer.wait_time = 0.3 - (flashCount*0.02)
			player.modulate = Color(1,1,1)
			$UI/RainbowScreenOverLay.show()
		flashCount += 1
		$FlashTimer.start()
		
func coinCollected():
	coins += 1



func hideRainbowParticles():
	$UI/RainbowParticles.hide()
