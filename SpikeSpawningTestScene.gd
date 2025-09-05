extends Node2D
@onready var blockScene = preload("res://Scenes/block.tscn")
@onready var screen_size = Globals.screenSize
@onready var itemScene = preload("res://Scenes/Item.tscn")

func _ready():
	spawnSpike()

func spawnSpike():
	var block = $Block#blockScene.instantiate()
	#self.add_child(block)
	var blockPosition = Vector2(randi_range(90,screen_size.x-90),randi_range(100,400))
	#blockPosition = Vector2(1829,387)
	var firstPosition = blockPosition
	block.position = blockPosition
	print(blockPosition)
	block.setColor("RED")
	block.number = -101
	
	var block2 = blockScene.instantiate()
	self.add_child(block2)
	var blockPosition2 = Vector2(randi_range(90,screen_size.x-90),randi_range(700,1500))
	#blockPosition2 = Vector2(700,1200)
	var secondPosition = blockPosition2
	block2.setColor("RED")
	block2.number = -101
	block2.position = blockPosition2
	
	if firstPosition.distance_to(secondPosition) >350 :
		
		#setBlockColor(lastBlockSpawned,true)
		
		var item = itemScene.instantiate()
		item.number =-999999999999# blocksSpawned-10 
		self.add_child(item)
		
		#set the item type
		var type
		type = "SPIKE"
		item.createHitBox(firstPosition,secondPosition, self,  block2, block,type)
		
		
		#spawn another block
		if true:
			var block3
			block3 = blockScene.instantiate()
			block3.number = -101
			self.add_child(block3)
			var block2Position = Vector2(0,0)
			var spikeSlope = (secondPosition.y-firstPosition.y) / (secondPosition.x -firstPosition.x)
			var inverseSlope  = 1
			if spikeSlope != 0:
				inverseSlope = -1/spikeSlope
			var distanceFromSpike = randf_range(350,500)
			var spikePosition = (firstPosition + secondPosition) /2.0
		
			block2Position = spikePosition
			var spikeDirection = Vector2(1,inverseSlope)
			spikeDirection = spikeDirection.normalized()
			#make it so it always points to the upper
			if spikeDirection.y > 0:
				spikeDirection.y *=-1
				spikeDirection.x *=-1
			block2Position += spikeDirection *distanceFromSpike  #Vector2(distanceFromSpike, distanceFromSpike*inverseSlope)
			
			#slope greater than 10 means verticle (update as needed)
			print(spikeSlope)
			print(inverseSlope)
			if abs(spikeSlope) >10:
				print("VERTICAL")
				if block2Position.y > -50 or (block2Position.x < 90) or (block2Position.x > screen_size.x -90):
					block2Position -= spikeDirection *distanceFromSpike
			
			
			block2Position += Vector2(randf_range(-0,0),randf_range(-0,0))
			block2Position.x = clamp(block2Position.x,90,screen_size.x-90)
			#block2Position.y = clamp(block2Position.y,-1000,-270)
			block3.position = block2Position
			print(block2Position)
			block3.setColor("GREEN")
