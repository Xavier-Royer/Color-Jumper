extends CanvasLayer



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
var blockSpawnTime = 0 
var screen_size


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
var tutorialBlockPositions = []
#would be nice if we had another name for blocks
var tutorialBlockSteps = []
var tuturialTexts = []
var tutorialChangeColor = false
var tutorialStep = 0 
var buttonAnimationPlayed = false
var textTween 
var textTweenAlpha
var lastCheckPoint
var lastCheckPointBlock
var tutorialState
var updateTextPosition = null
var learnedColors = false
var aboutToBeFree = false
var tutorialRainbow = false
var encouragemnetMessages = ["You got this!", "Lets try that again!", "Don't give up!"]


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
	
	#if tutorial already done then switch state to over
	FileManager.loadTutorial()
	if FileManager.tutorial:
		gameState = "TUTORIAL"
	else:
		gameState = "OVER"
	
	
	#uncomment this to get the tutorial everytime 
	#gameState = "TUTORIAL"

	
	if gameState != "TUTORIAL":
		loadGame(false)
	else:
		loadTutorial()






func loadGame(fromTutorial, tweenDistance = 0):
	get_parent().find_child("Background").get_child(0).resetBackgroundPositions()
	print(difficulty)
	#resets everything 
	gameRunTime = 0
	player.reset()
	#if difficulty != "RAINBOW":
	#rest rainbow
	$RainbowTimer.stop()
	$FlashTimer.stop()
	$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",false)
	$UI/RainBowBar.hide()
	$UI/RainbowParticles.position = $UI/RainBowBar.position + Vector2(60,885)#$UI/RainBowBar.size.y*2)
	$UI/RainbowParticles.hide()
	$UI/RainbowScreenOverLay.hide()
	rainbowOver = true
	
	#reset velocity and delete game screen objects 
	if fromTutorial == false:
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
	
	var block
	if fromTutorial == false:
		#generate first block which the layer is on
		block = blockScene.instantiate()
		movingObjects.add_child(block)
		block.position = Vector2(screen_size.x / 2,screen_size.y * (2.0/3.0))
		block.setColor("RED")
		block.setGhost()
		block.number = blocksSpawned
		blocksSpawned+=1
	
	
	#generates the rest of the starting blocks
	var blockPositions = []
	var numberOfBlocks = randi_range(15,18) 
	for i in range(numberOfBlocks):
		#spawnStarterBlock(i,fromTutorial,tweenDistance)
		block = blockScene.instantiate()
		block.number = blocksSpawned
		
		#var spacedOutBlocks = 4
		var yStartPos = screen_size.y * (2.0/3.0) - 150
		var yRange = (screen_size.y * (2.0/3.0) - 150) + 700.0
		var yIncriments = yRange/numberOfBlocks
		print(yIncriments)
	#	if i > spacedOutBlocks:
		var invalid = false
		var blockPosition = Vector2(randi_range(35,screen_size.x - 35),min(yStartPos-(yIncriments*i) + randi_range(-50,50),  yStartPos))
		#var blockPosition = Vector2(500,min(yStartPos-(yIncriments*i) + randi_range(-20,20),  yStartPos))
		for x in blockPositions:
			if blockPosition.distance_to(x) < 350:
				block.queue_free()
				invalid = true
		if not invalid:
			blockPositions.append(blockPosition)
			block.position = blockPosition
			print(block.position)
			movingObjects.add_child(block)
			if fromTutorial == true:
				block.position.y += -tweenDistance - movingObjects.position.y - 50
			##block.connect("invalidBlock",spawnBlock)
			block.setColor("RED")
			block.connect("blockMissed",gameOver)
			#block.connect("invalidBlock",spawnStarterBlock.bind(i))
			lastBlockSpawned = block
			blocksSpawned+=1
			#var timer = Timer.new()
			#self.add_child(timer)
			#timer.start(0.001)
			#await timer.timeout
	
	if fromTutorial == false:
		player.position = Vector2(screen_size.x / 2,screen_size.y * (21.0/30.0))
		player.velocity = Vector2(0, -7000)
	
	lastBlockSpawned = null
	streak = 0 
	blockStreak = 0 
	score = 0 
	$UI/Score.text = str(0) 
	$UI/Streak.text = ""
	
	difficulty = FileManager.difficulty
	speed = 7000
	spikeCoolDownTime = 1.3
	colorTransitionSpeed = 1.0
	if difficulty == "EASY":
		
		randomColorRate = 100
		baseGameSpeed  = 410#200
		blockSpawnTime = 0.6
		$SpawnTimer.wait_time = 0.6

	elif difficulty == "CLASSIC":
		randomColorRate = 140
		spikeSpawnRate = 260
		coinSpawnRate = 70
		baseGameSpeed  = 820
		blockSpawnTime = 0.35
		spikeDivisorCoolDown = 2.5
		spikeCoolDownTime = 1.6
		$SpawnTimer.wait_time = 0.35
	
	elif difficulty == "COLORFUL": #EXTREME
		randomColorRate = 820
		baseGameSpeed  = 670
		blockSpawnTime = 0.5
		$SpawnTimer.wait_time = 0.5
	else:# difficulty == "RAINBOW":
		randomColorRate = 1000
		baseGameSpeed  = 1130
		blockSpawnTime = 0.27
		spikeSpawnRate = 250 # percentage out of 1000 that one spawns
		coinSpawnRate = 120
		spikeDivisorCoolDown = 2.0
		$SpawnTimer.wait_time = 0.27
		colorTransitionSpeed = 1.5
		spikeCoolDownTime = 1.6
		speed = 8000
		player.rainbowOn()
		$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",true)
		player.modulate = Color(1,1,1)
		$UI/RainbowScreenOverLay.show()
		rainbowOver = false
	if fromTutorial:
		showButtons()
		#$GameOverScreen.hide()
		#$GameScreen.show()
		#$GameScreen.show()
	lastBlocksColor = "RED"
	currentDifficulty = 1
	gameState = "READY"


func spawnStarterBlock(i,fromTutorial,tweenDistance):
	var block
	block = blockScene.instantiate()
	block.number = blocksSpawned
	movingObjects.add_child(block)
	if i <3:
		block.position = Vector2(randi_range(30,screen_size.x - 35),randi_range(-600,screen_size.y * (2.0/3.0) - 100))
	else:
		block.position = Vector2(randi_range(30,screen_size.x - 35),randi_range(0,screen_size.y * (2.0/3.0) - 100))
	if fromTutorial == true:
		block.position.y += -tweenDistance - movingObjects.position.y - 50
	#block.connect("invalidBlock",spawnBlock)
	block.setColor("RED")
	block.connect("blockMissed",gameOver)
	block.connect("invalidBlock",spawnStarterBlock.bind(i,fromTutorial,tweenDistance))
	lastBlockSpawned = block
	blocksSpawned+=1

func changeColor(newColor):
	if difficulty == "RAINBOW":
		return
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
	
	if $Objects/Player/ColorRect.material.get_shader_parameter("rainbow"):
		$UI/RainBowBar.hide()
		$UI/RainbowParticles.hide()
		$UI/RainbowScreenOverLay/RainbowFade.stop()
		$UI/RainbowScreenOverLay/FlashTimer.stop()
		#$UI/RainbowScreenOverLay.hide()
		$UI/RainbowScreenOverLay.flashColor(colorToRGB[newColor])
		rainbowOver = false
		player.rainbowOff()
		#$UI/RainbowScreenOverLay.hide()
		$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",false)
		#$UI/RainbowScreenOverLay.flashColor(currentBlock.modulate)
		$RainbowTimer.stop()
	
	
	if gameState == "TUTORIAL":
		
		if len(tutorialBlockSteps) > tutorialStep+1:
			if tutorialBlockSteps[tutorialStep+1] =="FREE":
				aboutToBeFree = true
		
		if learnedColors == true and (tutorialState == "FREE" or aboutToBeFree):
			tutorialChangeColor = false
			aboutToBeFree = false
			return
		for i in $UI/ColorButtons.get_children():
			print(aboutToBeFree)
			print("DISABLING")
			i.disabled = true
		$UI/ButtonPointer.hide()
		$UI/ButtonAnimation.stop()
		tutorialChangeColor = false
	

#player captureing block
func _on_block_caught():
	
	#play block animation
	currentBlock = player.blockOn
	
	
	
	currentBlock.blockCaught(direction,gameSpeed,player.blockPosition)
	direction = Vector2(0,0)
	#make rainbow happen
	if currentBlock.get_collision_layer_value(10) :
		$UI/RainbowScreenOverLay.rainbowStart(gameState == "TUTORIAL")
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
	
	if player.blockOn.number == -100:
		var tweenDistance = -player.blockOn.global_position.y + (screen_size.y * (2.0/3.0))
		loadGame(true,tweenDistance)
		$UI/Parent.hide()
		$UI/Pointer.hide()
		$UI/SkipTutorial.hide()
		var tween = create_tween()
		#tween.set_ease(Tween.EASE_IN)
		#tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(movingObjects,"position",movingObjects.position + Vector2(0,tweenDistance),0.5)
		tween.connect("finished", tutorialOver)
	if player.blockOn.number == -99: 
		if textTween:
			textTween.kill()
		textTween = create_tween().set_loops()
		textTween.tween_property($UI/Parent/TextContainer,"global_position", tutorialBlockPositions[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,350),1.0).set_ease(Tween.EASE_OUT)
		textTween.tween_property($UI/Parent/TextContainer,"global_position", tutorialBlockPositions[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,300),1.0).set_ease(Tween.EASE_IN)
		
		textTweenAlpha = create_tween().set_loops()
		textTweenAlpha.tween_property($UI/Parent,"modulate", Color(1,1,1,0.5),1.0).set_ease(Tween.EASE_OUT)
		textTweenAlpha.tween_property($UI/Parent,"modulate", Color(1,1,1,1),1.0).set_ease(Tween.EASE_IN)
		
		if tutorialState == "FREE":
			var checkPointBlock = null
			var spawnNextCheckPoint = true
			print("STARTING LOOP")
			for i in range(len(tutorialBlockPositions)-lastCheckPoint-1):
				var blockState = tutorialBlockSteps[i+lastCheckPoint+1]
				if blockState == "CHECKPOINT" and i != 0:
					checkPointBlock = tutorialBlockPositions[i+lastCheckPoint]
					break
				print(tutorialBlockPositions[i+lastCheckPoint].tutorialBlockCaught)
				if tutorialBlockPositions[i+lastCheckPoint].tutorialBlockCaught == false:
					spawnNextCheckPoint = false
			if spawnNextCheckPoint:
				if currentBlock != checkPointBlock:
					checkPointBlock.spawnBackIn()
		#tutorialBlockPositions[i+lastCheckPoint].spawnBackIn()
	#tutorialBlockCaught
			
			
			tutorialStep += 1
			tutorialState = tutorialBlockSteps[tutorialStep]
			if tutorialState == "CHECKPOINT":# transition to learning 
				lastCheckPoint = tutorialStep
				lastCheckPointBlock = tutorialBlockPositions[tutorialStep-1]
				var tween = create_tween()
				$UI/Parent/TextContainer/Text.text = tuturialTexts[tutorialStep]
				textTween.kill()
				textTween = null
				$UI/Parent/TextContainer.modulate.a =0.0
				$UI/Parent.show()
				$UI/Parent/TextContainer.global_position = tutorialBlockPositions[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,300)
				var endPosition =  (-1*lastCheckPointBlock.position.y) + (screen_size.y * (2.0/3.0))
				var startPosition = movingObjects.position.y
				var distance = abs(startPosition-endPosition)
				tween.tween_property(movingObjects,"position:y",endPosition,distance/2000)
				await tween.finished
				showNextBlocks(true)
				tutorialState = "LEARNING"
				
				$UI/Pointer.position = tutorialBlockPositions[tutorialStep].global_position -Vector2(64,64)
				$UI/Pointer.show()
				
				if tutorialBlockPositions[tutorialStep].blockColor == "RAINBOW":
					tutorialRainbow = true
				
				updateTextPosition = true
				if  tutorialBlockPositions[tutorialStep-1].blockColor != tutorialBlockPositions[tutorialStep].blockColor and tutorialBlockPositions[tutorialStep-1].blockColor and not tutorialRainbow:
					tutorialChangeColor  =true
					# if we havent played the button animaton yet
					if not buttonAnimationPlayed:
						buttonAnimationPlayed = true
						$UI/ButtonPointer.show()
						var tween2 = create_tween()
						$UI/ButtonPointer.position = Vector2(0,screen_size.y - $UI/ButtonPointer.size.y)
						tween2.set_ease(Tween.EASE_IN_OUT)
						tween2.set_trans(Tween.TRANS_SINE)
						tween2.tween_property($UI/ButtonPointer,"position",Vector2(screen_size.x,$UI/ButtonPointer.position.y),1.2)
						tween2.connect("finished",hoverButton.bind(tutorialBlockPositions[tutorialStep].blockColor))
						#otherwise highlight color to siwtch to 
					else:
						hoverButton(tutorialBlockPositions[tutorialStep].blockColor)
		else:
			if len(tutorialBlockSteps) > tutorialStep:
				if  tutorialBlockSteps[tutorialStep] =="CHECKPOINT":
					var endPosition =  (-1*lastCheckPointBlock.position.y) + (screen_size.y * (2.0/3.0))
					var startPosition = movingObjects.position.y
					var distance = abs(startPosition-endPosition)
					var tween = create_tween()
					tween.tween_property(movingObjects,"position:y",endPosition,distance/1500)
					await tween.finished
					showNextBlocks()
			
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mousePosition = get_viewport().get_mouse_position()
		
		#ensure its not where the buttons are
		#mouse position over buttons check shouldnt be needed anymore as now were using mouse emulation and passthrough fitlers
		#hi dominic that is a pretty cool comment
		if gameState == "TUTORIAL":
			
			var blockPosition = tutorialBlockPositions[tutorialStep].global_position
			if not tutorialChangeColor:
				if tutorialState == "LEARNING":
					if (mousePosition.x < blockPosition.x + 80 and  mousePosition.x > blockPosition.x - 80) and (mousePosition.y < blockPosition.y + 80 and  mousePosition.y > blockPosition.y + -80):
						tutorialStep+=1
						if textTween != null:
							textTween.stop()
							textTweenAlpha.stop()
					
						if not tutorialStep > len(tutorialBlockPositions)-1:
							$UI/Parent/TextContainer/Text.text = tuturialTexts[tutorialStep]
							
							
							
							if tutorialBlockSteps[tutorialStep] =="FREE":
								tutorialState = "FREE"
							if tutorialBlockSteps[tutorialStep] == "CHECKPOINT":
								tutorialState = "CHECKPOINT" #+ tutorialBlockSteps[tutorialStep+1]
								$UI/CheckPointTexts.show()
								$UI/CheckPointTexts.text = "Now its your turn!"
								lastCheckPoint = tutorialStep
								print("CHECKPOINTTttt")
								lastCheckPointBlock = tutorialBlockPositions[tutorialStep-1]
								#
								#var endPosition =  (-1*lastCheckPointBlock.position.y) + (screen_size.y * (2.0/3.0))
								#var startPosition = movingObjects.position.y
								#var distance = abs(startPosition-endPosition)
								#var tween = create_tween()
								#tween.tween_property(movingObjects,"position:y",endPosition,distance/1500)
								#await tween.finished
								
								#showNextBlocks()
								
								#lastCheckPointBlock.setGhost()
						
							
							if len(tutorialBlockSteps) > tutorialStep +0:
								if tutorialBlockSteps[tutorialStep+1] == "FREE" and buttonAnimationPlayed:
									aboutToBeFree = true
									learnedColors = true
									for i in $UI/ColorButtons.get_children():
										i.disabled  = false 
								# if next blocks are different colors 
							if tutorialBlockPositions[tutorialStep].blockColor =="RAINBOW":
								tutorialRainbow = true
							if  tutorialBlockPositions[tutorialStep-1].blockColor != tutorialBlockPositions[tutorialStep].blockColor and learnedColors == false and not tutorialRainbow:
							
									# if we havent played the button animaton yet
								if not buttonAnimationPlayed:
									buttonAnimationPlayed = true
									$UI/ButtonPointer.show()
									var tween = create_tween()
									$UI/ButtonPointer.position = Vector2(0,screen_size.y - $UI/ButtonPointer.size.y)
									tween.set_ease(Tween.EASE_IN_OUT)
									tween.set_trans(Tween.TRANS_SINE)
									tween.tween_property($UI/ButtonPointer,"position",Vector2(screen_size.x,$UI/ButtonPointer.position.y),1.2)
									tween.connect("finished",hoverButton.bind(tutorialBlockPositions[tutorialStep].blockColor))
									#otherwise highlight color to siwtch to 
								else:
									hoverButton(tutorialBlockPositions[tutorialStep].blockColor)
									$UI/Pointer.global_position = tutorialBlockPositions[tutorialStep].global_position -Vector2(64,64)
						else:
							$UI/Pointer.hide()
				
						#Transition to the real game 
					
						#jump
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
				elif tutorialState == "CHECKPOINTFREE" or "FREE":
					
					tutorialState = "FREE"
					$UI/CheckPointTexts.hide()
					$UI/Pointer.hide()
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
					
							
					
		
		elif mousePosition.y < ($UI/ColorButtons.position.y+movingObjects.position.y) and gameState != "OVER":
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
					fadeOutButtons()
					
					
					
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
		else:
			print(mousePosition.y)
			print($UI/ColorButtons.position.y)

func _process(delta: float) -> void:
	#$UI/Difficulty.text = str((round(currentDifficulty*10000))/10000)
	#$UI/Difficulty.text =str(currentDifficulty)
	
	#if len(tutorialBlockPositions) >tutorialStep:
		#$UI/Parent/TextContainer/Text.text ="THIS IS A TEST"
		#$UI/Parent/TextContainer.global_position = tutorialBlockPositions[tutorialStep+0].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,300)
	#
	if rainbowOver == false:
		$UI/RainbowParticles.speed_scale = particleSpeed
	
	if gameState == "PLAYING":
		#updates player movement
		player.velocity = speed*direction
		player.gameSpeed = gameSpeed
		#updates game time and moves background down
		gameRunTime += delta
		spikeSpawnRate += delta/3.0
		
		gameSpeed = baseGameSpeed + 140*(log(gameRunTime)) 
		#gameSpeed = baseGameSpeed + 150*(log(gameRunTime)) 
		#gameSpeed = baseGameSpeed + (130*   pow((log((10+gameRunTime)*0.1)),2))
		
		#gameSpeed += delta
		movingObjects.position.y += delta*gameSpeed
		#update score
		$UI/Score.text = str(comma_format(str(score)))
	
	if gameState == "TUTORIAL":
		if updateTextPosition:
			$UI/Parent/TextContainer.global_position = tutorialBlockPositions[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,300)
			textTween = create_tween().set_loops()
			textTween.tween_property($UI/Parent/TextContainer,"global_position", tutorialBlockPositions[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,350),1.0).set_ease(Tween.EASE_OUT)
			textTween.tween_property($UI/Parent/TextContainer,"global_position", tutorialBlockPositions[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,300),1.0).set_ease(Tween.EASE_IN)
			updateTextPosition = false
			$UI/Parent/TextContainer.modulate.a =1.0
			$UI/Parent.show()
		#if tutorialStep == 0:
	#		$UI/Parent/TextContainer.position = tutorialBlockPositions[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,300)
		
		player.velocity = speed*direction
		player.gameSpeed = gameSpeed
		
		if tutorialState == "CHECKPOINT" and tutorialBlockSteps[tutorialStep+1] == "FREE":
			
			$UI/Parent.hide()
			$UI/Pointer.hide()
			#print("HINDG BUTTON")
		
		if tutorialState == "FREE":
			$UI/Parent.hide()
			$UI/Pointer.hide()
			gameSpeed =200
			movingObjects.position.y += delta*gameSpeed
		else:
			if player.velocity != Vector2.ZERO:
				#$UI/Parent/TextContainer.position = tutorialBlockPositions[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,300)
				#var tween2 = create_tween().set_loops()
				#tween2.tween_property($UI/Parent/TextContainer,"position", tutorialBlockPositions[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,500),0.4).set_ease(Tween.EASE_OUT)
				#tween2.tween_property($UI/Parent/TextContainer,"position", tutorialBlockPositions[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,450),0.4).set_ease(Tween.EASE_IN)
				gameSpeed =2000
				movingObjects.position.y += delta*gameSpeed *1.75
				if not tutorialStep > len(tutorialBlockPositions)-1:
					$UI/Pointer.position = tutorialBlockPositions[tutorialStep].global_position - Vector2(64,64)
					$UI/Parent/TextContainer.global_position = tutorialBlockPositions[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,300)# - $UI/SkipTutorial.size/2.0 - Vector2(0,400)
	if gameState == "TUTORIAL":
		gameSpeed = 0 
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





func spawnBlock(respawning = false):
	var block2
	var block = blockScene.instantiate()
	movingObjects.call_deferred("add_child",block)
	block.number = blocksSpawned
	blocksSpawned += 1
	block.connect("invalidBlock",spawnBlock.bind(true))
	block.connect("blockMissed",gameOver)
	
	
	#set block position
	var blockPosition = Vector2(randi_range(40,screen_size.x-40),randi_range(-750,-700))
	
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
	
		#lastBlockSpawned.number = -1#blocksSpawned-10 #-1
		#block.number = -1#blocksSpawned-10 #-1
		
		lastBlockSpawned.number = -101 - blocksSpawned
		blocksSpawned += 1
		block.number = -101 - blocksSpawned
		blocksSpawned += 1
		
		#print("SPIKE OR COIN SPAWN")
		#spawn the item
		var item = itemScene.instantiate()
		#print("SPAWNING ITEM")
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
			$SpawnTimer.wait_time = (blockSpawnTime *spikeCoolDownTime)
			block2 = blockScene.instantiate()
			movingObjects.call_deferred("add_child",block2)
			block2.number = blocksSpawned -5
			blocksSpawned += 1
			block2.connect("invalidBlock",spawnBlock.bind(true))
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
		#randomColorStreak += 20
	#else:
		#randomColorStreak = 0
	#random chance of making it rainbow
	if randi_range(0,1000) <= rainbowSpawnRate and difficulty != "RAINBOW":
		block.setColor("RAINBOW")
	else:
		#random variance
		var random = randf_range(max(-2,-1*gameRunTime),2)
		#xvalue of the sin function based on run time; a greater constant of muliplication equals higher frequency
		var xvalue = ((gameRunTime*colorTransitionSpeed) + random)*.08
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
	
func gameOver():
	if gameState == "PLAYING":
		$SpawnTimer.stop()
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
	if gameState == "TUTORIAL":
		resetToLastCheckPoint()


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
	

func loadTutorial():
#Tutorial To Do:
#make items respawn
#on free play make sure checkpoint block is the correct block, no skipping blocks
#add rainbow!
	
	
	#reset player
	gameState = "TUTORIAL"
	$UI/CheckPointTexts.hide()
	$UI/Parent.show()
	$UI/Pointer.show()
	$UI/SkipTutorial.show()
	#$UI/StartTutorial.hide()
	fadeOutButtons()
	$UI/Streak.hide()
	$UI/Score.hide()
	buttonAnimationPlayed = false
	gameRunTime = 0
	player.reset()
	$RainbowTimer.stop()
	$FlashTimer.stop()
	$Objects/Player/ColorRect.material.set_shader_parameter("rainbow",false)
	$UI/RainBowBar.hide()
	$UI/RainbowParticles.position = $UI/RainBowBar.position + Vector2(60,885)#$UI/RainBowBar.size.y*2)
	$UI/RainbowParticles.hide()
	$UI/RainbowScreenOverLay.hide()
	rainbowOver = true
	aboutToBeFree = false
	
	
	
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
	learnedColors = false
	tutorialRainbow = false
	
	
	#Spawn all of the setup blocks
	tutorialBlockPositions = []
	tutorialBlockSteps = []
	tutorialStep=0
	lastCheckPoint = 0 
	
	tutorialState = "LEARNING"
	
	
	movingObjects.position.y = 0
	var block = blockScene.instantiate()
	lastCheckPointBlock = block
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x / 2,screen_size.y * (2.0/3.0))
	block.number = -99
	block.setColor("RED")
	block.setGhost()
	block.tutorial = true
	block.connect("blockMissed",gameOver)
	block.show()
	#tutorialBlockPositions.append(block)
	tutorialBlockSteps.append("LEARNING")
	tuturialTexts.append("Click where you \n want your ship to go!")
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x / 4.0,screen_size.y * (5.00/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("RED")
	tutorialBlockSteps.append("LEARNING")
	block.show()
	block.tutorial = true
	block.connect("blockMissed",gameOver)
	tuturialTexts.append("Don't miss!")
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (2.0/6.0),screen_size.y * (2.2/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("RED")
	tutorialBlockSteps.append("CHECKPOINT")
	block.show()
	block.tutorial = true
	block.connect("blockMissed",gameOver)
	tuturialTexts.append("")
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (5.0/6.0),0)
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("RED")
	tutorialBlockSteps.append("FREE")
	block.tutorial = true
	block.connect("blockMissed",gameOver)
	block.hide()
	tuturialTexts.append("")
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (3.0/8.0),screen_size.y * (-2.0/10))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("RED")
	tutorialBlockSteps.append("FREE")
	block.tutorial = true
	block.connect("blockMissed",gameOver)
	block.hide()
	tuturialTexts.append("")
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (4.0/6.0),screen_size.y * (-4/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("RED")
	tutorialBlockSteps.append("FREE")
	block.tutorial = true
	block.connect("blockMissed",gameOver)
	block.hide()
	tuturialTexts.append("")
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (3.0/6.0),screen_size.y * (-7/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("RED")
	tutorialBlockSteps.append("CHECKPOINT")
	block.hide()
	block.tutorial = true
	block.connect("blockMissed",gameOver)
	tuturialTexts.append("Click to change colors")
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (1.0/4.0),screen_size.y * (-8.5/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("GREEN")
	tutorialBlockSteps.append("LEARNING")
	block.tutorial = true
	block.connect("blockMissed",gameOver)
	block.hide()
	tuturialTexts.append("Lets Try Blue!")
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (7.0/8.0),screen_size.y * (-10/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("BLUE")
	tutorialBlockSteps.append("LEARNING")
	block.tutorial = true
	block.connect("blockMissed",gameOver)
	block.hide()
	tuturialTexts.append("Pro Tip: Use your dominant hand to tap blocks, \n and your other hand to change colors")
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (3.0/6.0),screen_size.y * (-11/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("PURPLE")
	block.hide()
	tutorialBlockSteps.append("CHECKPOINT")
	block.tutorial = true
	block.connect("blockMissed",gameOver)
	tuturialTexts.append("")
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (1.0/6.0),screen_size.y * (-13/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("RED")
	block.hide()
	tutorialBlockSteps.append("FREE")
	block.tutorial = true
	block.connect("blockMissed",gameOver)
	tuturialTexts.append("")
	
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (2.0/5.0),screen_size.y * (-15/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("GREEN")
	tutorialBlockSteps.append("FREE")
	block.tutorial = true
	block.hide()
	block.connect("blockMissed",gameOver)
	tuturialTexts.append("")
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (4.0/5.0),screen_size.y * (-16/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("BLUE")
	tutorialBlockSteps.append("FREE")
	block.tutorial = true
	block.hide()
	block.connect("blockMissed",gameOver)
	tuturialTexts.append("")
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (3.0/6.0),screen_size.y * (-19/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("PURPLE")
	tutorialBlockSteps.append("CHECKPOINT")
	block.tutorial = true
	block.hide()
	block.connect("blockMissed",gameOver)
	tuturialTexts.append("Avoid Spikes!")
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (5.0/6.0),screen_size.y * (-21/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("RED")
	tutorialBlockSteps.append("LEARNING")
	block.tutorial = true
	block.hide()
	block.itemAttached = "SPIKE"
	block.connect("blockMissed",gameOver)
	tuturialTexts.append("Dont hit the blade")
	
	var block2 = blockScene.instantiate()
	movingObjects.add_child(block2)
	block2.position = Vector2(screen_size.x * (1.0/6.0),screen_size.y * (-22/10.0))
	tutorialBlockPositions.append(block2)
	block2.number = -99
	block2.setColor("RED")
	tutorialBlockSteps.append("LEARNING")
	block2.tutorial = true
	block2.hide()
	block2.connect("blockMissed",gameOver)
	tuturialTexts.append("Collect Coins!")
	
	#var item = itemScene.instantiate()
	#item.number =-999999999999# blocksSpawned-10 
	#movingObjects.add_child(item)
	#item.createHitBox(block.global_position,block2.global_position,movingObjects,block,block2,"SPIKE")
	#.call_deferred("createHitBox",firstPosition,secondPosition, movingObjects,  lastBlockSpawned, block,type)
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (2.0/6.0),screen_size.y * (-24/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("RED")
	tutorialBlockSteps.append("LEARNING")
	block.tutorial = true
	block.hide()
	tuturialTexts.append("Make sure to hit the coin")
	block.itemAttached = "COIN"
	block.connect("blockMissed",gameOver)
	
	block2 = blockScene.instantiate()
	movingObjects.add_child(block2)
	block2.position = Vector2(screen_size.x * (2.0/6.0),screen_size.y * (-25.5/10.0))
	tutorialBlockPositions.append(block2)
	block2.number = -99
	block2.setColor("RED")
	tutorialBlockSteps.append("LEARNING")
	block2.tutorial = true
	block2.hide()
	block2.connect("blockMissed",gameOver)
	tuturialTexts.append("")
	
	
	#item = itemScene.instantiate()
	#item.number =-999999999999# blocksSpawned-10 
	#movingObjects.add_child(item)
	#item.createHitBox(block.global_position,block2.global_position,movingObjects,block,block2,"COIN")
	
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (3.0/6.0),screen_size.y * (-28/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("RED")
	tutorialBlockSteps.append("CHECKPOINT")
	block.tutorial = true
	block.hide()
	block.connect("blockMissed",gameOver)
	tuturialTexts.append("")
	
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (2.0/3.0),screen_size.y * (-30.5/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("RED")
	tutorialBlockSteps.append("FREE")
	block.tutorial = true
	block.hide()
	block.itemAttached = "SPIKE"
	block.connect("blockMissed",gameOver)
	tuturialTexts.append("")
	
	block2 = blockScene.instantiate()
	movingObjects.add_child(block2)
	block2.position = Vector2(screen_size.x * (7.5/10.0),screen_size.y * (-33.5/10.0))
	tutorialBlockPositions.append(block2)
	block2.number = -99
	block2.setColor("RED")
	tutorialBlockSteps.append("FREE")
	block2.tutorial = true
	block2.hide()
	block2.connect("blockMissed",gameOver)
	tuturialTexts.append("")
	
	#item = itemScene.instantiate()
	#item.number =-999999999999# blocksSpawned-10 
	#movingObjects.add_child(item)
	#item.createHitBox(block.global_position,block2.global_position,movingObjects,block,block2,"SPIKE")
	#.call_deferred("createHitBox",firstPosition,secondPosition, movingObjects,  lastBlockSpawned, block,type)
	
	block2 = blockScene.instantiate()
	movingObjects.add_child(block2)
	block2.position = Vector2(screen_size.x * (1.0/3.0),screen_size.y * (-31.5/10.0))
	tutorialBlockPositions.append(block2)
	block2.number = -99
	block2.setColor("RED")
	tutorialBlockSteps.append("FREE")
	block2.tutorial = true
	block2.hide()
	block2.connect("blockMissed",gameOver)
	tuturialTexts.append("")
	
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (1.0/4.0),screen_size.y * (-34.5/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("RED")
	tutorialBlockSteps.append("FREE")
	block.tutorial = true
	block.hide()
	block.itemAttached = "COIN"
	block.connect("blockMissed",gameOver)
	tuturialTexts.append("")
	
	block2 = blockScene.instantiate()
	movingObjects.add_child(block2)
	block2.position = Vector2(screen_size.x * (1.0/3.0),screen_size.y * (-37.5/10.0))
	tutorialBlockPositions.append(block2)
	block2.number = -99
	block2.setColor("RED")
	tutorialBlockSteps.append("FREE")
	block2.tutorial = true
	block2.hide()
	block2.connect("blockMissed",gameOver)
	tuturialTexts.append("")
	
	
	block2 = blockScene.instantiate()
	movingObjects.add_child(block2)
	block2.position = Vector2(screen_size.x * (1.0/2.0),screen_size.y * (-40.0/10.0))
	tutorialBlockPositions.append(block2)
	block2.number = -99
	block2.setColor("RED")
	tutorialBlockSteps.append("CHECKPOINT")
	block2.tutorial = true
	block2.hide()
	block2.connect("blockMissed",gameOver)
	tuturialTexts.append("Rainbow blocks allow the player \n to hit all the colors!")
	
	#item = itemScene.instantiate()
	#item.number =-999999999999# blocksSpawned-10 
	#movingObjects.add_child(item)
	#item.createHitBox(block.global_position,block2.global_position,movingObjects,block,block2,"COIN")
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (2.0/3.0),screen_size.y * (-42/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("RAINBOW")
	tutorialBlockSteps.append("LEARNING")
	block.tutorial = true
	block.hide()
	block.itemAttached = ""
	block.connect("blockMissed",gameOver)
	tuturialTexts.append("Rainbow runs out after 5 seconds")
	
	block = blockScene.instantiate()
	movingObjects.add_child(block)
	block.position = Vector2(screen_size.x * (2.0/5.0),screen_size.y * (-44/10.0))
	tutorialBlockPositions.append(block)
	block.number = -99
	block.setColor("PURPLE")
	tutorialBlockSteps.append("LEARNING")
	block.tutorial = true
	block.hide()
	block.itemAttached = "COIN"
	block.connect("blockMissed",gameOver)
	tuturialTexts.append("Pro tip: To end rainbow early \n switch to any color")
	
	block2 = blockScene.instantiate()
	movingObjects.add_child(block2)
	block2.position = Vector2(screen_size.x * (4.0/6.0),screen_size.y * (-46.0/10.0))
	tutorialBlockPositions.append(block2)
	block2.number = -99
	block2.setColor("GREEN")
	block2.hide()
	tutorialBlockSteps.append("LEARNING")
	block2.tutorial = true
	tuturialTexts.append("Congrats! Lets start off in easy mode!!!")
	block2.connect("blockMissed",gameOver)
	
	#item = itemScene.instantiate()
	#item.number =-999999999999# blocksSpawned-10 
	#movingObjects.add_child(item)
	#item.createHitBox(block.global_position,block2.global_position,movingObjects,block,block2,"COIN")
	
	
	block2 = blockScene.instantiate()
	movingObjects.add_child(block2)
	block2.position = Vector2(screen_size.x * (1.0/2.0),screen_size.y * (-47.5/10.0))
	tutorialBlockPositions.append(block2)
	block2.number = -100 #-100
	block2.setColor("RED")
	block2.hide()
	tutorialBlockSteps.append("CHECKPOINT")
	block2.tutorial = true
	tuturialTexts.append("")
	block2.connect("blockMissed",gameOver)
	
	$UI/Parent/TextContainer/Text.text = tuturialTexts[0]
	$UI/Parent.show()
	
	#block = blockScene.instantiate()
	#movingObjects.add_child(block)
	#block.position = Vector2(screen_size.x * (5.0/6.0),screen_size.y * (1.0/10.0))
	#tutorialBlockPositions.append(block)
	#block.number = -99
	#block.setColor("RED")
	#
	#block = blockScene.instantiate()
	#movingObjects.add_child(block)
	#block.position = Vector2(screen_size.x * (4.0/6.0),screen_size.y * (-.11))
	#tutorialBlockPositions.append(block)
	#block.number = -99
	#block.setColor("GREEN")
	#
	#block = blockScene.instantiate()
	#movingObjects.add_child(block)
	#block.position = Vector2(screen_size.x * (3.0/6.0),screen_size.y * (-.35))
	#tutorialBlockPositions.append(block)
	#block.number = -99
	#block.setColor("GREEN")
	#
	#block = blockScene.instantiate()
	#movingObjects.add_child(block)
	#block.position = Vector2(screen_size.x * (3.0/6.0),screen_size.y * (-.6))
	#tutorialBlockPositions.append(block)
	#block.number = -100
	#block.setColor("RED")
	updateTextPosition = true
	for i in $UI/ColorButtons.get_children():
		i.disabled = true

	$UI/Parent.position = Vector2(0,0)
	$UI/Parent/TextContainer.global_position = tutorialBlockPositions[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,300)
	
	#var tween = create_tween().set_loops()
	#tween.tween_property($UI/Parent, "scale", Vector2(1.1, 1.1), 0.1).set_ease(Tween.EASE_IN)
	#tween.tween_property($UI/Parent, "scale", Vector2(1, 1), 0.4).set_ease(Tween.EASE_OUT)
	
	#var tween2 = create_tween().set_loops()
	#tween2.tween_property($UI/Parent/TextContainer,"position", tutorialBlockPositions[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,500),0.4).set_ease(Tween.EASE_OUT)
	#tween2.tween_property($UI/Parent/TextContainer,"position", tutorialBlockPositions[tutorialStep].global_position   - ($UI/Parent/TextContainer.size/2.0) - Vector2(0,450),0.4).set_ease(Tween.EASE_IN)


	player.position = Vector2(screen_size.x / 2,screen_size.y * (21.0/30.0))
	player.velocity = Vector2(0, -7000)
	$UI/Pointer.position = tutorialBlockPositions[tutorialStep].global_position -Vector2(64,64)
	$UI/PointerAnimation.play("Hover")
	
	
	
	
	
	
	
#	tween.start()
	#$UI/ColorRect
	#$UI/ButtonAnimation.play("TraverseButtons")
	
func hoverButton(nextBlockColor):
	var i = colorToNumber[nextBlockColor]
	#for i in $UI/ColorButtons.get_children():
		#i.disabled = false
	$UI/ButtonPointer.show()
	var button = $UI/ColorButtons.get_child(i-1)
	button.disabled = false
	$UI/ButtonPointer.size.x = (screen_size.x/4) 
	$UI/ButtonPointer.pivot_offset.x = $UI/ButtonPointer.size.x/2
	$UI/ButtonPointer.position = Vector2( ($UI/ColorButtons.size.x*.25) * (i-1),screen_size.y - $UI/ButtonPointer.size.y)
	$UI/ButtonAnimation.play("Hover")


func fadeOutButtons():
	$UI/TouchAnywhereText.hide()
	var tween = create_tween().set_parallel(true)
	tween.tween_property($UI/Logo, "modulate:a", 0.0, 0.5)
	$UI/Settings.disabled = true
	$UI/Leaderboard.disabled = true
	$UI/Shop.disabled = true
	$UI/StartTutorial.disabled = true
	$UI/Settings.mouse_filter = 1 #Passthrough
	$UI/Leaderboard.mouse_filter = 1 #Passthrough
	$UI/Shop.mouse_filter = 1 #Passthrough
	$UI/StartTutorial.mouse_filter = 1
	tween.tween_property($UI/Settings, "modulate:a", 0.0, 0.5)
	tween.tween_property($UI/Leaderboard, "modulate:a", 0.0, 0.5)
	tween.tween_property($UI/Shop, "modulate:a", 0.0, 0.5)
	tween.tween_property($UI/StartTutorial, "modulate:a", 0.0, 0.5)
	#$UI/StartTutorial.hide()
	

func tutorialOver():

	FileManager.saveTutorial()
	gameState = "READY"
	currentBlock = player.blockOn


func _on_skip_tutorial_pressed() -> void:
	loadGame(false)
	$UI/Pointer.hide()
	$UI/ButtonPointer.hide()
	#$UI/SkipTutorial.hide()
	var tween = create_tween().set_parallel(true)
	$UI/SkipTutorial.disabled = true
	$UI/SkipTutorial.mouse_filter = 1
	tween.tween_property($UI/SkipTutorial, "modulate:a", 0.0, 0.5)
	$UI/Parent.hide()
	FileManager.saveTutorial()
	showButtons()

func showButtons():
	$UI/Streak.show()
	$UI/Score.show()
	#do stuff
	$UI/StartTutorial.show()
	$UI/TouchAnywhereText.show()
	$UI/Logo.modulate.a = 1.0
	$UI/Settings.modulate.a = 1.0
	$UI/Settings.disabled = false
	$UI/Leaderboard.modulate.a = 1.0
	$UI/Leaderboard.disabled = false
	$UI/Shop.modulate.a = 1.0
	$UI/Shop.disabled = false
	$UI/StartTutorial.modulate.a = 1.0
	$UI/StartTutorial.disabled = false
	$UI/Settings.mouse_filter = 0 #Stop
	$UI/Leaderboard.mouse_filter = 0 #Stop
	$UI/Shop.mouse_filter = 0 #Stop
	for c in $UI/ColorButtons.get_children():
		c.disabled = false


func _on_start_tutorial_pressed() -> void:
	loadTutorial()

func resetToLastCheckPoint():
	player.hide()
	tutorialStep = lastCheckPoint
	if player.blockOn != lastCheckPointBlock:
		lastCheckPointBlock.spawnBackIn()
	for i in range(len(tutorialBlockPositions)-lastCheckPoint-1):
	
		var blockState = tutorialBlockSteps[i+lastCheckPoint]
		if blockState == "CHECKPOINT" and i != 0:
			tutorialBlockPositions[i+lastCheckPoint-1].hide()
			break
		tutorialBlockPositions[i+lastCheckPoint].spawnBackIn()
		
		if tutorialBlockPositions[i+lastCheckPoint].itemAttached != null:
			var block = tutorialBlockPositions[i+lastCheckPoint]
			block.deleteAttatchedItem()
			var block2 = tutorialBlockPositions[i+lastCheckPoint+1]
			var item = itemScene.instantiate()
			item.number =-999999999999# blocksSpawned-10 
			movingObjects.add_child(item)
			item.createHitBox(block.global_position,block2.global_position,movingObjects,block,block2,block.itemAttached)
		
		
	#movingObjects.position.y = lastCheckPointBlock.position.y + (screen_size.y * (2.0/3.0))
	tutorialStep = lastCheckPoint
	#if tutorialBlockSteps[tutorialStep-1] == "FREE":
	tutorialState =  tutorialBlockSteps[tutorialStep-1]
	lastCheckPointBlock.spawnBackIn()
	aboutToBeFree = tutorialBlockSteps[tutorialStep+1]== "FREE"
	print(" ARE WE FREE")
	print(tutorialBlockSteps[tutorialStep+1])
	changeColor(lastCheckPointBlock.originalColor) #originalColor #orignialColor
	
	player.velocity  = Vector2.ZERO
	currentBlock = lastCheckPointBlock
	player.blockOn = currentBlock
	player.position = lastCheckPointBlock.position + Vector2(0,140)
	tutorialStep = lastCheckPoint -1
	_on_block_caught()
	tutorialStep = lastCheckPoint 
	
	player.rotation =0
	player.show()
	player.modulate.a = 1
	player.reset()
	print("BLCOK ON:")
	print(player.blockOn)
	for i in range(len(tutorialBlockPositions)-lastCheckPoint):
		tutorialBlockPositions[i].deleted = false
	
	$UI/CheckPointTexts.hide()
	var endPosition =  (-1*lastCheckPointBlock.position.y) + (screen_size.y * (2.0/3.0))
	var startPosition = movingObjects.position.y
	var distance = abs(startPosition-endPosition)
	var tween = create_tween()
	tween.tween_property(movingObjects,"position:y",endPosition,distance/1500)
	await tween.finished
	#lastCheckPointBlock.setGhost()
	tutorialState = "CHECKPOINT"
	$UI/CheckPointTexts.show()
	
	$UI/CheckPointTexts.text = encouragemnetMessages[randi_range(0,len(encouragemnetMessages)-1)]
	

func showNextBlocks(showNextCheckPoint = false): #showNextBlocks
	for i in range(len(tutorialBlockPositions)-lastCheckPoint-0):
		var blockState = tutorialBlockSteps[i+lastCheckPoint+1]
		if blockState == "CHECKPOINT" and i != 0:
			if showNextCheckPoint:
				#if tutorialBlockPositions[i+lastCheckPoint].deleted:
				tutorialBlockPositions[i+lastCheckPoint].spawnBackIn()
			break
		#if tutorialBlockPositions[i+lastCheckPoint].visible == false:
		
		tutorialBlockPositions[i+lastCheckPoint].spawnBackIn()
		#else:
		#	print("NOT DOING THE SPIN")
		if tutorialBlockPositions[i+lastCheckPoint].itemAttached != null:
			var block = tutorialBlockPositions[i+lastCheckPoint]
			block.deleteAttatchedItem()
			var block2 = tutorialBlockPositions[i+lastCheckPoint+1]
			var item = itemScene.instantiate()
			item.number =-999999999999# blocksSpawned-10 
			movingObjects.add_child(item)
			item.createHitBox(block.global_position,block2.global_position,movingObjects,block,block2,block.itemAttached)
	#tutorialBlockCaught
