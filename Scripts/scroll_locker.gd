extends ScrollContainer

signal selection_changed(item: ShopSlot, index: int)

@export var content_path: NodePath
@export var snap_duration := 0.20
@export var settle_frames := 5
@export var transType := Tween.TRANS_CUBIC
@export var easeType := Tween.EASE_OUT

const ShopSlotScene: PackedScene = preload("res://Scenes/shopSlot.tscn")

var _content: HBoxContainer
var _centers: PackedFloat64Array = []
var _items: Array[ShopSlot] = []        # <─ parallel to _centers (no sorting)

var _pending_snap := false
var _last_scroll := 0.0
var _still_count := 0
var _tween: Tween

var current_index := -1                  # <─ index of selected item
func get_current_item() -> ShopSlot: # convenience getter
	if current_index < 0:
		return null     
	return _items[current_index]

func _ready() -> void:
	_content = get_node(content_path) as HBoxContainer


	for i in CollectibleDB.COLLECTIBLES:
		if i.type == self.name.to_lower().substr(0,len(self.name)-1):
			var node: ShopSlot = ShopSlotScene.instantiate()
			node.setup(i)
			if node.data.id not in CollectibleDB.OWNED:
				node.color.a = 0.5
			_content.add_child(node)

	# padding squares at the end
	var padding3 = _content.get_child(0).duplicate()
	padding3.name = "Padding3"
	_content.add_child(padding3)
	var padding4 = _content.get_child(0).duplicate()
	padding4.name = "Padding4"
	_content.add_child(padding4)

	resized.connect(_schedule_recompute)
	if _content:
		_content.child_entered_tree.connect(func(_n): _schedule_recompute())
		_content.child_exiting_tree.connect(func(_n): _schedule_recompute())

	await get_tree().process_frame
	await get_tree().process_frame
	_recompute_metrics()
	set_default()

func refresh() -> void:
	_recompute_metrics()

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

	# viewport center
	var viewport_center := float(scroll_horizontal) + size.x * 0.5

	# find nearest index (keep index, not just value)
	var best_i := 0
	var best_d: float = abs(_centers[0] - viewport_center)
	for i in range(1, _centers.size()):
		var d: float = abs(_centers[i] - viewport_center)
		if d < best_d:
			best_d = d
			best_i = i

	var target := int(_centers[best_i] - size.x * 0.5)
	var max_scroll := int(get_h_scroll_bar().max_value)
	target = clampi(target, 0, max_scroll)

	_tween = create_tween().set_trans(transType).set_ease(easeType)
	_tween.tween_property(self, "scroll_horizontal", target, snap_duration)
	_tween.finished.connect(func():
		_set_current(best_i)           # <─ update selected once we’ve snapped
	, CONNECT_ONE_SHOT)

func _set_current(i: int) -> void:
	if i == current_index: return
	current_index = i
	emit_signal("selection_changed", _items[i], i)
	
func set_default() -> void:
	var target := int(_centers[0] - size.x * 0.5)
	var max_scroll := int(get_h_scroll_bar().max_value)
	target = clampi(target, 0, max_scroll)

	_tween = create_tween().set_trans(transType).set_ease(easeType)
	_tween.tween_property(self, "scroll_horizontal", target, snap_duration)

func _schedule_recompute() -> void:
	call_deferred("_deferred_recompute")

func _deferred_recompute() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_recompute_metrics()

func _recompute_metrics() -> void:
	_centers.clear()
	_items.clear()
	if not _content:
		return
	for child in _content.get_children():
		if child.name.contains("Padding"):
			continue
		if child is Control:
			var cc := child as Control
			_centers.append(cc.position.x + cc.size.x * 0.5)
		if child is ShopSlot:
			_items.append(child as ShopSlot)

func snap_now() -> void:
	_pending_snap = false
	_snap_to_nearest()
