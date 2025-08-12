extends CanvasLayer
var difficulties = ["EASY", "MEDIUM" , "HARD", "EXTREME"]


func _on_menu_button_item_selected(index: int) -> void:
	FileManager.setDifficulty(difficulties[index])


func loadSettings():
	var index = difficulties.find(FileManager.difficulty)
	$Difficulty.select(index)


func _on_resetscores_button_pressed() -> void:
	for i in difficulties.size():
		FileManager.setHighScore(0, i)
