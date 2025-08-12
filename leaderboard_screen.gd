extends CanvasLayer

var scoreText = '''
[u]High Scores[/u]

[color=gold]easy
[color=white]11,000,000

[color=orange]medium
[color=white]11,000,000

[color=red]hard
[color=white]11,000,000

[color=purple]extreme
[color=white]11,000,000
'''
func comma_format(num_stra: int) -> String:
	var num_str = str(num_stra)
	var result := ""
	var count := 0
	for i in range(num_str.length() - 1, -1, -1):
		result = num_str[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result
	return result

func loadLeaderboard():
	$ScoreText.text = "[u]High Scores[/u]\n\n[color=gold]easy\n[color=white]{easy}\n\n[color=orange]medium\n[color=white]{medium}\n\n[color=red]hard\n[color=white]{hard}\n\n[color=purple]extreme\n[color=white]{extreme}".format({"easy": comma_format(FileManager.highScore[0]), "medium": comma_format(FileManager.highScore[1]), "hard": comma_format(FileManager.highScore[2]), "extreme": comma_format(FileManager.highScore[3])})
