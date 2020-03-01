class_name GridActor
extends GridEntity
tool

enum MoveType {
	FORWARD,
	BACKWARD,
	LEFT,
	RIGHT,
	TURN_LEFT,
	TURN_RIGHT,
	TURN_180
}

signal rotation_changed(rotation)

var move_buffer := []
var moving = false
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
		var move = move_buffer.front()
		move_progress = min(move_progress + delta * (1.0 / move.duration), 1.0)
		position = lerp(move.from_position * GridUtil.TILE_SIZE, move.to_position * GridUtil.TILE_SIZE, move.curve.interpolate(move_progress))
		position.x = ceil(position.x)
		position.y = ceil(position.y)
		rotation_degrees = lerp(GridUtil.facing_to_angle(move.from_facing), GridUtil.facing_to_angle(move.to_facing), move.curve.interpolate(move_progress))
		emit_signal("rotation_changed", rotation_degrees)

		for event in move.events:
			if prev_move_progress <= event.time and move_progress >= event.time:
				event.run({"position": Vector2(move.from_position.x, move.from_position.y), "facing": facing, "parent": get_parent()})
		prev_move_progress = move_progress

		if move_progress >= 1.0:
			moving = false
			set_x(move.to_position.x)
			set_y(move.to_position.y)
			set_facing(move.to_facing)
			move_buffer.pop_front()
			try_move()

func buffer_move(move: GridMove) -> bool:
	var world = get_world()
	if not world:
		return false

	var source_position := Vector2.ZERO
	var source_facing: int = GridUtil.Facing.NORTH
	if move_buffer.size() > 0:
		source_position = move_buffer[-1].to_position
		source_facing = move_buffer[-1].to_facing
	else:
		source_position = Vector2(x, y)
		source_facing = facing

	var move_delta := move.delta_position as Vector2
	move_delta = GridUtil.rotate_vec2_by_facing(move_delta, source_facing)

	var target_position = source_position + move_delta
	var target_facing = source_facing + move.delta_facing

	if move_delta == Vector2.ZERO or not world.check_tile_map_collision(target_position.x, target_position.y):
		move.from_position = source_position
		move.to_position = target_position
		move.from_facing = source_facing
		move.to_facing = target_facing

		move_buffer.push_back(move)
		try_move()
		return true

	return false

func try_move():
	var world = get_world()
	if not world:
		return false

	if moving:
		return

	if move_buffer.size() == 0:
		return

	var move = move_buffer[0]
	if not move.delta_position == Vector2.ZERO and world.check_entity_collision(move.to_position.x, move.to_position.y, self):
		move_buffer.clear()
		return

	move_progress = 0.0
	prev_move_progress = 0.0
	moving = true
