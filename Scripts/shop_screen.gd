extends CanvasLayer



func _on_selection_changed(item: ShopSlot, _index: int) -> void:
	var collectible: Collectible = item.data
	match collectible.type:
		"skin":
			CollectibleDB.CURRENT["skin"] = collectible
			$Player/ColorRect.texture = collectible.icon
			if collectible.id not in CollectibleDB.OWNED:
				$SkinBuySection.visible = true
			else:
				$SkinBuySection.visible = false
		"trail":
			CollectibleDB.CURRENT["trail"] = collectible
			if collectible.id not in CollectibleDB.OWNED:
				$TrailBuySection.visible = true
			else:
				$TrailBuySection.visible = false
		"theme":
			CollectibleDB.CURRENT["theme"] = collectible
			if collectible.id not in CollectibleDB.OWNED:
				$ThemeBuySection.visible = true
			else:
				$ThemeBuySection.visible = false
	
		


func _on_home_pressed() -> void:
	if CollectibleDB.CURRENT["skin"].id not in CollectibleDB.OWNED:
		CollectibleDB.CURRENT["skin"] = CollectibleDB.get_default_skin()
		$Options/skin.set_default()
		$Player/ColorRect.texture =CollectibleDB.get_default_skin().icon
	if CollectibleDB.CURRENT["trail"].id not in CollectibleDB.OWNED:
		CollectibleDB.CURRENT["trail"] = CollectibleDB.get_default_trail()
		$Options/trail.set_default()
		#set shop menu trail here
	if CollectibleDB.CURRENT["trail"].id not in CollectibleDB.OWNED:
		CollectibleDB.CURRENT["trail"] = CollectibleDB.get_default_theme()
		$Options/theme.set_default()
		#set shop menu theme here
		
	$"../GameScreen/Objects/Player/ColorRect".texture = CollectibleDB.CURRENT["skin"].icon
	#set real trail and theme here
