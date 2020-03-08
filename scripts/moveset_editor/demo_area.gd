extends ViewportContainer
tool

onready var grid_actor = $Viewport/GridWorld/GridActor

onready var cached_x = grid_actor.x
onready var cached_y = grid_actor.y
onready var cached_facing = grid_actor.facing

var cached_motion: GridMotion = null

func _ready() -> void:
	handle_resized()
	connect("resized", self, "handle_resized")

func handle_resized() -> void:
	var grid_size = get_parent().rect_size / GridUtil.TILE_SIZE * 0.5

	rect_position = grid_size.posmod(1.0) * GridUtil.TILE_SIZE

	grid_size = grid_size.floor()
	$Viewport.size = grid_size * GridUtil.TILE_SIZE
	rect_size = grid_size * GridUtil.TILE_SIZE * 2.0

	var tile_map = $Viewport/GridWorld/TileMap
	tile_map.clear()
	for x in range(0, grid_size.x):
		for y in range(0, grid_size.y):
			if x == 0 or x == grid_size.x - 1 or y == 0 or y == grid_size.y - 1:
				tile_map.set_cell(x, y, 2)
			else:
				tile_map.set_cell(x, y, 1)

func set_motion(motion: GridMotion):
	cached_motion = motion

	grid_actor.set_y(cached_y, true)
	grid_actor.set_facing(cached_facing, true)
	grid_actor.set_motion(motion)

func replay():
	set_motion(cached_motion)
