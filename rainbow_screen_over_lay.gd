extends ColorRect
var previousTween = null 
var gameOver = false

func rainbowStart():
	gameOver = false
	get_parent().get_node("FlashScreen").hide()
	self.modulate = Color(0,0,0,.5)
	self.show()
	$RainbowFade.start(4.7)
	$FlashTimer.start(4.9)



func _on_rainbow_fade_timeout() -> void:

	
	if previousTween != null:
		previousTween.stop()
	var currentTween = create_tween()
	currentTween.set_ease(Tween.EASE_OUT)
	currentTween.set_trans(Tween.TRANS_CIRC)
	
	currentTween.tween_property(self, "modulate", Color(1,1,1,0) ,0.3)
	currentTween.connect("finished",hideFlash)
	previousTween = currentTween


func _on_flash_timer_timeout() -> void:
	if gameOver == false:
		get_parent().get_node("FlashScreen").show()

func hideFlash():
	print("HIDE")
	get_parent().get_node("FlashScreen").hide()
