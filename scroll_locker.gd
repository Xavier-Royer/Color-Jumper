extends Node2D
var items = []
var itemSpacing = 75
var itemsDisplayed 
var scrollPosition = 0 
var center = Vector2(600,300)
var itemSize = 128
var itemsShowing = 5
var visibleTotalLength

var dragging = false
var initialDragPosition = Vector2(0,0)
var endDragPosition = Vector2(0,0)
var dragTime = 0

func _ready() -> void:
	for c in self.get_children():
		items.append(c)
	displayItems()

func displayItems():
	#assumes that there are an odd number of items showing 
	visibleTotalLength = (itemsShowing * itemSize) + (itemsShowing * (itemSpacing-1) )
	var xOffset = 0
	var totalItems = items.size()
	
	var trueHalfLength = ( (totalItems/2.0) * itemSize) + ( ((totalItems+1)/2.0)* (itemSpacing) )
	
	var scrollOffset =  fmod(scrollPosition , (2.0*(trueHalfLength))-itemSpacing ) 
	
	
	
	var direction = 1
	for i in items:
		i.position.y = center.y
		
		var xpos =  ((xOffset * direction) +scrollOffset)
		
		
		if abs(xpos) > trueHalfLength:
			var overFlow = ( abs(xpos)-  (2*trueHalfLength) +itemSpacing )
			if xpos > 0:
				xpos =  overFlow 
			else:
				xpos = -overFlow 
		
		i.position.x = center.x + xpos
		
		
		var distFromCenter = abs(xpos)
		
		var itemScale = ((visibleTotalLength/2.0)- distFromCenter) / (visibleTotalLength/2.0)
		var transParentScale = pow(itemScale,.5)
		itemScale = pow(itemScale, .25)
		
		i.modulate = Color(1,1,1,transParentScale)
		i.scale = Vector2(itemScale,itemScale)
		#print(itemScale)
		
		if  distFromCenter > visibleTotalLength/2:
			i.hide()
		else:
			i.show()
		
		if direction == 1:
			xOffset += itemSize + itemSpacing
		direction*=-1

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		dragging = true
		initialDragPosition = get_viewport().get_mouse_position()
		dragTime = 0.0
	elif event is InputEventScreenTouch and event.is_released():
		dragging = false
		endDragPosition = get_viewport().get_mouse_position()
		var totalDistance = endDragPosition.x  - initialDragPosition.x
		var dragVelcoity = totalDistance/dragTime
		print(totalDistance)
		print(dragTime)
		print(dragVelcoity)
		var tween  = create_tween()
		tween.tween_property(self,"scrollPosition", scrollPosition+(dragVelcoity*.05),0.2)
		

func _process(delta: float) -> void:
	#scrollPosition -= 1
	dragTime+= delta
	displayItems()
		
		
