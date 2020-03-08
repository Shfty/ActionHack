class_name CurveRect
extends Control
tool

export(Curve) var curve = null setget set_curve
export(float) var min_value := -1.0 setget set_min_value
export(float) var max_value := 1.0 setget set_max_value
export(Color) var color := Color.white setget set_color

# Setters
func set_curve(new_curve: Curve) -> void:
	if curve != new_curve:
		if curve:
			curve.disconnect("changed", self, "update")

		curve = new_curve

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
func _draw():
	if not curve:
		return

	if rect_size == Vector2.ZERO:
		return

	var points := PoolVector2Array()
	for i in range(0, rect_size.x):
		points.append(Vector2(i, get_normalized_curve_value(i / rect_size.x)))
	draw_polyline(points, color, 1, true)

# Utility
func get_normalized_curve_value(alpha: float) -> float:
	if not curve:
		return 0.0

	return range_lerp(curve.interpolate(alpha), min_value, max_value, rect_size.y, 0)
