extends CanvasLayer



func _on_selection_changed(item: ShopSlot, _index: int) -> void:
	var collectible: Collectible = item.data
	match collectible.type:
		"skin":
			CollectibleDB.CURRENT["skin"] = collectible
			$Player/ColorRect.texture = collectible.icon
			if collectible.id not in CollectibleDB.OWNED:
				$SkinBuySection/SkinCost.visible = true
				$SkinBuySection/SkinBuy.visible = true
				$SkinBuySection/EquippedLabel.visible = false
			else:
				$SkinBuySection/SkinCost.visible = false
				$SkinBuySection/SkinBuy.visible = false
				$SkinBuySection/EquippedLabel.visible = true
		"trail":
			CollectibleDB.CURRENT["trail"] = collectible
			if collectible.id not in CollectibleDB.OWNED:
				$TrailBuySection/SkinCost.visible = true
				$TrailBuySection/SkinBuy.visible = true
				$TrailBuySection/EquippedLabel.visible = false
			else:
				$TrailBuySection/SkinCost.visible = false
				$TrailBuySection/SkinBuy.visible = false
				$TrailBuySection/EquippedLabel.visible = true
		"theme":
			CollectibleDB.CURRENT["theme"] = collectible
			if collectible.id not in CollectibleDB.OWNED:
				$ThemeBuySection/SkinCost.visible = true
				$ThemeBuySection/SkinBuy.visible = true
				$ThemeBuySection/EquippedLabel.visible = false
			else:
				$ThemeBuySection/SkinCost.visible = false
				$ThemeBuySection/SkinBuy.visible = false
				$ThemeBuySection/EquippedLabel.visible = true
	
		


func _on_home_pressed() -> void:
	if CollectibleDB.CURRENT["skin"].id not in CollectibleDB.OWNED:
		CollectibleDB.CURRENT["skin"] = CollectibleDB.get_default_skin()
		$TabContainer/Skins.set_default()
		$Player/ColorRect.texture =CollectibleDB.get_default_skin().icon
	if CollectibleDB.CURRENT["trail"].id not in CollectibleDB.OWNED:
		CollectibleDB.CURRENT["trail"] = CollectibleDB.get_default_trail()
		$TabContainer/Trails.set_default()
		#set shop menu trail here
	if CollectibleDB.CURRENT["trail"].id not in CollectibleDB.OWNED:
		CollectibleDB.CURRENT["trail"] = CollectibleDB.get_default_theme()
		$TabContainer/Themes.set_default()
		#set shop menu theme here
		
	$"../GameScreen/Objects/Player/ColorRect".texture = CollectibleDB.CURRENT["skin"].icon
	#set real trail and theme here
