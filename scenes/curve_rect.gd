class_name CurveRect
extends Control
tool

export(Curve) var curve setget set_curve

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

# Overrides
func _draw():
	if not curve:
		return

	if rect_size == Vector2.ZERO:
		return

	var points := PoolVector2Array()
	for i in range(0, rect_size.x):
		points.append(Vector2(i, get_normalized_curve_value(i / rect_size.x)))
	draw_polyline(points, Color.darkgray, 1, true)

# Utility
func get_normalized_curve_value(alpha: float) -> float:
	if not curve:
		return 0.0

	return range_lerp(curve.interpolate(alpha), curve.min_value, curve.max_value, rect_size.y, 0)
