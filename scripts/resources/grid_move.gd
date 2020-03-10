class_name GridMove
extends Resource
tool

export(Vector2) var delta_position := Vector2.ZERO
export(int) var delta_facing := 0

export(Curve) var curve_x = null
export(Curve) var curve_y = null
export(Curve) var curve_facing = null

export(bool) var flip_curve_x := false
export(bool) var flip_curve_y := false
export(bool) var flip_curve_facing := false

export(float) var duration := 0.2
export(Array, Resource) var events = null setget set_events

export(Dictionary) var input_press_motions = null
export(Dictionary) var input_release_motions = null

func _init() -> void:
	if resource_name == "":
		resource_name = "Move"

	if not curve_x:
		curve_x = Curve.new()
		curve_x.add_point(Vector2.ZERO)
		curve_x.add_point(Vector2.RIGHT)

	if not curve_y:
		curve_y = Curve.new()
		curve_y.add_point(Vector2.ZERO)
		curve_y.add_point(Vector2.RIGHT)

	if not curve_facing:
		curve_facing = Curve.new()
		curve_facing.add_point(Vector2.ZERO)
		curve_facing.add_point(Vector2.RIGHT)

	if not events:
		events = []

	if not input_press_motions:
		input_press_motions = {}

	if not input_release_motions:
		input_release_motions = {}

func set_events(new_events: Array) -> void:
	if events != new_events:
		events = new_events
		for i in range(0, events.size()):
			if events[i] == null:
				events[i] = GridEvent.new()
