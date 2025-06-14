extends StaticBody2D

var playerOn  = false
signal invalidBlock
@onready var blockArea = $SpawnRadius
var number =0 
var deleted = false
#var spawnComplete = false

func _ready() -> void:
	if $SpawnRadius.has_overlapping_areas():
		self.queue_free()
		print("block deletred")
	

func setColor(color):
	for i in range(4):
		self.set_collision_layer_value(i+1,false)
	
	#setup blocks color and collision layers
	if color == "RED":
		self.modulate = Color(255,0,0)
		self.set_collision_layer_value(1,true)
	elif color == "GREEN":
		self.modulate = Color(0,255,0)
		self.set_collision_layer_value(2,true)
	elif color == "BLUE":
		self.modulate = Color(0,0,255)
		self.set_collision_layer_value(3,true)
	elif color == "PURPLE":
		self.modulate = Color(255,0,255)
		self.set_collision_layer_value(4,true)
	else: # for rainbow set all color collision layers to true
		for i in range(4):
			self.set_collision_layer_value(i+1,true)


func delete():
	queue_free()


func _on_spawn_radius_area_entered(_area: Area2D) -> void:
	if not deleted:
		var areas = $SpawnRadius.get_overlapping_areas()
	
		for a in areas:
			if a.get_parent().number < number:
				blockArea.set_collision_mask_value(9,false)
				blockArea.set_collision_layer_value(9,false)
				queue_free()
				print("block delted")
				emit_signal("invalidBlock")
				deleted = true
				break
			
	
	#print("invalid")
	##need to update the spawn function to fix this, bc this goes into an infinite loop	
	#
	#
	##
	#
