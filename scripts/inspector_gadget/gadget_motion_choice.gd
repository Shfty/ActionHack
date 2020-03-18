class_name GadgetMotionChoice
extends GadgetResource
tool

func _init(in_node_path: NodePath = NodePath(), in_subnames: String = "").(in_node_path, in_subnames):
	pass

static func supports_type(value) -> bool:
	return value is int

func has_controls() -> bool:
	return has_node("OptionButton")

func get_controls() -> Array:
	return [$OptionButton]

func populate_controls() -> void:
	var option_button = OptionButton.new()
	option_button.name = "OptionButton"
	option_button.text = "None"
	option_button.set_anchors_and_margins_preset(PRESET_WIDE)
	option_button.connect("item_selected", self, "set_motion_choice_value")
	add_child(option_button)

func set_motion_choice_value(value: int) -> void:
	set_node_value(value - 1)

func populate_value(value) -> void:
	var option_button = get_controls()[0] as OptionButton
	option_button.set_block_signals(true)
	option_button.add_item("None")

	if 'grid_motion_names' in custom_gadget_metadata:
		for i in range(0, custom_gadget_metadata['grid_motion_names'].size()):
			var motion_name = custom_gadget_metadata['grid_motion_names'][i]
			option_button.add_item(motion_name)

		option_button.selected = value + 1

	option_button.set_block_signals(false)
	option_button.disabled = !editable

func depopulate_value() -> void:
	var option_button = get_controls()[0]
	option_button.set_block_signals(true)
	option_button.clear()
	option_button.set_block_signals(false)
	option_button.disabled = true
