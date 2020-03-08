class_name MovesetEditorUtil

static func create_motion_menu(moveset: GridMoveset, selected_motion: GridMotion, ignore_motion: GridMotion = null) -> OptionButton:
	var motion_menu_button = OptionButton.new()
	motion_menu_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	motion_menu_button.flat = false

	motion_menu_button.get_popup().add_item("None")
	for motion in moveset.motions:
		if not motion:
			continue

		if motion == ignore_motion:
			continue

		motion_menu_button.get_popup().add_item(motion.get_name())

	motion_menu_button.selected = moveset.motions.find(selected_motion) + 1

	return motion_menu_button
