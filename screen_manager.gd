extends Node
@onready var currentScreen = $GameScreen
var onScreenPosition = Vector2(0,0)
@onready var offScreenPosition = Vector2(Globals.screenSize.x,0)



func _ready() -> void:
	$SettingsScreen.offset = offScreenPosition
	$GameScreen.connect("gameOverScreen",$GameOverScreen.show)

func next_screen(nextScreen):
	#screen transition
	var screenTransition = create_tween()
	screenTransition.set_ease(Tween.EASE_IN)
	screenTransition.set_trans(Tween.TRANS_BACK)
	screenTransition.tween_property(currentScreen, "offset", offScreenPosition,.5)
	await screenTransition.finished
	
	currentScreen.visible = false
	nextScreen.visible = true

	screenTransition = create_tween()
	screenTransition.set_ease(Tween.EASE_IN)
	screenTransition.set_trans(Tween.TRANS_BACK)
	screenTransition.tween_property(nextScreen, "offset", onScreenPosition,.5)
	currentScreen = nextScreen
	await screenTransition.finished
	





#when play pressed load in new game
func _on_play_pressed() -> void:
	#on play press reset everything
	$GameScreen.loadGame()
	$GameScreen/UI/TouchAnywhereText.show()
	$GameScreen/UI/Logo.modulate.a = 1.0
	$GameScreen/UI/Settings.modulate.a = 1.0
	$GameScreen/UI/Settings.disabled = false
	$GameScreen/UI/Leaderboard.modulate.a = 1.0
	$GameScreen/UI/Leaderboard.disabled = false
	$GameScreen/UI/Settings.mouse_filter = 0 #Stop
	$GameScreen/UI/Leaderboard.mouse_filter = 0 #Stop

	$GameOverScreen.hide()
	$GameScreen.show()
	$GameScreen.show()
	
	


func _on_settings_pressed() -> void:
	$SettingsScreen.loadSettings()
	next_screen($SettingsScreen)
	
func _on_home_pressed():
	next_screen($GameScreen)
	_on_play_pressed()
