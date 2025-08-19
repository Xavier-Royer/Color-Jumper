extends CanvasLayer
var difficulties = ["EASY", "CLASSIC" , "COLORFUL", "RAINBOW"]


func _on_menu_button_item_selected(index: int) -> void:
	FileManager.setDifficulty(difficulties[index])


func loadSettings():
	var index = difficulties.find(FileManager.difficulty)
	$Difficulty.select(index)


func _on_resetscores_button_pressed() -> void:
	$ConfirmationDialog.size = Vector2i(Globals.screenSize.x * 0.75, Globals.screenSize.y * 0.15)
	$ConfirmationDialog.popup_centered()



func _on_confirmed():
	var index = difficulties.find(FileManager.difficulty)
	FileManager.setHighScore(0, index)
