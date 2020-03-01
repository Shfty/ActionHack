class_name GridController
extends Node
tool

export(Resource) var input_map = preload("res://resources/grid_input_map/basic_input_map.tres")

onready var target_actor = get_parent() as GridActor

func buffer_move(input_key: String) -> bool:
	if not input_map:
		return false

	if not input_key in input_map.map:
		return false

	var move = input_map.map[input_key]
	return target_actor.buffer_move(move.duplicate())
