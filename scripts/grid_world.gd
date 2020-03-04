class_name GridWorld
extends Node2D

var tile_maps := []
var entities := []

func _ready() -> void:
	for child in get_children():
		if child is TileMap:
			child.connect("tree_exiting", self, "handle_tile_map_tree_exit", [child])
			tile_maps.append(child)
		elif child is GridEntity:
			child.connect("tree_exiting", self, "handle_entity_tree_exit", [child])
			entities.append(child)

func check_collision(x: int, y: int, ignore: GridEntity = null) -> bool:
	if check_tile_map_collision(x, y):
		return true

	if check_entity_collision(x, y, ignore):
		return true

	return false

func check_tile_map_collision(x: int, y: int) -> bool:
	for tile_map in tile_maps:
		if check_tile_map_collision_internal(tile_map, x, y):
			return true

	return false

func check_entity_collision(x: int, y: int, ignore: GridEntity = null) -> GridEntity:
	for entity in entities:
		if entity == ignore:
			continue

		if check_entity_collision_internal(entity, x, y):
			return entity

	return null

func check_tile_map_collision_internal(tile_map: TileMap, x: int, y: int) -> bool:
	var cell = tile_map.get_cell(x, y)

	if cell == TileMap.INVALID_CELL:
		return false
	else:
		var tileset = tile_map.get_tileset()
		if tileset:
			var shape = tileset.tile_get_shape(cell, 0)
			if not shape:
				return false
		else:
			return false

	return true

func check_entity_collision_internal(entity: GridEntity, x: int, y: int) -> bool:
	return entity.solid and entity.x == x and entity.y == y

func handle_tile_map_tree_exit(tile_map: TileMap) -> void:
	var tile_map_idx = tile_maps.find(tile_map)
	if tile_map_idx >= 0:
		tile_maps.remove(tile_map_idx)

func handle_entity_tree_exit(entity: GridEntity) -> void:
	var entity_idx = entities.find(entity)
	if entity_idx >= 0:
		entities.remove(entity_idx)
