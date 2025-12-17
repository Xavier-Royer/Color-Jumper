extends CanvasLayer
var current_collectible = null
var coins = 0 

func _on_selection_changed(item: ShopSlot, _index: int) -> void:
	var collectible: Collectible = item.data
	match collectible.type:
		"skin":
			CollectibleDB.CURRENT["skin"] = collectible
			current_collectible = collectible
			$Player/ColorRect.texture = collectible.icon
			$Player.resetAnimation()
			if collectible.id not in CollectibleDB.OWNED:
				$SkinBuySection/SkinCost.visible = true
				$SkinBuySection/SkinBuy.visible = true
				$SkinBuySection/EquippedLabel.visible = false
				if collectible.price <= coins: 
					$SkinBuySection/SkinBuy.disabled = false
				else:
					$SkinBuySection/SkinBuy.disabled = true
			else:
				$SkinBuySection/SkinCost.visible = false
				$SkinBuySection/SkinBuy.visible = false
				$SkinBuySection/EquippedLabel.visible = true
		"trail":
			CollectibleDB.CURRENT["trail"] = collectible
			current_collectible = collectible
			$Player/Trail.texture = collectible.icon
			$Player/Trail2.texture = collectible.icon
			if collectible.id not in CollectibleDB.OWNED:
				$SkinBuySection/SkinCost.visible = true
				$SkinBuySection/SkinBuy.visible = true
				$SkinBuySection/EquippedLabel.visible = false
				if collectible.price <= coins: 
					$SkinBuySection/SkinBuy.disabled = false
				else:
					$SkinBuySection/SkinBuy.disabled = true
			else:
				$SkinBuySection/SkinCost.visible = false
				$SkinBuySection/SkinBuy.visible = false
				$SkinBuySection/EquippedLabel.visible = true
		"theme":
			CollectibleDB.CURRENT["theme"] = collectible
			current_collectible = collectible
			if collectible.id not in CollectibleDB.OWNED:
				$SkinBuySection/SkinCost.visible = true
				$SkinBuySection/SkinBuy.visible = true
				$SkinBuySection/EquippedLabel.visible = false
				if collectible.price <= coins: 
					$SkinBuySection/SkinBuy.disabled = false
				else:
					$SkinBuySection/SkinBuy.disabled = true
			else:
				$SkinBuySection/SkinCost.visible = false
				$SkinBuySection/SkinBuy.visible = false
				$SkinBuySection/EquippedLabel.visible = true
	
func startPlayerAnimation():
	$Player.resetAnimation()

func on_loading_shop_screen():
	startPlayerAnimation()
	FileManager.loadCoins()
	coins = FileManager.coins
	$CoinLabel.text = str(coins) + "[img]res://Textures/Coin.png[/img]"
	$TabContainer/Skins.reset()
	$TabContainer/Skins.set_to_item(CollectibleDB.COLLECTIBLES[0])
	#$TabContainer/Themes.reset()
	#$TabContainer/Trails.reset()


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
	$"../GameScreen/Objects/Player/Trail".texture = CollectibleDB.CURRENT["trail"].icon
	$"../GameScreen/Objects/Player/Trail2".texture = CollectibleDB.CURRENT["trail"].icon
	#set real trail and theme here


func _on_skin_buy_pressed() -> void:
	coins -= current_collectible.price
	FileManager.coins = coins
	FileManager.saveCoins()
	$CoinLabel.text = str(coins) + "[img]res://Textures/Coin.png[/img]"
	$SkinBuySection/SkinCost.visible = false
	$SkinBuySection/SkinBuy.visible = false
	$SkinBuySection/EquippedLabel.visible = true
	
	if current_collectible.type == "skin":
		$TabContainer/Skins.buy_current_node()
	elif current_collectible.type == "trail":
		$TabContainer/Trails.buy_current_node()
	else:
		$TabContainer/Themes.buy_current_node()
	
	#ts does not actaully store data :/
	CollectibleDB.OWNED.append(current_collectible.id)
	FileManager.owned = CollectibleDB.OWNED
	FileManager.saveOwned()
	
	pass # Replace with function body.
