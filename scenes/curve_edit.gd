class_name CurveEdit
extends Control
tool

export(Curve) var curve: Curve setget set_curve
export(float) var min_value = -1.0 setget set_min_value
export(float) var max_value = 1.0 setget set_max_value
export(Color) var color = Color.white setget set_color

# Getters
func get_curve_rect():
	var curve_rect: CurveRect = null
	if has_node("CurveRect"):
		curve_rect = $CurveRect
	else:
		curve_rect = CurveRect.new()
		curve_rect.name = "CurveRect"
		curve_rect.anchor_right = 1
		curve_rect.anchor_bottom = 1
		curve_rect.margin_top = 20
		curve_rect.margin_bottom = -20
		curve_rect.margin_left = 20
		curve_rect.margin_right = -20
		curve_rect.mouse_filter = MOUSE_FILTER_PASS
		curve_rect.rect_clip_content = true
		add_child(curve_rect)
	return curve_rect

func get_curve_control_points():
	var curve_control_points: CurveControlPoints = null
	if has_node("CurveControlPoints"):
		curve_control_points = $CurveControlPoints
	else:
		curve_control_points = CurveControlPoints.new()
		curve_control_points.name = "CurveControlPoints"
		curve_control_points.anchor_right = 1
		curve_control_points.anchor_bottom = 1
		curve_control_points.margin_top = 20
		curve_control_points.margin_bottom = -20
		curve_control_points.margin_left = 20
		curve_control_points.margin_right = -20
		curve_control_points.mouse_filter = MOUSE_FILTER_PASS
		curve_control_points.rect_clip_content = true
		add_child(curve_control_points)
	return curve_control_points

# Setters
func set_curve(new_curve: Curve) -> void:
	if curve != new_curve:
		if curve:
			curve.disconnect("changed", self, "update")

		curve = new_curve

		if curve:
			if not curve.is_connected("changed", self, "update"):
				curve.connect("changed", self, "update")

		get_curve_rect().set_curve(curve)
		get_curve_control_points().set_curve(curve)
		update()

func set_min_value(new_min_value: float) -> void:
	if min_value != new_min_value:
		min_value = new_min_value

		get_curve_rect().set_min_value(min_value)
		get_curve_control_points().set_min_value(min_value)
		update()

func set_max_value(new_max_value: float) -> void:
	if max_value != new_max_value:
		max_value = new_max_value

		get_curve_rect().set_max_value(max_value)
		get_curve_control_points().set_max_value(max_value)
		update()

func set_color(new_color: Color) -> void:
	if not color == new_color:
		color = new_color

		get_curve_rect().set_color(color)
		get_curve_control_points().set_color(color)

# Overrides
func _ready() -> void:
	update()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, rect_size), Color.black, true)
	if not curve:
		return

	var curve_rect = get_curve_rect()
	var curve_rect_relative = curve_rect.rect_global_position - rect_global_position

	var font = get_font("font")
	draw_string(font, Vector2(5, 15), String(min_value))
	draw_string(font, Vector2(0, rect_size.y * 0.5) + Vector2(5, -5), "0")
	draw_string(font, Vector2(rect_size.x, rect_size.y * 0.5) + Vector2(-15, -5), "1")
	draw_string(font, Vector2(0, rect_size.y) + Vector2(5, -5), String(max_value))

	# Draw snap lines
	if Input.is_key_pressed(KEY_CONTROL):
		for x in range(0, 20):
			for y in range(0, 20):
				var x_pos = x * (curve_rect.rect_size.x / 20)
				var y_pos = y * (curve_rect.rect_size.y / 20)
				draw_line(Vector2(curve_rect_relative.x + x_pos, curve_rect_relative.y), Vector2(curve_rect_relative.x + x_pos, curve_rect_relative.y + curve_rect.rect_size.y), Color(0.4, 0.4, 0.4))
				draw_line(Vector2(curve_rect_relative.x, curve_rect_relative.y + y_pos), Vector2(curve_rect_relative.x + curve_rect.rect_size.x, curve_rect_relative.y + y_pos), Color(0.4, 0.4, 0.4))

	# Draw reference lines
	var curve_rect_size = curve_rect.rect_size

	draw_line(Vector2(curve_rect_relative.x, 0), Vector2(curve_rect_relative.x, rect_size.y), Color.white)
	draw_line(Vector2(curve_rect_relative.x + curve_rect_size.x, 0), Vector2(curve_rect_relative.x + curve_rect_size.x, rect_size.y), Color.white)

	draw_line(Vector2(0, curve_rect_relative.y), Vector2(rect_size.x, curve_rect_relative.y), Color.white)
	draw_line(Vector2(0, curve_rect_relative.y + curve_rect_size.y), Vector2(rect_size.x, curve_rect_relative.y + curve_rect_size.y), Color.white)

	var zero = range_lerp(0.0, min_value, max_value, 0, curve_rect_size.y)
	draw_line(Vector2(0, curve_rect_relative.y + zero), Vector2(rect_size.x, curve_rect_relative.y + zero), Color.white)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.scancode == KEY_CONTROL:
			update()
