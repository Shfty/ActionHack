class_name PlayerController
extends GridController

func _unhandled_input(event: InputEvent) -> void:
	if not target_actor:
		return

	if not event is InputEventKey and not event is InputEventMouseButton:
		return

	if event is InputEventKey and event.echo:
		return

	if event.is_action("special"):
		return

	for action in InputMap.get_actions():
		if event.is_action(action):
			var action_name = ""
			if Input.is_action_pressed("special"):
				action_name = "special_"
			action_name += action

			buffer_input(action_name, event.pressed)

			# Prevent special releases from masking their normal counterparts
			if not event.pressed:
				buffer_input(action, false)
