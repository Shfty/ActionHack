class_name GadgetArray
extends InspectorGadgetBase
tool

func _init(in_node_path: NodePath = NodePath(), in_subnames: String = "").(in_node_path, in_subnames):
	pass

func set_node_path(new_node_path: NodePath):
	.set_node_path(new_node_path)

	if not has_controls():
		return

	var vbox = get_controls()[0]

	for child in vbox.get_children():
		child.node_path = node_path

func set_subnames(new_subnames: String):
	.set_subnames(new_subnames)

	if not has_controls():
		return

	var vbox = get_controls()[0]

	for child in vbox.get_children():
		child.node_path = node_path

static func supports_type(value) -> bool:
	return InspectorGadgetBaseUtil.is_array_type(value)

func has_controls() -> bool:
	return has_node("VBoxContainer")

func get_controls() -> Array:
	return [$VBoxContainer]

func populate_controls() -> void:
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.set_anchors_and_margins_preset(PRESET_WIDE)

	add_child(vbox)

func populate_value(value) -> void:
	var vbox = get_controls()[0]
	for i in range(0, value.size()):
		var val = value[i]
		var node = null

		match typeof(val):
			TYPE_BOOL:
				node = GadgetBool.new()
			TYPE_INT:
				node = GadgetInt.new()
			TYPE_REAL:
				node = GadgetFloat.new()
			TYPE_STRING:
				node = GadgetString.new()
			TYPE_VECTOR2:
				node = GadgetVector2.new()
			TYPE_VECTOR3:
				node = GadgetVector3.new()
			TYPE_TRANSFORM2D:
				node = GadgetTransform2D.new()
			TYPE_PLANE:
				node = GadgetPlane.new()
			TYPE_QUAT:
				node = GadgetQuat.new()
			TYPE_AABB:
				node = GadgetAABB.new()
			TYPE_BASIS:
				node = GadgetBasis.new()
			TYPE_TRANSFORM:
				node = GadgetTransform.new()
			TYPE_COLOR:
				node = GadgetColor.new()
			TYPE_RID:
				node = GadgetRID.new()
			TYPE_OBJECT:
				pass
			TYPE_DICTIONARY:
				pass
			TYPE_ARRAY:
				node = get_script().new()
			TYPE_RAW_ARRAY:
				node = get_script().new()
			TYPE_INT_ARRAY:
				node = get_script().new()
			TYPE_REAL_ARRAY:
				node = get_script().new()
			TYPE_STRING_ARRAY:
				node = get_script().new()
			TYPE_VECTOR2_ARRAY:
				node = get_script().new()
			TYPE_VECTOR3_ARRAY:
				node = get_script().new()
			TYPE_COLOR_ARRAY:
				node = get_script().new()

		if node:
			node.node_path = "../../" + node_path
			node.subnames = subnames + ":" + String(i)
			node.connect("change_property_begin", self, "change_property_begin")
			node.connect("change_property_end", self, "change_property_end")
			vbox.add_child(node)

func depopulate_value() -> void:
	var vbox = get_controls()[0]
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()
