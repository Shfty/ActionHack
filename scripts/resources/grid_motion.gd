class_name GridMotion
extends Resource
tool

export(Array, Resource) var motion_moves setget set_moves
export(Curve) var motion_curve = preload("res://resources/curve/curve_linear.tres")
export(Resource) var hit_wall_motion
export(Resource) var hit_entity_motion
export(Resource) var next_motion
export(bool) var looping = false
export(bool) var lock_input_buffer = false
export(bool) var cancelable = false

func set_moves(new_motion_moves: Array) -> void:
	if motion_moves != new_motion_moves:
		motion_moves = new_motion_moves
		if motion_moves.size() > 0:
			if not motion_moves[-1]:
				motion_moves[-1] = GridMove.new()

func get_duration() -> float:
	var duration = 0.0
	for move in motion_moves:
		duration += move.duration
	return duration
