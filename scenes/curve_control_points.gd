class_name CurveControlPoints
extends Control
tool

export(Curve) var curve: Curve setget set_curve
export(float) var min_value = -1.0 setget set_min_value
export(float) var max_value = 1.0 setget set_max_value
export(Color) var color = Color.white setget set_color
export(int) var position_snap = 20
export(float) var angle_snap = 1.0 / (PI / 8)

var hovered_point := -1
var hovered_tangent_sign := 0

var drag_start = Vector2.ZERO
var selected_point := -1
var selected_tangent_sign := 0

# Setters
func set_curve(new_curve: Curve) -> void:
	if curve != new_curve:
		if curve:
			curve.disconnect("changed", self, "update")

		curve = new_curve

		if has_node("CurveRect"):
			$CurveRect.set_curve(curve)

		if has_node("ControlPoints"):
			$ControlPoints.set_curve(curve)

		if curve:
			if not curve.is_connected("changed", self, "update"):
				curve.connect("changed", self, "update")

		update()

func set_min_value(new_min_value: float) -> void:
	if min_value != new_min_value:
		min_value = new_min_value
		update()

func set_max_value(new_max_value: float) -> void:
	if max_value != new_max_value:
		max_value = new_max_value
		update()

func set_color(new_color: Color) -> void:
	if color != new_color:
		color = new_color
		update()

# Overrides
func _draw() -> void:
	if not curve:
		return

	# Draw control points
	for i in range(0, curve.get_point_count()):
		var curve_position = curve.get_point_position(i)
		curve_position.y = range_lerp(curve_position.y, min_value, max_value, 1, 0)
		var local_position = curve_position * rect_size
		local_position = local_position.floor()

		var left_tangent = get_tangent_position(i, false)
		var right_tangent = get_tangent_position(i, true)

		draw_line(local_position, left_tangent, Color.white, 1.0, true)
		draw_line(local_position, right_tangent, Color.white, 1.0, true)

		if i == hovered_point and hovered_tangent_sign == 0:
			draw_circle(local_position, 7.0, Color.white)
		else:
			draw_circle(local_position, 5.0, Color.white)

		if i == hovered_point and hovered_tangent_sign == -1:
			draw_circle(left_tangent, 5.0, Color.white)
		else:
			draw_circle(left_tangent, 3.0, Color.white)

		if i == hovered_point and hovered_tangent_sign == 1:
			draw_circle(right_tangent, 5.0, Color.white)
		else:
			draw_circle(right_tangent, 3.0, Color.white)

func get_tangent_position(index: int, left: bool) -> Vector2:
	if not curve:
		return Vector2.ZERO

	var curve_position = curve.get_point_position(index)
	curve_position.y = range_lerp(curve_position.y, min_value, max_value, 1, 0)
	var local_position = Vector2(curve_position.x, curve_position.y) * rect_size

	var tangent = curve.get_point_left_tangent(index) if left else curve.get_point_right_tangent(index)
	var rad = atan(-tangent)
	var tangent_position = local_position + (Vector2(cos(rad), sin(rad)) * rect_size).normalized() * (-20 if left else 20)
	tangent_position = tangent_position.floor()

	return tangent_position

func _gui_input(event: InputEvent) -> void:
	if not curve:
		return

	if not event is InputEventMouse:
		return

	var mouse_position = get_viewport().get_mouse_position()
	var local_position = mouse_position - rect_global_position

	if event is InputEventMouseMotion:
		if selected_point == -1:
			var closest_idx := 0
			var closest_point := Vector2.ZERO
			var closest_dist := 0.0
			var tangent_sign := 0
			for i in range(curve.get_point_count()):
				var point = curve.get_point_position(i)
				point.x *= rect_size.x
				point.y = range_lerp(point.y, min_value, max_value, rect_size.y, 0)

				var left_tangent = get_tangent_position(i, false)
				var right_tangent = get_tangent_position(i, true)

				var dist_point = (point - local_position).length()
				var dist_left_tangent = (left_tangent - local_position).length()
				var dist_right_tangent = (right_tangent - local_position).length()

				if i == 0 or dist_point < closest_dist:
					closest_idx = i
					closest_point = point
					closest_dist = dist_point
					tangent_sign = 0.0

				if dist_left_tangent < closest_dist:
					closest_idx = i
					closest_point = left_tangent
					closest_dist = dist_left_tangent
					tangent_sign = -1.0

				if dist_right_tangent < closest_dist:
					closest_idx = i
					closest_point = right_tangent
					closest_dist = dist_right_tangent
					tangent_sign = 1.0

			if closest_dist < 5.0:
				hovered_point = closest_idx
				hovered_tangent_sign = tangent_sign
			else:
				hovered_point = -1
				hovered_tangent_sign = 0

			update()
		else:
			var point = curve.get_point_position(selected_point)
			point.x *= rect_size.x - 1.5
			point.y = range_lerp(point.y, min_value, max_value, rect_size.y, 0) + 1.5

			var start = drag_start
			if Input.is_key_pressed(KEY_CONTROL):
				var snap_vec = Vector2(1.0 / (rect_size.x / position_snap), 1.0 / (rect_size.y / position_snap))
				start *= snap_vec
				start = start.round()
				start /= snap_vec

			var delta = local_position - start

			var point_to_mouse = local_position - point
			point_to_mouse /= rect_size
			var angle = atan2(point_to_mouse.y, point_to_mouse.x)

			if Input.is_key_pressed(KEY_CONTROL):
				var snap_vec = Vector2(1.0 / (rect_size.x / position_snap), 1.0 / (rect_size.y / position_snap))
				delta *= snap_vec
				delta = delta.round()
				delta /= snap_vec

				angle *= angle_snap
				angle = round(angle)
				angle /= angle_snap

			var tangent = tan(-angle)

			match hovered_tangent_sign:
				0:
					var dest_offset = (start.x + delta.x) / rect_size.x
					var dest_value = range_lerp(start.y + delta.y, rect_size.y, 0, min_value, max_value)

					if selected_point > 0 and dest_offset < curve.get_point_position(selected_point - 1).x:
						selected_point -= 1
					elif selected_point < curve.get_point_count() - 1 and dest_offset > curve.get_point_position(selected_point + 1).x:
						selected_point += 1

					curve.set_point_offset(selected_point, dest_offset)
					curve.set_point_value(selected_point, dest_value)
				-1:
					curve.set_point_right_tangent(selected_point, tangent)
					if not Input.is_key_pressed(KEY_SHIFT):
						curve.set_point_left_tangent(selected_point, tangent)
				1:
					curve.set_point_left_tangent(selected_point, tangent)
					if not Input.is_key_pressed(KEY_SHIFT):
						curve.set_point_right_tangent(selected_point, tangent)

	elif event is InputEventMouseButton:
		if BUTTON_LEFT & event.button_mask == BUTTON_LEFT and event.pressed:
			if hovered_point != -1:
				selected_point = hovered_point
				drag_start = local_position
		else:
			selected_point = -1

		if BUTTON_RIGHT & event.button_mask == BUTTON_RIGHT:
			if selected_point != -1:
				return

			if hovered_point != -1:
				curve.remove_point(hovered_point)
				hovered_point = -1
			else:
				var norm_position = local_position / rect_size
				var curve_position = Vector2(norm_position.x, range_lerp(norm_position.y, 1.0, 0.0, -1, 1))
				var target_position = curve_position

				if Input.is_key_pressed(KEY_CONTROL):
					target_position *= position_snap
					target_position = target_position.round()
					target_position /= position_snap

				curve.add_point(target_position)
