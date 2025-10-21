extends ScrollContainer

@export var content_path: NodePath
@export var snap_duration := 0.20            # seconds
@export var settle_frames := 5               # still frames before snapping
@export var trans := Tween.TRANS_CUBIC
@export var ease := Tween.EASE_OUT

const ShopSlotScene: PackedScene = preload("res://Scenes/shopSlot.tscn")

var _content: HBoxContainer
var _centers: PackedFloat64Array = []

var _pending_snap := false
var _last_scroll := 0.0
var _still_count := 0
var _tween: Tween

func _ready() -> void:
	_content = get_node(content_path) as HBoxContainer
	var c=0
	for i in CollectibleDB.COLLECTIBLES:
		c+=1
		var node: ShopSlot = ShopSlotScene.instantiate()
		node.setup(i)
		if node.data.id not in CollectibleDB.OWNED:
			node.color.a = 0.5
		_content.add_child(node)
		
	#add padding squares at the end
	var padding3 = _content.get_child(0).duplicate()
	padding3.name = "Padding3"
	_content.add_child(padding3)
	var padding4 = _content.get_child(0).duplicate()
	padding4.name = "Padding4"
	_content.add_child(padding4)
	
			
	# Recompute on layout-affecting changes
	resized.connect(_schedule_recompute)
	if _content:
		_content.child_entered_tree.connect(func(_n): _schedule_recompute())
		_content.child_exiting_tree.connect(func(_n): _schedule_recompute())
		
	await get_tree().process_frame
	await get_tree().process_frame
	await _recompute_metrics()

func refresh() -> void:
	# Call after adding/removing/resizing items at runtime
	await _recompute_metrics()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_start_pending_snap()
	elif event is InputEventScreenTouch and not event.pressed:
		_start_pending_snap()

func _process(_delta: float) -> void:
	if _pending_snap:
		var s := float(scroll_horizontal)
		if abs(s - _last_scroll) < 0.5:
			_still_count += 1
		else:
			_still_count = 0
		_last_scroll = s
		if _still_count >= settle_frames:
			_pending_snap = false
			_snap_to_nearest()

func _start_pending_snap() -> void:
	_pending_snap = true
	_still_count = 0
	_last_scroll = -9e9

func _snap_to_nearest() -> void:
	if _centers.is_empty():
		return

	if _tween and _tween.is_running():
		_tween.kill()

	# Find nearest item center to the viewport center
	var viewport_center := float(scroll_horizontal) + size.x * 0.5
	var nearest_center := _centers[0]
	var best = abs(nearest_center - viewport_center)
	for c in _centers:
		var d = abs(c - viewport_center)
		if d < best:
			best = d
			nearest_center = c

	var target := int(nearest_center - size.x * 0.5)
	var max_scroll := int(get_h_scroll_bar().max_value)
	target = clampi(target, 0, max_scroll)

	_tween = create_tween().set_trans(trans).set_ease(ease)
	_tween.tween_property(self, "scroll_horizontal", target, snap_duration)

func _schedule_recompute() -> void:
	# Defer to after layout settles
	call_deferred("_deferred_recompute")

func _deferred_recompute() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await _recompute_metrics()

func _recompute_metrics() -> void:
	_centers.clear()
	if not _content:
		return
	# Collect true centers from laid-out children (mixed widths supported)
	for child in _content.get_children():
		if child.name.contains("Padding"):
			continue
		if child is Control:
			var cc := child as Control
			_centers.append(cc.position.x + cc.size.x * 0.5)
	_centers.sort()

# Optional helper if you want to snap from code (e.g., after a selection change)
func snap_now() -> void:
	_pending_snap = false
	_snap_to_nearest()
