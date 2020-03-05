class_name CurveEdit
extends Control
tool

export(Curve) var curve: Curve setget set_curve

func _ready() -> void:
	if Engine.is_editor_hint():
		update()

func set_curve(new_curve: Curve) -> void:
	if curve != new_curve:
		if curve:
			curve.disconnect("changed", self, "update")

		curve = new_curve

		if curve:
			curve.connect("changed", self, "update")

		for child in get_children():
			remove_child(child)
			child.queue_free()

		update()

func get_control_point(index: int) -> CurveControlPoint:
	var control_point: CurveControlPoint = null
	var node_name = "ControlPoint" + String(index)
	if has_node(node_name):
		control_point = get_node(node_name)
	else:
		control_point = CurveControlPoint.new()
		control_point.name = node_name
		control_point.rect_size = Vector2(8, 8)
		control_point.connect("item_rect_changed", self, "control_point_moved", [index], CONNECT_PERSIST)
		control_point.connect("left_tangent_changed", self, "control_point_left_tangent_changed", [index], CONNECT_PERSIST)
		control_point.connect("right_tangent_changed", self, "control_point_right_tangent_changed", [index], CONNECT_PERSIST)
		add_child(control_point)
		if is_inside_tree():
			var edited_scene_root = get_tree().get_edited_scene_root()
			if edited_scene_root:
				control_point.set_owner(edited_scene_root)

	return control_point

func control_point_moved(index: int):
	var control_point = get_child(index)
	var position = control_point.rect_position + control_point.rect_size * 0.5
	curve.set_point_offset(index, range_lerp(position.x, 0, rect_size.x, 0, 1))
	curve.set_point_value(index, range_lerp(position.y, 0, rect_size.y, curve.min_value, curve.max_value))
	update()

func _draw() -> void:
	if not curve:
		return

	if rect_size == Vector2.ZERO:
		return

	# Update control points
	for i in range(0, curve.get_point_count()):
		var control_point = get_control_point(i)
		var curve_position = curve.get_point_position(i)
		curve_position.y = range_lerp(curve_position.y, curve.min_value, curve.max_value, 0, 1)
		control_point.rect_position = (curve_position * rect_size) - control_point.rect_size * 0.5
		control_point.set_left_tangent(curve.get_point_left_tangent(i))
		control_point.set_right_tangent(curve.get_point_right_tangent(i))

	# Draw reference lines
	draw_line(Vector2(0, 0), Vector2(rect_size.x, 0), Color.white)
	draw_line(Vector2(0, rect_size.y), Vector2(rect_size.x, rect_size.y), Color.white)

	var zero = range_lerp(0.0, curve.min_value, curve.max_value, 0, rect_size.y)
	draw_line(Vector2(0, zero), Vector2(rect_size.x, zero), Color.white)

	# Draw curve
	var points := PoolVector2Array()
	for i in range(0, rect_size.x + 20):
		points.append(Vector2(i, get_normalized_curve_value(i / rect_size.x) * rect_size.y))
	draw_polyline(points, Color.darkgray, 1, true)

func get_normalized_curve_value(alpha: float) -> float:
	return range_lerp(curve.interpolate(alpha), curve.min_value, curve.max_value, 0, 1)

func control_point_left_tangent_changed(tangent: float, index: int) -> void:
	curve.set_point_left_tangent(index, tangent)
	curve.set_point_right_tangent(index, tangent)

func control_point_right_tangent_changed(tangent: float, index: int) -> void:
	curve.set_point_left_tangent(index, tangent)
	curve.set_point_right_tangent(index, tangent)
