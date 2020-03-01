class_name GridMotion
extends Resource
tool

export(Array, Resource) var moves setget set_moves
export(Curve) var curve = preload("res://resources/curve/curve_linear.tres")

func set_moves(new_moves: Array) -> void:
	if moves != new_moves:
		moves = new_moves
		if moves.size() > 0:
			if not moves[-1]:
				moves[-1] = GridMove.new()

func get_duration() -> float:
	var duration = 0.0
	for move in moves:
		duration += move.duration
	return duration
