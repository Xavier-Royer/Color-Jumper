extends CanvasLayer

var scoreText = '''
[u]High Scores[/u]

[color=gold]easy
[color=white]11,000,000

[color=orange]classic
[color=white]11,000,000

[color=red]colorful
[color=white]11,000,000

[color=purple]rainbow
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
	$ScoreText.text = "[u]High Scores[/u]\n\n[color=gold]easy\n[color=white]{easy}\n\n[color=orange]classic\n[color=white]{classic}\n\n[color=red]colorful\n[color=white]{colorful}\n\n[color=purple]rainbow\n[color=white]{rainbow}".format({"easy": comma_format(FileManager.highScore[0]), "classic": comma_format(FileManager.highScore[1]), "colorful": comma_format(FileManager.highScore[2]), "rainbow": comma_format(FileManager.highScore[3])})
