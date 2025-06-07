extends Node
@onready var currentScreen = $HomeScreen
var onScreenPosition = Vector2(0,0)
var offScreenPosition = Vector2(480,0)


func _ready() -> void:
	$GameScreen.connect("gameOverScreen",next_screen.bind($GameOverScreen))


#screen transitioner, waits until finished to return
func next_screen(nextScreen):
	currentScreen.visible = false
	nextScreen.visible = true
	currentScreen = nextScreen
	'''
	var screenTransition = create_tween()
	screenTransition.set_ease(Tween.EASE_IN)
	screenTransition.set_trans(Tween.TRANS_BACK)
	screenTransition.tween_property(currentScreen, "position", offScreenPosition,.5)
	screenTransition.tween_property(nextScreen, "position", onScreenPosition,.5)
	currentScreen = nextScreen
	await screenTransition.finished
	'''
	





#when play pressed load in new game
func _on_play_pressed() -> void:
	$GameScreen.loadGame()
	await next_screen($GameScreen)
	$GameScreen.playGame()
