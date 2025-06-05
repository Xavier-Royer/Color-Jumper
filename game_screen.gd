extends Node2D

@onready var blockScene = preload("res://block.tscn")
@onready var player = $Player
var currentColor
var currentBlock

var colorToNumber ={
	"RED": 1,
	"GREEN":2,
	"BLUE":3,
	"PURPLE":4
}

func _ready() -> void:
	for button in $ColorButtons.get_children():
		button.connect("pressed",changeColor.bind(button.name))

func playGame():
	print("playing game")

func loadGame():
	currentBlock = null
	changeColor("RED")
	
	#generate first block which the layer is on
	var block = blockScene.instantiate()
	$Blocks.add_child(block)
	block.position = Vector2(240,600) + self.position
	block.setColor("RED")
	
	
	#generates the rest of the starting blocks 
	for i in randi_range(10,15):
		block = blockScene.instantiate()
		$Blocks.add_child(block)
		block.position = Vector2(randi_range(10,470),randi_range(20,520)) + self.position
		block.setColor("RED")
	
	player.position = Vector2(240,590)

func changeColor(newColor):
	for i in range(4):
		player.set_collision_mask_value(i+1,false)
	player.set_collision_mask_value(colorToNumber[newColor],true)
	
	if currentBlock != null:
		currentBlock.setColor(newColor)

func _on_player_area_entered(area: Area2D) -> void:
	print("Hit block")
	currentBlock = area
