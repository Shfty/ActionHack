class_name Compass
extends Control
tool

export(float) var angle = 0.0 setget set_angle

func _process(delta: float) -> void:
	update()

func _draw() -> void:
	var center = rect_size * 0.5
	draw_circle(center, rect_size.x * 0.5, Color(0.0, 0.5, 1.0))
	draw_circle(center, rect_size.x * 0.45, Color.whitesmoke)
	draw_circle_arc_poly(center, rect_size.x * 0.45, angle - 45, angle + 45, Color.crimson)

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)


func set_angle(new_angle: float) -> void:
	if angle != new_angle:
		angle = -new_angle
