class_name GadgetCurve
extends GadgetResource
tool

func _init(in_node_path: NodePath = NodePath(), in_subnames: String = "", in_metadata: Dictionary = {}).(in_node_path, in_subnames, in_metadata):
	pass

static func supports_type(value) -> bool:
	return value is Curve

func has_controls() -> bool:
	return has_node("LineEdit")

func get_controls() -> Array:
	return [$LineEdit]

func populate_controls() -> void:
	var line_edit = LineEdit.new()
	line_edit.name = "LineEdit"
	line_edit.set_anchors_and_margins_preset(PRESET_WIDE)
	line_edit.connect("text_entered", self, "_set_value")
	add_child(line_edit)

func populate_value(value) -> void:
	var line_edit = get_controls()[0]
	line_edit.set_block_signals(true)
	line_edit.text = value.get_path()
	line_edit.set_block_signals(false)
	line_edit.editable = editable

func depopulate_value() -> void:
	var line_edit = get_controls()[0]
	line_edit.set_block_signals(true)
	line_edit.text = ""
	line_edit.set_block_signals(false)
	line_edit.editable = false
