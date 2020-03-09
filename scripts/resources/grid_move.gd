class_name GridMove
extends Resource
tool

export(Vector2) var delta_position := Vector2.ZERO
export(int) var delta_facing := 0

export(Curve) var curve_x := Curve.new() as Curve
export(Curve) var curve_y := Curve.new() as Curve
export(Curve) var curve_facing := Curve.new() as Curve

export(bool) var flip_curve_x := false
export(bool) var flip_curve_y := false
export(bool) var flip_curve_facing := false

export(float) var duration := 0.2
export(Array, Resource) var events := [] setget set_events

export(Dictionary) var input_press_motions := {}
export(Dictionary) var input_release_motions := {}

func _init() -> void:
	if curve_x.get_point_count() == 0:
		curve_x.add_point(Vector2.ZERO, 0, tan(deg2rad(45)))
		curve_x.add_point(Vector2.ONE, tan(deg2rad(45)), 0)

	if curve_y.get_point_count() == 0:
		curve_y.add_point(Vector2.ZERO, 0, tan(deg2rad(45)))
		curve_y.add_point(Vector2.ONE, tan(deg2rad(45)), 0)

	if curve_facing.get_point_count() == 0:
		curve_facing.add_point(Vector2.ZERO, 0, tan(deg2rad(45)))
		curve_facing.add_point(Vector2.ONE, tan(deg2rad(45)), 0)

func set_events(new_events: Array) -> void:
	if events != new_events:
		events = new_events
		for i in range(0, events.size()):
			if events[i] == null:
				events[i] = GridEvent.new()
