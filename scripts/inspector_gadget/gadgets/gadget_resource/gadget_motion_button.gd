class_name GadgetMotionButton
extends GadgetResource
tool

func _init(in_node_path: NodePath = NodePath(), in_subnames: String = "").(in_node_path, in_subnames):
	pass

static func supports_type(value) -> bool:
	return value is GridMotion or value == null

func has_controls() -> bool:
	return has_node("Button")

func get_controls() -> Array:
	return [$Button]

func populate_controls() -> void:
	var motion_label = GadgetStringLabel.new("../../../" + node_path, subnames + ":resource_name")
	motion_label.name = "MotionLabel"
	motion_label.size_flags_horizontal = SIZE_EXPAND_FILL
	motion_label.mouse_filter = MOUSE_FILTER_PASS

	var hbox = HBoxContainer.new()
	hbox.name = "HBoxContainer"
	hbox.anchor_right = 1
	hbox.anchor_bottom = 1
	hbox.add_child(motion_label)

	var button = Button.new()
	button.name = "Button"
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.add_child(hbox)

	add_child(button)

func set_motion_choice_value(value: int) -> void:
	if value == 0:
		set_node_value(null)
	else:
		if 'grid_motions' in custom_gadget_metadata:
			var id = $OptionButton.get_item_id(value)
			set_node_value(custom_gadget_metadata['grid_motions'][id])

func populate_value(value: GridMotion) -> void:
	var button = get_controls()[0] as Button
	button.disabled = !editable
	if button.is_connected("pressed", self, "motion_pressed"):
		button.disconnect("pressed", self, "motion_pressed")
	button.connect("pressed", self, "motion_pressed", [value])

func motion_pressed(motion: GridMotion) -> void:
	gadget_event({
		"name": "grid_motion_select",
		"motion": motion
	})
func depopulate_value() -> void:
	var button = get_controls()[0]
	button.disabled = true
