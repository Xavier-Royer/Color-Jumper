extends HBoxContainer

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

func set_text(place: int, name: String, score: int):
	$Place.text = str(place) + "."
	$Username.text = name
	$Score.text =  comma_format(score)
	if place == 1:
		$Place.add_theme_color_override("font_color", Color(0.763, 0.564, 0.097, 1.0))
		$Username.add_theme_color_override("font_color", Color(0.763, 0.564, 0.097, 1.0))
		$Score.add_theme_color_override("font_color", Color(0.763, 0.564, 0.097, 1.0))
	elif place == 2:
		$Place.add_theme_color_override("font_color", Color(0.393, 0.393, 0.393, 1.0))
		$Username.add_theme_color_override("font_color", Color(0.393, 0.393, 0.393, 1.0))
		$Score.add_theme_color_override("font_color", Color(0.393, 0.393, 0.393, 1.0))
	elif place == 3:
		$Place.add_theme_color_override("font_color", Color(0.662, 0.369, 0.24, 1.0))
		$Username.add_theme_color_override("font_color", Color(0.662, 0.369, 0.24, 1.0))
		$Score.add_theme_color_override("font_color", Color(0.662, 0.369, 0.24, 1.0))
	else:
		$Place.remove_theme_color_override("font_color")
		$Username.remove_theme_color_override("font_color")
		$Score.remove_theme_color_override("font_color")
