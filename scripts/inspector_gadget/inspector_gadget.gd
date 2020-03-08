class_name InspectorGadget
extends InspectorGadgetBase
tool

export(Array, String) var property_blacklist := []
export(Array, Script) var resource_gadgets := []
export(Dictionary) var resource_gadget_metadata := {}

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
	return value is Object or InspectorGadgetUtil.is_array_type(value) or value == null

func has_controls() -> bool:
	return has_node("PanelContainer")

func get_controls() -> Array:
	return [$PanelContainer/VBoxContainer]

func populate_controls() -> void:
	var vbox_container = VBoxContainer.new()
	vbox_container.name = "VBoxContainer"
	vbox_container.size_flags_horizontal = SIZE_EXPAND_FILL

	var panel_container = PanelContainer.new()
	panel_container.name = "PanelContainer"
	panel_container.size_flags_horizontal = SIZE_FILL
	panel_container.add_child(vbox_container)

	add_child(panel_container)

func populate_value(value) -> void:
	var vbox = get_controls()[0]
	if value is Object:
		var property_list = value.get_property_list()
		for property in property_list:
			if property['name'] in property_blacklist:
				continue

			var is_editor_variable = PROPERTY_USAGE_EDITOR & property['usage'] == PROPERTY_USAGE_EDITOR
			var is_script_variable = PROPERTY_USAGE_SCRIPT_VARIABLE & property['usage'] == PROPERTY_USAGE_SCRIPT_VARIABLE
			if is_editor_variable and is_script_variable:
				var property_name = property['name']

				var label = Label.new()
				label.text = property_name.capitalize()
				vbox.add_child(label)

				var gadget: InspectorGadgetBase = get_gadget_for_type(value[property_name], property_name)
				if gadget:
					gadget.size_flags_horizontal = SIZE_EXPAND_FILL
					gadget.node_path = "../../../" + node_path
					if subnames != "":
						gadget.subnames = subnames + ":" + property_name
					else:
						gadget.subnames = ":" + property_name
					gadget.connect("change_property_begin", self, "change_property_begin")
					gadget.connect("change_property_end", self, "change_property_end")
					gadget.connect("gadget_event", self, "gadget_event")
					vbox.add_child(gadget)

					var separator = HSeparator.new()
					separator.size_flags_horizontal = SIZE_EXPAND_FILL
					vbox.add_child(separator)
	if value is Array:
		for i in range(0, value.size()):
			var label = Label.new()
			label.text = String(i)
			vbox.add_child(label)

			var gadget: InspectorGadgetBase = get_gadget_for_type(value[i])
			if gadget:
				gadget.size_flags_horizontal = SIZE_EXPAND_FILL
				gadget.node_path = "../../../" + node_path
				gadget.subnames = subnames + ":" + String(i)
				gadget.connect("change_property_begin", self, "change_property_begin")
				gadget.connect("change_property_end", self, "change_property_end")
				gadget.connect("gadget_event", self, "gadget_event")
				vbox.add_child(gadget)

				var separator = HSeparator.new()
				separator.size_flags_horizontal = SIZE_EXPAND_FILL
				vbox.add_child(separator)

func depopulate_value() -> void:
	var vbox = get_controls()[0]
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()

func get_gadget_for_type(value, property_name = "") -> InspectorGadgetBase:
	var gadget: InspectorGadgetBase = null

	match typeof(value):
		TYPE_NIL:
			for i in range(resource_gadgets.size() - 1, -1, -1):
				var  resource_gadget = resource_gadgets[i]
				if not resource_gadget:
					continue

				if not resource_gadget.get_base_script() == GadgetResource:
					continue

				var target = InspectorGadgetUtil.get_indexed_ex(_node, subnames)
				var property_list = target.get_property_list()
				for property in property_list:
					if property['name'] == property_name:
						if property['hint'] == PROPERTY_HINT_RESOURCE_TYPE:
							if resource_gadget.supports_resource(property['hint_string']):
								gadget = resource_gadget.new(NodePath(), "", resource_gadget_metadata)
								break
		TYPE_BOOL:
			gadget = GadgetBool.new()
		TYPE_INT:
			gadget = GadgetInt.new()
		TYPE_REAL:
			gadget = GadgetFloat.new()
		TYPE_STRING:
			gadget = GadgetStringEdit.new()
		TYPE_VECTOR2:
			gadget = GadgetVector2.new()
		TYPE_RECT2:
			gadget = GadgetRect2.new()
		TYPE_VECTOR3:
			gadget = GadgetVector3.new()
		TYPE_TRANSFORM2D:
			gadget = GadgetTransform2D.new()
		TYPE_PLANE:
			gadget = GadgetPlane.new()
		TYPE_QUAT:
			gadget = GadgetQuat.new()
		TYPE_AABB:
			gadget = GadgetAABB.new()
		TYPE_BASIS:
			gadget = GadgetBasis.new()
		TYPE_TRANSFORM:
			gadget = GadgetTransform.new()
		TYPE_COLOR:
			gadget = GadgetColor.new()
		TYPE_RID:
			gadget = GadgetRID.new()
		TYPE_OBJECT:
			for i in range(resource_gadgets.size() - 1, -1, -1):
				var  resource_gadget = resource_gadgets[i]
				if not resource_gadget:
					continue

				if not resource_gadget.get_base_script() == GadgetResource:
					continue

				if resource_gadget.supports_type(value):
					gadget = resource_gadget.new(NodePath(), "", resource_gadget_metadata)
					break

			if not gadget:
				gadget = get_script().new()
		TYPE_ARRAY:
			gadget = get_script().new()
		TYPE_RAW_ARRAY:
			gadget = get_script().new()
		TYPE_INT_ARRAY:
			gadget = get_script().new()
		TYPE_REAL_ARRAY:
			gadget = get_script().new()
		TYPE_STRING_ARRAY:
			gadget = get_script().new()
		TYPE_VECTOR2_ARRAY:
			gadget = get_script().new()
		TYPE_VECTOR3_ARRAY:
			gadget = get_script().new()
		TYPE_COLOR_ARRAY:
			gadget = get_script().new()

	return gadget
