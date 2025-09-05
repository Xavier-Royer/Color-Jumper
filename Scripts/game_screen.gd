extends CanvasLayer

signal gameOverScreen

@onready var blockScene = preload("res://Scenes/block.tscn")
@onready var itemScene = preload("res://Scenes/Item.tscn")
@onready var area2D = $Objects/Player
@onready var player = $Objects/Player
@onready var movingObjects = $Objects

#player attribuites
var direction = Vector2(0,0)
var speed = 7000
var currentColor
var currentBlock
#game control stuff
var difficulty = "CLASSIC" #easy, medium, hard or extreme
var difficulties = ["EASY", "CLASSIC" , "COLORFUL", "RAINBOW"]

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
var rainbowSpawnRate = 5#5 # percentage out of 1000 that one spawns
var randomColorRate = 300 # percentage out of 1000 that one spawns
var spikeSpawnStreak = 1
var randomColorStreak = 1
var colorTransitionSpeed = 1.0
var spikeDivisorCoolDown = 2.0
var spikeCoolDownTime = 1.3
var currentDifficulty = 1.0
var lastBlocksColor = "RED"
var coinStreak = 1

var rainbowOver = true
var particleSpeed = 3
var lastBlockSpawned = null


var gameState = "TUTORIAL" #OVER, READY, PLAYING, TUTORIAL
var gameRunTime = 0 
var blockSpawnTime: float = 0.0
var screen_size

var finalGameSpeed = 1
var finalSpawnWaitTime = 1
var finalRandomColorRate = 1
var difficultyTween: Tween

var colorToNumber ={
	"RED": 1,
	"GREEN":2,
	"BLUE":3,
	"PURPLE":4
}

var colorToRGB ={
	"RED": Color(1.0,.07,0),
	"GREEN": Color(0,1.0,.05),
	"BLUE": Color(0,.8,1.0),
	"PURPLE":Color(1.0,.1,1.0)
}


#rainbowFlashAnimationVariables
var flashCount =0  
var pastColor = Color()

var oldRainbowTweenBar
var oldRainbowTweenParticles

#tutorialVariables
var tutorialBlocks = []
var tutorialStages= []
var tuturialTexts = []
var tutorialChangeColor = false
var tutorialStep = 0 
var buttonAnimationPlayed = false
var textTween 
var textTweenAlpha
var lastCheckPoint
var lastCheckPointBlock
var tutorialState
var learnedColors = false
var aboutToBeFree = false
var tutorialRainbow = false
var awaitingTutorialTween 
var encouragemnetMessages = ["You got this!", "Lets try that again!", "Don't give up!"]
var playerLoadInAnimation = false
var starterBlock = null


func _ready() -> void:
	screen_size = Globals.screenSize #get_viewport().get_visible_rect().size
	player.connect("caughtBlock",_on_block_caught)
	player.connect("collectCoin", coinCollected)
	for button in $UI/ColorButtons.get_children():
		button.connect("pressed",changeColor.bind(button.name))
	player.connect("screenExited",gameOver.bind("MISSED"))
	player.connect("spikeHit",gameOver.bind("SPIKE"))
	player.connect("screenExitedWithBlock",gameOver.bind("PLAYERONBLOCK"))
	
	#animating text on menu screen
	var tween = create_tween().set_loops()
	tween.tween_property($UI/TouchAnywhereText, "scale", Vector2(1.1, 1.1), 0.1).set_ease(Tween.EASE_IN)
	tween.tween_property($UI/TouchAnywhereText, "scale", Vector2(1, 1), 0.4).set_ease(Tween.EASE_OUT)
	var tween2 = create_tween().set_loops()
	tween2.tween_property($UI/Logo, "position:y", $UI/Logo.position.y + 50, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween2.tween_property($UI/Logo, "position:y", $UI/Logo.position.y, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	#if tutorial already done then switch state to over
	FileManager.loadTutorial()
	if FileManager.tutorial:
		gameState = "TUTORIAL"
	else:
		gameState = "OVER"
	
	if gameState != "TUTORIAL":
		loadGame(false)
	else:
		loadTutorial()


func loadGame(fromTutorial, tweenDistance = 0):
	disableColorButtons()
	difficulty = FileManager.difficulty
	$UI/DeathText.hide()
	get_parent().find_child("Background").get_child(0).resetBackgroundPositions()
	#resets everything 
	gameRunTime = 0
	player.reset()
	turnOffRainbow()
	#reset velocity and delete game screen objects 
	if fromTutorial == false:
		resetMovingObjects()
	
	#show the player 
	blocksSpawned = 0 
	currentBlock = null
	changeColor("RED")
	
	
	
	var block
	if fromTutorial == false:
		#generate first block which the layer is on
		block = blockScene.instantiate()
		movingObjects.add_child(block)
		block.position = Vector2(screen_size.x / 2,screen_size.y * (2.65/5.0))
		block.setColor("RED")
		block.setGhost()
		block.number = -99999999999999
		blocksSpawned+=1
		starterBlock = block
	
	
	#generates the rest of the starting blocks
	var blockPositions = [block.position]
	var numberOfBlocks = randi_range(12,18) 
	print(numberOfBlocks)
	for i in range(numberOfBlocks):
		block = blockScene.instantiate()
		block.number = blocksSpawned
		
		var yStartPos = (screen_size.y * (2.65/5.0)) - 150
		var yRange = (screen_size.y * (2.65/5.0) - 150) + 900.0
		var yIncriments = yRange/numberOfBlocks
		
		var invalid = false
		var blockPosition = Vector2(randi_range(90,screen_size.x - 90),min(yStartPos-(yIncriments*i) + randi_range(-50,50),  yStartPos))
		#checks to see if the block's spawn position is valid
		for x in blockPositions:
			if blockPosition.distance_to(x) < 390:
				block.queue_free()
				print("INVALID BLOCK")
				invalid = true
		if not invalid:
			blockPositions.append(blockPosition)
			block.position = blockPosition
			movingObjects.add_child(block)
			if fromTutorial == true:
				block.position.y += -tweenDistance - movingObjects.position.y - 50
			
			block.setColor("RED")
			block.connect("blockMissed",gameOver)
			lastBlockSpawned = block
		blocksSpawned+=1
	
	if fromTutorial == false:
		playerLoadInAnimation = true
		player.position = Vector2(screen_size.x / 2 - 30,screen_size.y * (27.0/30.0))
		player.velocity = Vector2(0, -1000)
	else:
		player.position = Vector2(screen_size.x / 2 - 30,player.position.y)
	
	lastBlockSpawned = null
	streak = 0 
	blockStreak = 0 
	score = 0 
	$UI/Score.text = str(0) 
	$UI/Streak.text = ""
	
	
	
	
	speed = 7000
	spikeCoolDownTime = 1.3
	colorTransitionSpeed = 1.0
	if difficulty == "EASY":
		randomColorRate = 15
		baseGameSpeed  = 400
		blockSpawnTime = 1
		$SpawnTimer.wait_time = blockSpawnTime
		rainbowSpawnRate = 5
		finalGameSpeed = 900
		finalSpawnWaitTime = 0.5


	elif difficulty == "CLASSIC":
		randomColorRate = 65
		spikeSpawnRate = 125
		coinSpawnRate = 70
		#baseGameSpeed  = 820
		baseGameSpeed  = 650
		blockSpawnTime = 0.7
		spikeDivisorCoolDown = 2.5
		spikeCoolDownTime = 1.6
		$SpawnTimer.wait_time = blockSpawnTime
		rainbowSpawnRate = 5
		finalGameSpeed = 1600
		finalSpawnWaitTime = 0.24
	
	elif difficulty == "COLORFUL": #EXTREME
		randomColorRate = 200
		baseGameSpeed  = 670
		blockSpawnTime = 0.6
		$SpawnTimer.wait_time = blockSpawnTime
		rainbowSpawnRate = 20
		finalRandomColorRate = 1000
		finalGameSpeed = 775
		finalSpawnWaitTime = 0.3
	else:# difficulty == "RAINBOW":
		randomColorRate = 1000
		baseGameSpeed  = 850
		finalGameSpeed = 1650
		blockSpawnTime = 0.35
		finalSpawnWaitTime = 0.25
		spikeSpawnRate = 250 # percentage out of 1000 that one spawns
		coinSpawnRate = 120
		spikeDivisorCoolDown = 2.0
		$SpawnTimer.wait_time = blockSpawnTime
		colorTransitionSpeed = 1.5
		spikeCoolDownTime = 1.6
		speed = 8000
		rainbowSpawnRate = 0
		player.rainbowOn()
		$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",true)
		#player.modulate = Color(1,1,1)
		$UI/RainbowScreenOverLay.show()
		rainbowOver = false
	if fromTutorial:
		showButtons()
	lastBlocksColor = "RED"
	currentDifficulty = 1
	gameState = "READY"


func changeColor(newColor):
	#if loading into game and done with rise up animation turn on color buttons
	if playerLoadInAnimation:
		starterBlock.setColor(newColor)
	if difficulty == "RAINBOW" and gameState != "TUTORIAL":
		return
	#update collision masks and color to netural for trail
	if newColor == "RAINBOW":
		for i in range(4):
			area2D.set_collision_mask_value(i+1,true)
		pastColor = player.getColor()
		player.rainbowOn()
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
	player.setColor(colorToRGB[newColor])
	
	#manual turn off of rainbow
	if $Objects/Player/ColorRect.material.get_shader_parameter("rainbow"):
		$UI/RainBowBar.hide()
		$UI/RainbowParticles.hide()
		$UI/RainbowScreenOverLay/RainbowFade.stop()
		$UI/RainbowScreenOverLay/FlashTimer.stop()
		$UI/RainbowScreenOverLay.flashColor(colorToRGB[newColor])
		rainbowOver = false
		player.rainbowOff()
		$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",false)
		$RainbowTimer.stop()
	
	
	if gameState == "TUTORIAL":
		if (tutorialState == "FREE") or aboutToBeFree:
			return
		for i in $UI/ColorButtons.get_children():
			i.disabled = true
		$UI/ButtonPointer.hide()
		$UI/ButtonAnimation.stop()
		tutorialChangeColor = false
	

#player captureing block
func _on_block_caught():
	
	playerLoadInAnimation = false
	#play block animation
	currentBlock = player.blockOn
	currentBlock.blockCaught(direction,gameSpeed,player.blockPosition)
	direction = Vector2(0,0)
	#make rainbow happen
	if currentBlock.get_collision_layer_value(10) :
		rainbowOver = false
		$UI/RainbowScreenOverLay.rainbowStart(gameState == "TUTORIAL")
		$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",true)
		changeColor("RAINBOW")
		$UI/RainBowBar.show()
		$UI/RainbowParticles.show()
		$UI/RainBowBar.value = 100 
		$UI/RainbowParticles.position =  $UI/RainBowBar.position + Vector2(984,-40)
		
		if oldRainbowTweenParticles != null:
			oldRainbowTweenBar.stop()
			oldRainbowTweenParticles.stop()
		
		$UI/RainbowParticles.restart()
		
		#start rainbow
		if gameState != "TUTORIAL":
			$RainbowTimer.start()
			var rainbowTweenBar = create_tween()
			var rainbowTweenParticles = create_tween()
			rainbowTweenParticles.connect("finished",hideRainbowParticles)
			var endPosition = ( $UI/RainBowBar.position + Vector2(0, -40))
			rainbowTweenParticles.tween_property($UI/RainbowParticles, "position", endPosition, 5)
			rainbowTweenBar.tween_property($UI/RainBowBar, "value", 0,5)
			oldRainbowTweenBar = rainbowTweenBar
			oldRainbowTweenParticles = rainbowTweenParticles
		else:
			for i in $UI/ColorButtons.get_children():
				i.disabled = true
	
	#if rainbow over set color to block color
	if rainbowOver:
		$UI/RainBowBar.hide()
		$UI/RainbowParticles.hide()
		rainbowOver = false
		player.rainbowOff()
		
		#$UI/RainbowScreenOverLay.hide()
		$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",false)
		changeColor(currentBlock.blockColor)
		if currentBlock.blockColor != "RAINBOW" and gameRunTime >0.0 and difficulty != "RAINBOW":
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
	
	elif gameState == "TUTORIAL":
		#if its the last tutorial block then transition to game 
		if player.blockOn.number == -100:
			var tweenDistance = -player.blockOn.global_position.y + (screen_size.y * (16.0/30.0)) 
			loadGame(true,tweenDistance)
			player.blockOn.setGhost()
			playerLoadInAnimation =true 
			$UI/Parent.hide()
			$UI/Pointer.hide()
			$UI/SkipTutorial.hide()
			var tween = create_tween()
			#tween.set_ease(Tween.EASE_IN)
			#tween.set_trans(Tween.TRANS_SINE)
			awaitingTutorialTween = true
			tween.tween_property(movingObjects,"position", Vector2(0,movingObjects.position.y+ tweenDistance),0.5)
			tween.connect("finished", tutorialOver)
			awaitingTutorialTween = false
		else: 
			tutorialStep +=1
			tutorialState =  tutorialStages[tutorialStep-1]
			
			if tutorialState == "CHECKPOINT":
				lastCheckPoint = tutorialStep
				lastCheckPointBlock = tutorialBlocks[tutorialStep-1]
			
			if tutorialBlocks[tutorialStep].blockColor == "RAINBOW":
					tutorialRainbow = true
			
			if textTween:
				textTween.kill()
			
			var learningCheckPoint = false
			if  tutorialStages[tutorialStep] == "LEARNING" and tutorialState == "CHECKPOINT":
				learningCheckPoint = true
			
			var playPointerAnimation = false
			if learningCheckPoint:
				var tween = create_tween()
				var endPosition =  (-1*lastCheckPointBlock.position.y) + (screen_size.y * (2.0/3.0))
				var startPosition = movingObjects.position.y
				var distance = abs(startPosition-endPosition)
				awaitingTutorialTween = true
				tween.tween_property(movingObjects,"position:y",endPosition,distance/2000)
				await tween.finished
				playPointerAnimation = true
				showNextBlocks(true)
				tutorialState = "LEARNING"
			
			if tutorialState == "LEARNING": #or learningcheckpoint
				if textTween != null:
					textTween.stop()
					textTweenAlpha.stop()
					textTween = null
				
				$UI/Pointer.hide()
				$UI/Parent.hide()
				$UI/Parent/TextContainer/Text.text = tuturialTexts[tutorialStep-1]
				$UI/Parent.position = tutorialBlocks[tutorialStep+0].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,300)
				$UI/Pointer.position = tutorialBlocks[tutorialStep+0].global_position -Vector2(64,64)
				
				if playPointerAnimation:
					playPointerSpawnInAnimation()
					waitForTutorialRespawn()
				else:
					playPointerLoopTweens()
				
				#chec if the player needs to change colors
				if  tutorialBlocks[tutorialStep-1].blockColor != tutorialBlocks[tutorialStep].blockColor and tutorialBlocks[tutorialStep-1].blockColor and not tutorialRainbow:
					tutorialChangeColor  =true
					# if we havent played the button animaton yet
					if not buttonAnimationPlayed:
						buttonAnimationPlayed = true
						$UI/ButtonPointer.show()
						var tween2 = create_tween()
						$UI/ButtonPointer.position = Vector2(0,screen_size.y - $UI/ButtonPointer.size.y)
						tween2.set_ease(Tween.EASE_IN_OUT)
						tween2.set_trans(Tween.TRANS_SINE)
						tween2.tween_property($UI/ButtonPointer,"position",Vector2(screen_size.x,$UI/ButtonPointer.position.y),1.0)
						tween2.connect("finished",hoverButton.bind(tutorialBlocks[tutorialStep].blockColor))
						#otherwise highlight color to siwtch to 
					else:
						hoverButton(tutorialBlocks[tutorialStep].blockColor)
				
			#else we are free or about to be free 
			else:
				var checkPointBlock = null
				var spawnNextCheckPoint = true
				
				
				#check all blocks in the state to check if the player's landed on them yet
				for i in range(len(tutorialBlocks)-lastCheckPoint-1):
					var blockState = tutorialStages[i+lastCheckPoint+0]
					if blockState == "CHECKPOINT" and i != 0:
						#found next checkpoint block
						checkPointBlock = tutorialBlocks[i+lastCheckPoint+0]
						
						break
					
					if tutorialBlocks[i+lastCheckPoint].tutorialBlockCaught == false:
						#a block hasn't been deleted yet
						spawnNextCheckPoint = false
				
				#reveal the checkpoint if all blocks are deleted
				if spawnNextCheckPoint:
					#if currentBlock != checkPointBlock:
					checkPointBlock.spawnBackIn()
					
				
				#if were transitioning to free state 
				if  tutorialState =="CHECKPOINT":
					aboutToBeFree = true
					#undisable the color buttons
					if buttonAnimationPlayed:
						for i in $UI/ColorButtons.get_children():
							i.disabled = false
					var endPosition =  (-1*lastCheckPointBlock.position.y) + (screen_size.y * (2.0/3.0))
					var startPosition = movingObjects.position.y
					var distance = abs(startPosition-endPosition)
					var tween = create_tween()
					playDeatTextAnimation("YOUR TURN NOW!")
					awaitingTutorialTween = true
					tween.tween_property(movingObjects,"position:y",endPosition,distance/1500)
					await tween.finished
					showNextBlocks()
					waitForTutorialRespawn()



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mousePosition = get_viewport().get_mouse_position()
		if gameState == "TUTORIAL" and awaitingTutorialTween:
			return
		if gameState == "TUTORIAL" and tutorialState == "LEARNING":
			var blockPosition = tutorialBlocks[tutorialStep].global_position
			#if palyer is the right color
			if not tutorialChangeColor:
				#if click is over the block
				if (mousePosition.x < blockPosition.x + 80 and  mousePosition.x > blockPosition.x - 80) and (mousePosition.y < blockPosition.y + 80 and  mousePosition.y > blockPosition.y + -80):
					#Player can proceed
					playerJump(mousePosition)
					$UI/Pointer.hide()
					$UI/Parent.hide()

		elif mousePosition.y < ($UI/ColorButtons.position.y+movingObjects.position.y) and gameState != "OVER":
			if currentBlock != null:
				#Begin game if in ready position
				if gameState == "READY":
					#start palying the game
					gameRunTime = 0 
					gameState = "PLAYING"
					$SpawnTimer.start()
					lastJumpStamp = get_process_delta_time()
					gameSpeed = baseGameSpeed
					#start the difficulty ramping tween
					difficultyTween = create_tween()
					difficultyTween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
					difficultyTween.tween_property(self, "gameSpeed", finalGameSpeed, 100) #2 min 25s
					#difficultyTween.set_trans(Tween.TRANS_LINEAR)
					#difficultyTween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
					difficultyTween.set_parallel()
					difficultyTween.tween_property(self, "blockSpawnTime", finalSpawnWaitTime, 100) #2 min 25s
					difficultyTween.set_parallel()
					if difficulty == "COLORFUL":
						difficultyTween.tween_property(self, "randomColorRate", finalRandomColorRate, 100) #2 min 25s
					
					#hide all the start screen buttons
					fadeOutButtons()
				#if awaiting tween === false
				playerJump(mousePosition)
				if aboutToBeFree:
					aboutToBeFree = false
					tutorialState = "FREE"

func playerJump(mousePosition):
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
		#spikeSpawnRate += delta/3.0
		
		#gameSpeed += delta
		movingObjects.position.y += delta*gameSpeed
		#update score
		$UI/Score.text = str(comma_format(str(score)))
	
	if gameState == "TUTORIAL":
		$UI/Parent/TextContainer/Finger.size = Vector2($UI/Parent/TextContainer/Text.size.x,342)
		gameSpeed = 0
		player.velocity = speed*direction
		
		if tutorialState == "FREE":
			gameSpeed =200
			movingObjects.position.y += delta*gameSpeed
		else: #if player is in learning
			if player.velocity != Vector2.ZERO:
				gameSpeed =2000
				movingObjects.position.y += delta*gameSpeed *1.75
		player.gameSpeed = gameSpeed
	
	get_parent().find_child("Background").get_child(0).backgroundMoveSpeed = gameSpeed/20


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



func spawnBlock(respawning = false, depth=0):
	if depth >= 15:
		return
	var block2
	var block = blockScene.instantiate()
	movingObjects.call_deferred("add_child",block)
	block.number = blocksSpawned
	blocksSpawned += 1
	block.connect("invalidBlock",spawnBlock.bind(true, depth+1))
	block.connect("blockMissed",gameOver)
	
	#set block position
	var blockPosition = Vector2(randi_range(90,screen_size.x-90),randi_range(-900,-850))
	block.set_deferred("global_position", blockPosition)
	#spawn a spike connected to the block
	
	#var spikeSpawn = randi_range(0,1000*spikeSpawnStreak) < spikeSpawnRate
	var spikeSpawn = randi_range(0,1000*(max(1,currentDifficulty/4.2))) < spikeSpawnRate
	#var coinSpawn = randi_range(0,1000/(max(currentDifficulty/3.0,1))) < coinSpawnRate
	var coinSpawn = randi_range(0,1000/(min(coinStreak,15))) < coinSpawnRate
	#if spikeSpawnStreak > 1:
		#spikeSpawnStreak = max(1,spikeSpawnStreak/spikeDivisorCoolDown)
	if currentDifficulty > 1:
		currentDifficulty = max(1,currentDifficulty/1.5)
	
	if coinSpawn and not spikeSpawn:
		coinStreak*=10
		if randi_range(0,10) < 4:
			coinStreak = 1
	else:
		coinStreak = 1
		if currentDifficulty < 2:
			coinStreak = 2
		coinSpawn = false
	
	#spikeSpawnStreak = 1
	var lastBlockExists = lastBlockSpawned != null
	var firstPosition = Vector2.ZERO
	if lastBlockExists:
		lastBlockExists = ! lastBlockSpawned.deleted
		firstPosition  = lastBlockSpawned.get_global_position()
	var secondPosition = blockPosition
	#if both blocks exist and its time to spawn coin/spike
	$SpawnTimer.wait_time = blockSpawnTime
	if (spikeSpawn or coinSpawn) and lastBlockExists and (firstPosition.distance_to(secondPosition) >350 and not respawning and gameRunTime >1.0):
		setBlockColor(block,true)
		#setBlockColor(lastBlockSpawned,true)
		
		lastBlockSpawned.number = -101 - blocksSpawned
		blocksSpawned += 1
		block.number = -101 - blocksSpawned
		blocksSpawned += 1
		
		var item = itemScene.instantiate()
		item.number =-999999999999# blocksSpawned-10 
		movingObjects.call_deferred("add_child",item)
		
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
			currentDifficulty+=10
			$SpawnTimer.wait_time = blockSpawnTime#(blockSpawnTime *spikeCoolDownTime)
			block2 = blockScene.instantiate()
			movingObjects.call_deferred("add_child",block2)
			block2.number = min(-101 - blocksSpawned -30,-101)
			blocksSpawned += 1
			block2.connect("invalidBlock",spawnBlock.bind(true, depth+1))
			block2.connect("blockMissed",gameOver)
			var block2Position = Vector2(0,0)
			var spikeSlope = (secondPosition.y-firstPosition.y) / (secondPosition.x -firstPosition.x)
			var inverseSlope  = 1
			if spikeSlope != 0:
				inverseSlope = -1/spikeSlope
			var distanceFromSpike = randf_range(300,400)
			var spikePosition = (firstPosition + secondPosition) /2.0
		
		
			
			
			block2Position = spikePosition
			var spikeDirection = Vector2(1,inverseSlope)
			spikeDirection = spikeDirection.normalized()
			#make it so it always points to the upper
			if spikeDirection.y > 0:
				spikeDirection.y *=-1
				spikeDirection.x *= -1
			block2Position += spikeDirection *distanceFromSpike  #Vector2(distanceFromSpike, distanceFromSpike*inverseSlope)
			
			#slope greater than 10 means verticle (update as needed)
			if abs(spikeSlope) >10:
				if block2Position.y > -50 or (block2Position.x < 90) or (block2Position.x > screen_size.x -90):
					block2Position -= spikeDirection *distanceFromSpike * 2
			
			
			block2Position += Vector2(randf_range(-70,70),randf_range(-70,70))
			block2Position.x = clamp(block2Position.x,90,screen_size.x-90)
			block2Position.y = clamp(block2Position.y,-1000,-270)
			block2.set_deferred("global_position", block2Position)
			setBlockColor(block2,true)
	else:
		setBlockColor(block,false)
	lastBlockSpawned = block
	
	
	
	
	
func setBlockColor(block,itemAttached):
	#set color 
	#if an item is attached, its more likely to be the same color
	var maxRange = 1000
	if itemAttached:
		maxRange = 2000
	maxRange *= (max(currentDifficulty/2.0,0.75))
	if difficulty == "COLORFUL":
		maxRange = 1000
	
	#random chance of making it a random color
	if randi_range(1, maxRange) <= randomColorRate: # + randomColorStreak
		var colors  = ["RED","GREEN","BLUE","PURPLE"]
		block.setColor(colors[randi_range(0,3)])
		if (block.blockColor != lastBlocksColor) and (block.blockColor != "RAINBOW") and (lastBlocksColor != "RAINBOW") and (difficulty != "RAINBOW"):
			currentDifficulty+=5
		lastBlocksColor = block.blockColor 
		return
	#random chance of making it rainbow
	if randi_range(0,1000) <= rainbowSpawnRate and difficulty != "RAINBOW":
		block.setColor("RAINBOW")
	else:
		#random variance
		#var random = randf_range(max(-2,-1*gameRunTime),2)
		#xvalue of the sin function based on run time; a greater constant of muliplication equals higher frequency
		var xvalue = ((gameRunTime*colorTransitionSpeed))*.08 # + random after colotransitinospeed
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
	if (block.blockColor != lastBlocksColor) and (block.blockColor != "RAINBOW") and (lastBlocksColor != "RAINBOW") and (difficulty != "RAINBOW") :
		if difficulty == "COLORFUl":
			currentDifficulty+=0.5
		else:
			currentDifficulty+=5
	lastBlocksColor = block.blockColor 
	
func gameOver(deathType = ""):
	if gameState == "PLAYING":
		$SpawnTimer.stop()
		difficultyTween.kill()
		gameSpeed = 0
		if difficulty != "RAINBOW":
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
	if gameState == "TUTORIAL" :
		if not playerLoadInAnimation:
			resetToLastCheckPoint(deathType)


func _on_spawn_timer_timeout() -> void:
	#should update so that wait time varys + gets faster as game goes on 
	spawnBlock()
	print("gamespeed: " + str(gameSpeed))
	print("waittime: " + str($SpawnTimer.wait_time))
	print("waittime2: " + str(blockSpawnTime))
	print("color change: " + str(randomColorRate))


func _on_rainbow_timer_timeout() -> void:
		rainbowOver = true


func coinCollected():
	coins += 1


func hideRainbowParticles():
	$UI/RainbowParticles.hide()
	

func loadTutorial():
	#reset player
	player.reset()
	#set player position
	direction = Vector2(0,0)
	player.position = Vector2(screen_size.x / 2,screen_size.y * (21.0/30.0))
	player.velocity = Vector2(0, -7000)
	gameState = "TUTORIAL"
	turnOffRainbow()
	$UI/CheckPointTexts.hide()
	$UI/Parent.show()
	$UI/Pointer.show()
	$UI/SkipTutorial.show()
	var tween = create_tween().set_parallel(true)
	$UI/SkipTutorial.disabled = false
	$UI/SkipTutorial.mouse_filter = 0
	tween.tween_property($UI/SkipTutorial, "modulate:a", 1.0, 0.5)
	
	changeColor("RED")
	
	#hideButtons
	fadeOutButtons()
	$UI/Streak.hide()
	$UI/Score.hide()
	
	#reset tutorial variables
	buttonAnimationPlayed = false
	gameRunTime = 0
	aboutToBeFree = false
	learnedColors = false
	tutorialRainbow = false
	awaitingTutorialTween = false
	tutorialBlocks = []
	tutorialStages = []
	tutorialStep=0
	lastCheckPoint = 0 
	tutorialState = "LEARNING"
	
	#delete game screen objects 
	resetMovingObjects()
	
	#show the player 
	player.show()
	blocksSpawned = 0 
	currentBlock = null
	
	#Spawn all of the setup blocks
	createTutorialBlock(Vector2(screen_size.x / 2,screen_size.y * (2.0/3.0)),"RED","Click where you \n want your ship to go!","LEARNING",null,true,false,true)
	createTutorialBlock(Vector2(screen_size.x / 4.0,screen_size.y * (5.00/10.0)),"RED","Don't miss!","LEARNING",null,true)
	createTutorialBlock(Vector2(screen_size.x * (2.0/6.0),screen_size.y * (2.2/10.0)),"RED","","CHECKPOINT",null,true)
	createTutorialBlock(Vector2(screen_size.x * (5.0/6.0),0),"RED","","FREE")
	createTutorialBlock(Vector2(screen_size.x * (3.0/8.0),screen_size.y * (-2.0/10)),"RED","","FREE")
	createTutorialBlock(Vector2(screen_size.x * (4.0/6.0),screen_size.y * (-4/10.0)),"RED","","FREE")
	createTutorialBlock(Vector2(screen_size.x * (3.0/6.0),screen_size.y * (-7/10.0)),"RED","Click to change colors","CHECKPOINT")
	createTutorialBlock(Vector2(screen_size.x * (1.0/4.0),screen_size.y * (-8.5/10.0)),"GREEN","Lets Try Blue!","LEARNING")
	createTutorialBlock(Vector2(screen_size.x * (7.0/8.0),screen_size.y * (-10/10.0)),"BLUE","Pro Tip: Use your dominant hand to tap blocks, \n and your other hand to change colors","LEARNING")
	createTutorialBlock(Vector2(screen_size.x * (3.0/6.0),screen_size.y * (-11/10.0)),"PURPLE","","CHECKPOINT")
	createTutorialBlock(Vector2(screen_size.x * (1.0/6.0),screen_size.y * (-13/10.0)),"RED","","FREE")
	createTutorialBlock(Vector2(screen_size.x * (2.0/5.0),screen_size.y * (-15/10.0)),"GREEN","","FREE")
	createTutorialBlock(Vector2(screen_size.x * (4.0/5.0),screen_size.y * (-16/10.0)),"BLUE","","FREE")
	createTutorialBlock(Vector2(screen_size.x * (3.0/6.0),screen_size.y * (-19/10.0)),"PURPLE"," Avoid Spikes! \n [img]res://Textures/Spike.png[/img] ","CHECKPOINT")
	createTutorialBlock(Vector2(screen_size.x * (5.0/6.0),screen_size.y * (-21/10.0)),"RED","Dont hit the blade","LEARNING", "SPIKE")
	createTutorialBlock(Vector2(screen_size.x * (1.0/6.0),screen_size.y * (-22/10.0)),"RED","  Collect Coins! \n [img]res://Textures/Coin.png[/img] ","LEARNING")
	createTutorialBlock(Vector2(screen_size.x * (3.0/6.0),screen_size.y * (-24/10.0)),"RED","Make sure to hit the coin","LEARNING","COIN")
	createTutorialBlock(Vector2(screen_size.x * (4.5/6.0),screen_size.y * (-26.5/10.0)),"RED","","LEARNING")
	createTutorialBlock(Vector2(screen_size.x * (3.0/6.0),screen_size.y * (-28.5/10.0)),"RED","","CHECKPOINT")
	createTutorialBlock(Vector2(screen_size.x * (2.0/3.0),screen_size.y * (-30.5/10.0)),"RED","","FREE","SPIKE")
	createTutorialBlock(Vector2(screen_size.x * (7.5/10.0),screen_size.y * (-33.5/10.0)),"RED","","FREE")
	createTutorialBlock( Vector2(screen_size.x * (1.0/3.0),screen_size.y * (-32/10.0)),"RED","","FREE")
	createTutorialBlock(Vector2(screen_size.x * (1.0/4.0),screen_size.y * (-35.5/10.0)),"RED","","FREE","COIN")
	createTutorialBlock(Vector2(screen_size.x * (4.0/9.0),screen_size.y * (-38.5/10.0)),"RED","","FREE")
	createTutorialBlock(Vector2(screen_size.x * (1.0/2.0),screen_size.y * (-41.0/10.0)),"RED","Rainbow blocks allow the player \n to hit all the colors!","CHECKPOINT")
	createTutorialBlock(Vector2(screen_size.x * (2.0/3.0),screen_size.y * (-43/10.0)),"RAINBOW","Rainbow runs out after 5 seconds","LEARNING")
	createTutorialBlock(Vector2(screen_size.x * (2.0/5.0),screen_size.y * (-45/10.0)),"PURPLE","Pro tip: To end rainbow early \n switch to any color", "LEARNING", "COIN")
	createTutorialBlock(Vector2(screen_size.x * (4.0/6.0),screen_size.y * (-47.0/10.0)),"GREEN","Congrats! Lets start off in easy mode!!!", "LEARNING")
	createTutorialBlock(Vector2(screen_size.x * (3.0/6.0),screen_size.y * (-48.5/10.0)),"RED","", "CHECKPOINT",null,false,true)

	$UI/PointerAnimation.play("Hover")
	
	#disable color buttons
	for i in $UI/ColorButtons.get_children():
		i.disabled = true

	
func hoverButton(nextBlockColor):
	var i = colorToNumber[nextBlockColor]
	$UI/ButtonPointer.show()
	var button = $UI/ColorButtons.get_child(i-1)
	button.disabled = false
	$UI/ButtonPointer.size.x = (screen_size.x/4) 
	$UI/ButtonPointer.pivot_offset.x = $UI/ButtonPointer.size.x/2
	$UI/ButtonPointer.position = Vector2( ($UI/ColorButtons.size.x*.25) * (i-1),screen_size.y - $UI/ButtonPointer.size.y)
	$UI/ButtonAnimation.play("Hover")


func fadeOutButtons():
	$UI/TouchAnywhereText.hide()
	fadeOutButton($UI/Logo,false)
	fadeOutButton($UI/ButtonContainer/Settings)
	fadeOutButton($UI/ButtonContainer/Leaderboard)
	fadeOutButton($UI/ButtonContainer/Shop)
	fadeOutButton($UI/ButtonContainer/StartTutorial)

func tutorialOver():
	enableColorButtons()
	FileManager.saveTutorial()
	gameState = "READY"
	currentBlock = player.blockOn

func _on_skip_tutorial_pressed() -> void:
	loadGame(false)
	#hide tutorial buttons
	$UI/Pointer.hide()
	$UI/ButtonPointer.hide()
	$UI/Parent.hide()
	$UI/ButtonPointer.hide()
	#fade out skip tutorial button
	var tween = create_tween().set_parallel(true)
	$UI/SkipTutorial.disabled = true
	$UI/SkipTutorial.mouse_filter = 1
	tween.tween_property($UI/SkipTutorial, "modulate:a", 0.0, 0.5)
	FileManager.saveTutorial()
	showButtons()

func showButtons():
	$UI/Streak.show()
	$UI/Score.show()
	$UI/TouchAnywhereText.show()
	#$UI/StartTutorial.show()
	fadeInButton($UI/Logo, false)
	fadeInButton($UI/ButtonContainer/StartTutorial)
	fadeInButton($UI/ButtonContainer/Settings)
	fadeInButton($UI/ButtonContainer/Leaderboard)
	fadeInButton($UI/ButtonContainer/Shop)
	#enable color switching buttons
	for c in $UI/ColorButtons.get_children():
		c.disabled = false


func _on_start_tutorial_pressed() -> void:
	loadTutorial()

func resetToLastCheckPoint(deathType):
	#print(deathType)
	awaitingTutorialTween = true
	player.disappear()
	tutorialStep = lastCheckPoint
	if player.blockOn != lastCheckPointBlock:
		lastCheckPointBlock.spawnBackIn()
	for i in range(len(tutorialBlocks)-lastCheckPoint-1):
		var blockState = tutorialStages[i+lastCheckPoint]
		if blockState == "CHECKPOINT" and i != 0:
			tutorialBlocks[i+lastCheckPoint-0].hideForTutorial()
			break
		tutorialBlocks[i+lastCheckPoint].spawnBackIn()
		
		if tutorialBlocks[i+lastCheckPoint].itemAttached != null:
			var block = tutorialBlocks[i+lastCheckPoint]
			block.deleteAttatchedItem()
			var block2 = tutorialBlocks[i+lastCheckPoint+1]
			var item = itemScene.instantiate()
			item.fromTutorial = true
			item.number =-999999999999# blocksSpawned-10 
			item.fadeIn()
			movingObjects.add_child(item)
			item.createHitBox(block.global_position,block2.global_position,movingObjects,block,block2,block.itemAttached)
			
		
		
	tutorialStep = lastCheckPoint
	tutorialState =  tutorialStages[tutorialStep-1]
	lastCheckPointBlock.spawnBackIn()
	aboutToBeFree = tutorialStages[tutorialStep+1]== "FREE"
	
	
	
	
	for i in range(len(tutorialBlocks)-lastCheckPoint):
		tutorialBlocks[i].deleted = false
	
	$UI/CheckPointTexts.hide()
	var endPosition =  (-1*lastCheckPointBlock.position.y) + (screen_size.y * (2.0/3.0))
	var startPosition = movingObjects.position.y
	var distance = abs(startPosition-endPosition)
	var tween = create_tween()
	tween.tween_property(movingObjects,"position:y",endPosition,distance/1500)
	await tween.finished
	
	player.reset()
	changeColor(lastCheckPointBlock.originalColor) 
	player.velocity  = Vector2.ZERO
	currentBlock = lastCheckPointBlock
	player.blockOn = currentBlock
	player.position = lastCheckPointBlock.position + Vector2(0,140)
	tutorialStep = lastCheckPoint -1
	_on_block_caught()
	tutorialStep = lastCheckPoint 
	
	#lastCheckPointBlock.setGhost()
	tutorialState = "CHECKPOINT"
	$UI/CheckPointTexts.show()
	$UI/CheckPointTexts.text = encouragemnetMessages[randi_range(0,len(encouragemnetMessages)-1)]
	
	#spawn death message
	var text = ""
	if deathType == "SPIKE":
		text = "OUCH! You hit a spike!"
	elif deathType == "MISSED":
		text = "Aim for the block next time!"
	elif deathType == "BLOCKMISSED":
		text = "Looks like you missed a block!"
	elif deathType == "PLAYERONBLOCK":
		text= "Dpn't slow down!"
	playDeatTextAnimation(text)
	
	waitForTutorialRespawn()
	
func playDeatTextAnimation(text):
	$UI/DeathTextAnimation.stop()
	$UI/DeathText.hide()
	$UI/CheckPointTexts.hide()
	$UI/DeathText.text = text
	$UI/DeathText.global_position.y = screen_size.y/5
	$UI/DeathText.pivot_offset.x = $UI/DeathText.size.x/2
	$UI/DeathTextAnimation.play("FlashText")
	$UI/DeathText.scale = Vector2.ZERO
	$UI/DeathText.show()

func showNextBlocks(showNextCheckPoint = false): #showNextBlocks
	for i in range(len(tutorialBlocks)-lastCheckPoint):
		var blockState = tutorialStages[i+lastCheckPoint]
		if blockState == "CHECKPOINT" and i != 0 :
			if showNextCheckPoint:
				#if tutorialBlockPositions[i+lastCheckPoint].deleted:
				tutorialBlocks[i+lastCheckPoint].spawnBackIn()
			break
		tutorialBlocks[i+lastCheckPoint].spawnBackIn()
		
		if tutorialBlocks[i+lastCheckPoint].itemAttached != null:
			var block = tutorialBlocks[i+lastCheckPoint]
			block.deleteAttatchedItem()
			var block2 = tutorialBlocks[i+lastCheckPoint+1]
			var item = itemScene.instantiate()
			item.number =-999999999999# blocksSpawned-10 
			movingObjects.add_child(item)
			item.fromTutorial = true
			item.fadeIn()
			item.createHitBox(block.global_position,block2.global_position,movingObjects,block,block2,block.itemAttached)

func createTutorialBlock(relativePosition, color, text, blockStage, item = null, visibile = false, lastBlcok = false, ghost = false):
	var block  = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = relativePosition
	block.setColor(color)
	block.tutorial = true
	block.connect("blockMissed",gameOver.bind("BLOCKMISSED"))
	block.itemAttached = item
	
	if lastBlcok == false:
		block.number = -99
	else: 
		block.number = -100
	
	if visibile == false:
		block.hideForTutorial()
	
	tutorialBlocks.append(block)
	tutorialStages.append(blockStage)
	tuturialTexts.append(text)
	
	if ghost:
		lastCheckPoint = block
		block.setGhost()

func turnOffRainbow():
	$RainbowTimer.stop()
	$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",false)
	player.rainbowOff()
	$UI/RainBowBar.hide()
	$UI/RainbowParticles.position = $UI/RainBowBar.position + Vector2(60,885)#$UI/RainBowBar.size.y*2)
	$UI/RainbowParticles.hide()
	$UI/RainbowScreenOverLay.hide()
	rainbowOver = true

func resetMovingObjects():
	for i in movingObjects.get_children():
		if i.name != "Player":
			i.queue_free()
	movingObjects.position.y = 0 
	
func fadeInButton(button, isButton = true):
	button.modulate.a = 1.0
	if isButton:
		button.disabled = false
		button.mouse_filter = 0 #Stop


func fadeOutButton(button,isButton = true):
	var tween = create_tween()
	tween.tween_property(button, "modulate:a", 0.0, 0.5)
	if isButton:
		button.disabled = true
		button.mouse_filter = 1 #Passthrough

func enableColorButtons():
	for i in $UI/ColorButtons.get_children():
		i.disabled = false
		
func disableColorButtons():
	for i in $UI/ColorButtons.get_children():
		i.disabled = true

func playPointerLoopTweens():
	textTween = create_tween().set_loops()
	textTween.tween_property($UI/Parent/TextContainer,"global_position", tutorialBlocks[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,350),1.0).set_ease(Tween.EASE_OUT)
	textTween.tween_property($UI/Parent/TextContainer,"global_position", tutorialBlocks[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,300),1.0).set_ease(Tween.EASE_IN)
				
	textTweenAlpha = create_tween().set_loops()
	textTweenAlpha.tween_property($UI/Parent/TextContainer/Finger,"modulate", Color(1,1,1,0.5),1.0).set_ease(Tween.EASE_OUT)
	textTweenAlpha.tween_property($UI/Parent/TextContainer/Finger,"modulate", Color(1,1,1,1),1.0).set_ease(Tween.EASE_IN)
	
	$UI/Parent.show()
	$UI/Pointer.show()

func playPointerSpawnInAnimation():
	$UI/PointerAnimation.stop()
	$UI/PointerAnimation.play("SpawnIn")
	$UI/Pointer.scale = Vector2(0,0)
	$UI/Pointer.show()


func _on_pointer_animation_animation_finished(_anim_name: StringName) -> void:
	playPointerLoopTweens()
	$UI/PointerAnimation.play("Hover")

func waitForTutorialRespawn():
	awaitingTutorialTween = true
	$UI/TutorialRespawnTimer.start()

func _on_tutorial_respawn_timer_timeout() -> void:
	awaitingTutorialTween = false
