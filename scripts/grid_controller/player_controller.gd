class_name PlayerController
extends GridController

func _unhandled_input(event: InputEvent) -> void:
	if not target_actor:
		return

	if not event is InputEventKey and not event is InputEventMouseButton:
		return

	if not event.pressed:
		return

	if event is InputEventKey and event.echo:
		return

	for action in input_map.map:
		if not InputMap.has_action(action):
			continue

		if event.is_action(action):
			var action_name = ""
			if Input.is_action_pressed("special"):
				action_name = "special_"
			action_name += action

			buffer_move(action_name)
