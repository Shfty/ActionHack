extends VBoxContainer

var cached_moveset: GridMoveset

func populate_moveset(moveset: GridMoveset) -> void:
	cached_moveset = moveset

	clear_children()

	if not moveset:
		return

	var action_label = Label.new()
	action_label.text = "Action"
	action_label.size_flags_horizontal = SIZE_EXPAND_FILL

	var motion_label = Label.new()
	motion_label.text = "Motion"
	motion_label.size_flags_horizontal = SIZE_EXPAND_FILL

	var header_hbox = HBoxContainer.new()
	header_hbox.add_child(action_label)
	header_hbox.add_child(motion_label)
	add_child(header_hbox)

	var separator = HSeparator.new()
	separator.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(separator)

	for action in moveset.input_map:
		var label = Label.new()
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		label.text = action.capitalize()
		label.clip_text = true

		var motion_menu_button = MovesetEditorUtil.create_motion_menu(moveset, action)
		motion_menu_button.connect("item_selected", self, "motion_selected", [motion_menu_button, action])

		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = SIZE_EXPAND_FILL
		hbox.add_child(label)
		hbox.add_child(motion_menu_button)

		add_child(hbox)

func repopulate_moveset() -> void:
	populate_moveset(cached_moveset)

func motion_selected(index: int, menu: PopupMenu, action: String) -> void:
	if index == 0:
		cached_moveset.input_map[action] = null
	else:
		cached_moveset.input_map[action] = cached_moveset.motions[index - 1]

func clear_children() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
