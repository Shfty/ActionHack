class_name GridMove
extends Resource
tool

export(Vector2) var delta_position
var from_position: Vector2
var to_position: Vector2

export(int) var delta_facing
var from_facing: int
var to_facing: int

export(float) var duration = 0.2
export(Curve) var curve = preload("res://resources/curve/curve_linear.tres")
export(Array, Resource) var events setget set_events

func set_events(new_events: Array) -> void:
	if events != new_events:
		events = new_events
		if events.size() > 0:
			if not events[-1]:
				events[-1] = GridEvent.new()
