class_name GadgetMotionButton
extends GadgetResource
tool

func _init(in_node_path: NodePath = NodePath(), in_subnames: String = "", in_metadata: Dictionary = {}).(in_node_path, in_subnames, in_metadata):
	pass

static func supports_type(value) -> bool:
	return value is GridMotion or value == null

static func supports_resource(classname: String) -> bool:
	return classname == "GridMotion"

func has_controls() -> bool:
	return has_node("Button")

func get_controls() -> Array:
	return [$Button]

func populate_controls() -> void:
	var motion_label = GadgetStringLabel.new("../../../" + node_path, subnames + ":resource_name")
	motion_label.name = "MotionLabel"
	motion_label.size_flags_horizontal = SIZE_EXPAND_FILL
	motion_label.mouse_filter = MOUSE_FILTER_PASS

	var delete_button = ToolButton.new()
	delete_button.name = "DeleteButton"
	delete_button.text = "X"
	delete_button.mouse_filter = MOUSE_FILTER_STOP

	var hbox = HBoxContainer.new()
	hbox.name = "HBoxContainer"
	hbox.anchor_right = 1
	hbox.anchor_bottom = 1
	hbox.add_child(motion_label)
	hbox.add_child(delete_button)

	var button = Button.new()
	button.name = "Button"
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.add_child(hbox)

	add_child(button)

func set_motion_choice_value(value: int) -> void:
	if value == 0:
		set_node_value(null)
	else:
		if 'grid_motions' in metadata:
			var id = $OptionButton.get_item_id(value)
			set_node_value(metadata['grid_motions'][id])

func populate_value(value: GridMotion) -> void:
	var option_button = get_controls()[0] as Button
	option_button.disabled = !editable
	if option_button.is_connected("pressed", self, "motion_pressed"):
		option_button.disconnect("pressed", self, "motion_pressed")
	option_button.connect("pressed", self, "motion_pressed", [value])

	var delete_button = option_button.get_node("HBoxContainer/DeleteButton")
	delete_button.disabled = !editable
	if delete_button.is_connected("pressed", self, "motion_delete_pressed"):
		delete_button.disconnect("pressed", self, "motion_delete_pressed")
	delete_button.connect("pressed", self, "motion_delete_pressed", [value])

func motion_pressed(motion: GridMotion) -> void:
	gadget_event({
		"name": "grid_motion_select",
		"motion": motion
	})

func motion_delete_pressed(motion: GridMotion) -> void:
	gadget_event({
		"name": "grid_motion_delete",
		"motion": motion
	})

func depopulate_value() -> void:
	var option_button = get_controls()[0]
	option_button.disabled = true

	var delete_button = option_button.get_node("HBoxContainer/DeleteButton")
	delete_button.disabled = !editable
