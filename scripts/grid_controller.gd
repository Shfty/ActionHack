class_name GridController
extends Node
tool

export(Resource) var input_map = preload("res://resources/grid_input_map/basic_input_map.tres")

onready var target_actor = get_parent() as GridActor

func buffer_motion(input_key: String) -> void:
	if not input_map:
		return

	if not input_key in input_map.map:
		return

	var motion = input_map.map[input_key] as GridMotion
	if motion:
		target_actor.buffer_motion(motion.duplicate())
