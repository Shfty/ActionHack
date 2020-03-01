class_name GridUtil

enum Facing {
	NORTH = 0,
	EAST,
	SOUTH,
	WEST
}

const TILE_SIZE = 20.0

static func facing_to_angle(facing: int) -> float:
	return facing * 90.0

static func rotate_vec2_by_facing(vec: Vector2, facing: int) -> Vector2:
	match facing % 4 if facing > 0 else 4 + (facing % 4):
		Facing.EAST:
			return Vector2(-vec.y, vec.x)
		Facing.WEST:
			return Vector2(vec.y, -vec.x)
		Facing.SOUTH:
			return Vector2(-vec.x, -vec.y)

	return vec
