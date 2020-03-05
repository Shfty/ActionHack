class_name CurveControlPoint
extends DraggableRect

signal left_tangent_changed(tangent)
signal right_tangent_changed(tangent)

export(float) var left_tangent = 0 setget set_left_tangent
export(float) var right_tangent = 0 setget set_right_tangent

func _ready() -> void:
	if Engine.is_editor_hint():
		update_left_handle()
		update_right_handle()

func set_left_tangent(new_left_tangent: float) -> void:
	if left_tangent != new_left_tangent:
		left_tangent = new_left_tangent
		update_left_handle()

func update_left_handle():
	if not is_inside_tree():
		return

	var left_handle = get_tangent_handle(false)
	var rad = atan(left_tangent)
	left_handle.rect_position = Vector2(2, 2) + (Vector2(cos(rad), sin(rad)) * get_parent().rect_size).normalized() * -20
	update()

func set_right_tangent(new_right_tangent: float) -> void:
	if right_tangent != new_right_tangent:
		right_tangent = new_right_tangent
		update_right_handle()

func update_right_handle():
	if not is_inside_tree():
		return

	var right_handle = get_tangent_handle(true)
	var rad = atan(right_tangent)
	right_handle.rect_position = Vector2(2, 2) + (Vector2(cos(rad), sin(rad)) * get_parent().rect_size).normalized() * 20
	update()

func get_tangent_handle(left: bool) -> DraggableRect:
	var node_name = ("Left" if left else "Right") + "Handle"
	var node: DraggableRect = null
	if has_node(node_name):
		node = get_node(node_name)
	else:
		node = DraggableRect.new()
		node.name = node_name
		node.rect_size = Vector2(4, 4)
		node.connect("dragged", self, "tangent_handle_moved", [left], CONNECT_PERSIST)
		add_child(node)
		if is_inside_tree():
			var edited_scene_root = get_tree().get_edited_scene_root()
			if edited_scene_root:
				node.set_owner(edited_scene_root)
	return node

func _draw() -> void:
	var left_handle = get_tangent_handle(false)
	var right_handle = get_tangent_handle(true)

	draw_line(rect_size * 0.5, left_handle.rect_position + left_handle.rect_size * 0.5, Color.darkgray)
	draw_line(rect_size * 0.5, right_handle.rect_position + left_handle.rect_size * 0.5, Color.darkgray)

func tangent_handle_moved(left: bool) -> void:
	var handle := get_tangent_handle(left)
	var pos = handle.rect_position
	pos +=  handle.rect_size * 0.5
	pos -= rect_size * 0.5
	pos /= get_parent().rect_size.normalized()
	var angle = atan2(pos.y, pos.x)
	if left:
		emit_signal("left_tangent_changed", tan(angle))
	else:
		emit_signal("right_tangent_changed", tan(angle))
