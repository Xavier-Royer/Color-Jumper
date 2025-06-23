extends CanvasLayer
var difficulties = ["EASY", "MEDIUM" , "HARD", "EXTREME"]

func _on_menu_button_item_selected(index: int) -> void:
	FileManager.setDifficulty(difficulties[index])


func loadSettings():
	var index = difficulties.find(FileManager.difficulty)
	$Difficulty.select(index)
