extends VBoxContainer

signal motion_selected(motion)
signal delete_moveset_motion(motion)

var cached_moveset: GridMoveset

var button_group = ButtonGroup.new()

func populate_moveset(moveset: GridMoveset) -> void:
	cached_moveset = moveset

	clear_children()

	if not moveset:
		return

	for motion in moveset.motions:
		var motion_label = Label.new()
		motion_label.size_flags_horizontal = SIZE_EXPAND_FILL
		motion_label.text = motion.get_name()
		motion_label.clip_text = true

		var delete_button = ToolButton.new()
		delete_button.text = "X"
		delete_button.connect("pressed", self, "delete_pressed", [motion])

		var hbox = HBoxContainer.new()
		hbox.anchor_right = 1
		hbox.anchor_bottom = 1
		hbox.add_child(motion_label)
		hbox.add_child(delete_button)

		var button = Button.new()
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		button.group = button_group
		button.add_child(hbox)
		button.connect("pressed", self, "motion_selected", [motion])

		add_child(button)

func repopulate_moveset() -> void:
	populate_moveset(cached_moveset)

func clear_children() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

func motion_selected(motion: GridMotion) -> void:
	emit_signal("motion_selected", motion)

func delete_pressed(motion: GridMotion) -> void:
	emit_signal("delete_moveset_motion", motion)
