extends ColorRect
var previousTween = null 
var gameOver = false
var rainbowGoing = false

func rainbowStart():
	gameOver = false
	rainbowGoing = true
	get_parent().get_node("FlashScreen").hide()
	self.modulate = Color(1.0,1.0,1.0,.5)
	self.show()
	$RainbowFade.start(5)
	#$FlashTimer.start(4.8)



func _on_rainbow_fade_timeout() -> void:

	
	if previousTween != null:
		previousTween.stop()
	var currentTween = create_tween()
	currentTween.set_ease(Tween.EASE_OUT)
	currentTween.set_trans(Tween.TRANS_CIRC)
	
	currentTween.tween_property(self, "modulate", Color(0.3,0.3,0.3,0.3) ,0.4)
	#currentTween.connect("finished",hideFlash)
	previousTween = currentTween


func _on_flash_timer_timeout() -> void:
	hideFlash()
	#if gameOver == false:
		#get_parent().get_node("FlashScreen").show()
		#if get_parent().get_parent().currentBlock != null:
			#get_parent().get_node("FlashScreen").modulate = get_parent().get_parent().currentBlock.modulate
		#get_parent().get_node("FlashScreen").modulate.a = 70
func hideFlash():
	print("HIDE")
	#get_parent().get_node("FlashScreen").hide()
	
	self.hide()

func flashColor(blockColor):
	#get_parent().get_node("FlashScreen").show()
	#get_parent().get_node("FlashScreen").modulate = Color(blockColor.r,blockColor.g,blockColor.b,0.5)
#	get_parent().get_node("FlashScreen").modulate.a = 1
	previousTween.stop() 
	rainbowGoing = false
	self.modulate = Color(blockColor.r,blockColor.g,blockColor.b,0.3)
	$FlashTimer.start(.12)
