class_name GadgetMotionChoice
extends GadgetResource
tool

func _init(in_node_path: NodePath = NodePath(), in_subnames: String = "", in_metadata: Dictionary = {}).(in_node_path, in_subnames, in_metadata):
	pass

static func supports_type(value) -> bool:
	return value is GridMotion

static func supports_resource(classname: String) -> bool:
	return classname == "GridMotion"

func has_controls() -> bool:
	return has_node("OptionButton")

func get_controls() -> Array:
	return [$OptionButton]

func populate_controls() -> void:
	var option_button = OptionButton.new()
	option_button.name = "OptionButton"
	option_button.set_anchors_and_margins_preset(PRESET_WIDE)
	option_button.connect("item_selected", self, "set_motion_choice_value")
	add_child(option_button)

func set_motion_choice_value(value: int) -> void:
	if value == -1:
		_set_value(null)
	else:
		if 'grid_motions' in metadata:
			_set_value(metadata['grid_motions'][value - 1])

func populate_value(value) -> void:
	var option_button = get_controls()[0]
	option_button.set_block_signals(true)

	option_button.add_item("None")
	if 'grid_motions' in metadata:
		for motion in metadata['grid_motions']:
			if 'grid_motions_ignore' in metadata:
				if motion in metadata['grid_motions_ignore']:
					continue
			option_button.add_item(motion.get_name())

		option_button._select_int(metadata['grid_motions'].find(value) + 1)

	option_button.set_block_signals(false)
	option_button.disabled = !editable

func depopulate_value() -> void:
	var option_button = get_controls()[0]
	option_button.set_block_signals(true)
	option_button.clear()
	option_button.set_block_signals(false)
	option_button.disabled = true
