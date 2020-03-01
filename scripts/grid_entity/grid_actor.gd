class_name GridActor
extends GridEntity
tool

signal rotation_changed(rotation)

var motion_buffer := []
var moving = false
var motion_progress := 0.0
var move_progress := 0.0
var prev_move_progress := 0.0

var wall_map_path := NodePath("../WallMap")

# Getters
func get_wall_map() -> TileMap:
	if wall_map_path.is_empty():
		return null

	return get_node(wall_map_path) as TileMap

# Overrides
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if moving:
		var motion = motion_buffer.front() as GridMotion
		var motion_duration = motion.get_duration()
		var move = motion.moves.front() as GridMove

		var delta_progress = delta * (1.0 / move.duration)
		move_progress = min(move_progress + delta_progress, 1.0)
		motion_progress = min(motion_progress + delta_progress, motion.moves.size())

		var from_position = Vector2(x, y)
		var delta_position_rotated = GridUtil.rotate_vec2_by_facing(motion.moves[0].delta_position, facing)
		var to_position = from_position + delta_position_rotated

		position = lerp(from_position * GridUtil.TILE_SIZE, to_position * GridUtil.TILE_SIZE, motion.curve.interpolate(motion_progress / motion.moves.size()) * motion.moves.size())
		position.x = ceil(position.x)
		position.y = ceil(position.y)

		rotation_degrees = lerp(GridUtil.facing_to_angle(facing), GridUtil.facing_to_angle(facing + motion.moves[0].delta_facing), motion.curve.interpolate(move_progress))
		emit_signal("rotation_changed", rotation_degrees)

		for event in motion.moves[0].events:
			if prev_move_progress <= event.time and move_progress >= event.time:
				event.run({"position": Vector2(x, y), "facing": facing, "parent": get_parent()})
		prev_move_progress = move_progress

		if move_progress >= 1.0:
			set_x(x + delta_position_rotated.x)
			set_y(y + delta_position_rotated.y)
			set_facing(facing + move.delta_facing)

			move_progress = 0.0
			prev_move_progress = 0.0

			if motion.moves.size() > 0:
				motion.moves.pop_front()

			if motion.moves.size() == 0:
				motion_progress = 0.0
				motion_buffer.pop_front()

			moving = false
			try_move()

func buffer_motion(motion: GridMotion) -> void:
	motion_buffer.push_back(motion)
	try_move()

func try_move():
	var world = get_world()
	if not world:
		return

	if moving:
		return

	if motion_buffer.size() == 0:
		return

	var motion = motion_buffer.front()

	if not motion or motion.moves.size() == 0:
		return

	var move = motion.moves.front()

	var rotated_delta_position = GridUtil.rotate_vec2_by_facing(move.delta_position, facing)
	if rotated_delta_position == Vector2.ZERO or not world.check_collision(x + rotated_delta_position.x, y + rotated_delta_position.y, self):
		moving = true
	else:
		if motion.moves.size() > 0:
			motion.moves.pop_front()

		if motion.moves.size() == 0:
			motion_buffer.pop_front()

		try_move()
