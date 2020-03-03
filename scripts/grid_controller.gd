class_name GridController
extends Node
tool

onready var target_actor = get_parent() as GridActor

func buffer_input(input_key: String, pressed: bool) -> void:
	target_actor.buffer_input(input_key, pressed)

func buffer_press(input_key: String) -> void:
	buffer_input(input_key, true)

func buffer_release(input_key: String) -> void:
	buffer_input(input_key, false)

func buffer_tap(input_key: String) -> void:
	buffer_press(input_key)
	buffer_release(input_key)
