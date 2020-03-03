class_name Renderer2D
extends Control
tool

export(bool) var invalidate_cache = false setget set_invalidate_cache

export(int) var width = 24 setget set_width
export(int) var height = 24 setget set_height

export(Vector2) var offset = Vector2.ZERO setget set_offset

var wall_cache = null
var player_sprite = TextureRect.new()
var actor_sprites := {}
var tile_maps := {}

var rotation_path = "./Rotation"
var offset_path = rotation_path + "/Offset"
var canvas_path = offset_path + "/Canvas"
var walls_path = canvas_path + "/Walls"

# Setters
func set_invalidate_cache(new_invalidate_cache: bool) -> void:
	if invalidate_cache != new_invalidate_cache:
		invalidate_wall_cache()

func set_width(new_width: int) -> void:
	if width != new_width:
		width = new_width
		update_canvas_node_position()
		update_canvas_node_size()
		update_rotation_node_position()
		invalidate_wall_cache()

func set_height(new_height: int) -> void:
	if height != new_height:
		height = new_height
		update_canvas_node_position()
		update_rotation_node_position()
		update_canvas_node_size()
		invalidate_wall_cache()

func set_offset(new_offset: Vector2) -> void:
	if offset != new_offset:
		offset = new_offset
		update_offset_node_position()

# Utility
func update_offset_node_position() -> void:
	var offset_node = get_offset_node()
	if offset_node:
		offset_node.rect_position = Vector2(-fmod(offset.x, 1.0) * GridUtil.TILE_SIZE, -fmod(offset.y, 1.0) * GridUtil.TILE_SIZE)

func update_rotation_node_position() -> void:
	var rotation_node = get_rotation_node()
	if rotation_node:
		rotation_node.rect_position = rect_size * 0.5

func update_canvas_node_position() -> void:
	var canvas_node = get_canvas_node()
	if canvas_node:
		canvas_node.rect_position = Vector2(-width * 0.5 * GridUtil.TILE_SIZE, -height * 0.5 * GridUtil.TILE_SIZE)

func update_canvas_node_size():
	var canvas_node = get_canvas_node()
	if canvas_node:
		canvas_node.rect_size = Vector2(width * GridUtil.TILE_SIZE, height * GridUtil.TILE_SIZE)

func get_node_checked(node_path: NodePath):
	if node_path.is_empty():
		return null

	return get_node(node_path) as Node2D

func get_offset_node() -> Control:
	return get_node(offset_path) as Control

func get_rotation_node() -> Control:
	return get_node(rotation_path) as Control

func get_canvas_node() -> Control:
	return get_node(canvas_path) as Control

func get_walls_node() -> Control:
	return get_node(walls_path) as Control

func invalidate_wall_cache() -> void:
	var canvas_node := get_canvas_node()
	if canvas_node:
		for child in canvas_node.get_children():
			if child != get_walls_node():
				canvas_node.remove_child(child)
				child.queue_free()

	wall_cache = null
	player_sprite = null
	actor_sprites.clear()

func _process(delta: float) -> void:
	var world = get_node("../World")
	if not world:
		return

	for node in world.get_children():
		if node is TileMap:
			draw_walls_new(node)
		elif node is GridEntity:
			draw_entity(node)
		elif node is GridCamera:
			var canvas_node = get_canvas_node()
			if canvas_node:
				set_offset(-Vector2(5, 5) + Vector2(-12, -12) + Vector2(0.5, 0.5) + node.position / GridUtil.TILE_SIZE)

			var rotation_node = get_rotation_node()
			if rotation_node:
				rotation_node.rect_rotation = -node.rotation_degrees

func draw_walls_new(tile_map: TileMap) -> void:
	var walls_node = get_walls_node()
	if not walls_node:
		return

	var map: TileMap = null

	if tile_map in tile_maps:
		map = tile_maps[tile_map]
	else:
		map = tile_map.duplicate()
		tile_maps[tile_map] = map
		walls_node.add_child(map)
		if not map.is_connected("tree_exiting", self, "handle_tile_map_tree_exiting"):
			map.connect("tree_exiting", self, "handle_tile_map_tree_exiting", [map])

	map.position = -offset * GridUtil.TILE_SIZE
	map.position += Vector2(fmod(offset.x, 1.0), fmod(offset.y, 1.0)) * GridUtil.TILE_SIZE

func draw_walls(wall_map: TileMap) -> void:
	if not wall_cache:
		create_wall_cache()

	if not wall_map:
		return

	var walls_node = get_walls_node()
	if not walls_node:
		return

	var tileset = wall_map.get_tileset()
	var tiles_ids = tileset.get_tiles_ids()

	for x in range(0, width):
		for y in range(0, height):
			var cell_coord = Vector2(x + int(offset.x), y + int(offset.y))
			var map_cell = wall_map.get_cell(cell_coord.x, cell_coord.y)

			var idx = y + (x * height)
			var wall = wall_cache[idx]
			var node := wall[0] as TextureSubregionRect
			var in_tree = wall[1] as bool

			if tileset:
				if map_cell != TileMap.INVALID_CELL:
					if map_cell in tileset.get_tiles_ids():
						node.texture = tileset.tile_get_texture(map_cell)

			node.offset = wall_map.get_cell_autotile_coord(cell_coord.x, cell_coord.y) * GridUtil.TILE_SIZE

			if map_cell != TileMap.INVALID_CELL and not in_tree:
				walls_node.add_child(node)
				wall_cache[idx][1] = true
			elif map_cell == TileMap.INVALID_CELL and in_tree:
				walls_node.remove_child(node)
				wall_cache[idx][1] = false

func draw_entity(entity: GridEntity):
	if not entity:
		return

	var canvas_node = get_canvas_node()
	if not canvas_node:
		return

	var top_left = offset * GridUtil.TILE_SIZE
	var bottom_right = offset + (Vector2(width, height) * GridUtil.TILE_SIZE)

	var sprite: TextureRect = null

	if entity in actor_sprites:
		sprite = actor_sprites[entity]
	else:
		sprite = TextureRect.new()
		sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
		actor_sprites[entity] = sprite
		entity.connect("tree_exiting", self, "handle_entity_tree_exiting", [entity])

	sprite.texture = entity.sprite_texture
	if sprite.texture:
		sprite.rect_pivot_offset = sprite.texture.get_size() * 0.5

	if entity.has_method("get_sprite"):
		var entity_sprite = entity.get_sprite()

		sprite.rect_position = entity.position + entity_sprite.position
		sprite.rect_position -= offset * GridUtil.TILE_SIZE
		sprite.rect_position += Vector2(fmod(offset.x, 1.0), fmod(offset.y, 1.0)) * GridUtil.TILE_SIZE

		sprite.rect_rotation = entity.rotation_degrees
		sprite.rect_rotation += entity_sprite.rotation_degrees

		sprite.modulate[3] = entity.opacity

	var entity_visible = true
	entity_visible = entity_visible and sprite.rect_position.x >= -30
	entity_visible = entity_visible and sprite.rect_position.y >= -30
	entity_visible = entity_visible and sprite.rect_position.x <= canvas_node.rect_size.x - 30
	entity_visible = entity_visible and sprite.rect_position.y <= canvas_node.rect_size.y - 30

	if not entity_visible and sprite in canvas_node.get_children():
		canvas_node.remove_child(sprite)
	elif entity_visible and not sprite in canvas_node.get_children():
		canvas_node.add_child(sprite)

func create_wall_cache() -> void:
	wall_cache = []
	for x in range(0, width):
		for y in range(0, height):
			var color_rect = TextureSubregionRect.new()
			color_rect.rect_position = Vector2(x, y) * GridUtil.TILE_SIZE
			color_rect.rect_size = Vector2(GridUtil.TILE_SIZE, GridUtil.TILE_SIZE)
			color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			wall_cache.append([color_rect, false])

func handle_entity_tree_exiting(entity: GridEntity):
	if entity in actor_sprites:
		var sprite = actor_sprites[entity]
		var parent = sprite.get_parent()

		if parent:
			sprite.get_parent().remove_child(sprite)

		sprite.queue_free()
		actor_sprites.erase(entity)

func handle_tile_map_tree_exiting(tile_map: TileMap):
	if tile_map in tile_maps:
		var map = tile_maps[tile_map]
		var parent = map.get_parent()

		if parent:
			map.get_parent().remove_child(map)

		map.queue_free()
		tile_maps.erase(map)
