extends Node2D

@onready var blockScene = preload("res://block.tscn")

func playGame():
	print("playing game")

func loadGame():
	var block = blockScene.instantiate()
	$Blocks.add_child(block)
	block.position = Vector2(240,600) + self.position
	block.setColor("RED")
	
	for i in randi_range(10,15):
		block = blockScene.instantiate()
		$Blocks.add_child(block)
		block.position = Vector2(randi_range(10,470),randi_range(20,520)) + self.position
		block.setColor("RED")
