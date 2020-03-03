class_name GridMove
extends Resource
tool

export(Vector2) var delta_position
export(int) var delta_facing

export(Curve) var curve_x
export(Curve) var curve_y
export(Curve) var curve_facing

export(bool) var flip_curve_x = false
export(bool) var flip_curve_y = false
export(bool) var flip_curve_facing = false

export(float) var duration = 0.2
export(Array, Resource) var events setget set_events

export(Dictionary) var input_press_motions := {}
export(Dictionary) var input_release_motions := {}

func set_events(new_events: Array) -> void:
	if events != new_events:
		events = new_events
		if events.size() > 0:
			if not events[-1]:
				events[-1] = GridEvent.new()
