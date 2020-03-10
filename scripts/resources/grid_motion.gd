class_name GridMotion
extends Resource
tool

export(Array, Resource) var motion_moves := [
	GridMove.new()
] setget set_moves
export(Curve) var motion_curve: Curve = null

export(bool) var looping := false
export(bool) var cancelable := false
export(bool) var lock_input_buffer := false
export(Array, String) var lock_inputs = null setget set_lock_inputs

export(int) var hit_wall_motion_idx = -1
export(int) var hit_entity_motion_idx = -1
export(int) var next_motion_idx = -1

func _init() -> void:
	if resource_name == "":
		resource_name = "New Motion"

	if not motion_curve:
		motion_curve = Curve.new()
		motion_curve.add_point(Vector2.ZERO, 0, tan(deg2rad(45)))
		motion_curve.add_point(Vector2.ONE, tan(deg2rad(45)), 0)

	if not lock_inputs:
		lock_inputs = []

func set_moves(new_motion_moves: Array) -> void:
	if motion_moves != new_motion_moves:
		motion_moves = new_motion_moves
		if motion_moves.size() > 0:
			if not motion_moves[-1]:
				motion_moves[-1] = Object()

func set_lock_inputs(new_lock_inputs: Array) -> void:
	if lock_inputs != new_lock_inputs:
		lock_inputs = new_lock_inputs

func get_duration() -> float:
	var duration = 0.0
	for move in motion_moves:
		duration += move.duration
	return duration

func add_move() -> void:
	motion_moves.append(GridMove.new())

func delete_move(move: GridMove) -> void:
	if move in motion_moves:
		motion_moves.erase(move)
