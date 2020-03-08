class_name GridMove
extends Resource
tool

export(Vector2) var delta_position := Vector2.ZERO
export(int) var delta_facing := 0

export(Curve) var curve_x: Curve = null
export(Curve) var curve_y: Curve = null
export(Curve) var curve_facing: Curve = null

export(bool) var flip_curve_x := false
export(bool) var flip_curve_y := false
export(bool) var flip_curve_facing := false

export(float) var duration := 0.2
export(Array, Resource) var events := [] setget set_events

export(Dictionary) var input_press_motions := {}
export(Dictionary) var input_release_motions := {}

func _init() -> void:
	if not curve_x:
		curve_x = Curve.new()
		curve_x.add_point(Vector2.ZERO, 0, tan(deg2rad(45)))
		curve_x.add_point(Vector2.ONE, tan(deg2rad(45)), 0)

	if not curve_y:
		curve_y = Curve.new()
		curve_y.add_point(Vector2.ZERO, 0, tan(deg2rad(45)))
		curve_y.add_point(Vector2.ONE, tan(deg2rad(45)), 0)

	if not curve_facing:
		curve_facing = Curve.new()
		curve_facing.add_point(Vector2.ZERO, 0, tan(deg2rad(45)))
		curve_facing.add_point(Vector2.ONE, tan(deg2rad(45)), 0)

func set_events(new_events: Array) -> void:
	if events != new_events:
		events = new_events
		if events.size() > 0:
			if not events[-1]:
				events[-1] = GridEvent.new()
