class_name InspectorGadget
extends PanelContainer
tool

const HINT_INSPECTOR_GADGET_RESOURCE_TYPE = 24

signal change_property_begin(object, property)
signal change_property_end(object, property)

export(NodePath) var node_path setget set_node_path
export(String) var subnames setget set_subnames

export(Array, String) var property_blacklist := []

export(Array, Script) var resource_gadgets := []
export(Dictionary) var resource_gadget_metadata := {}

var node: Node
var target: Object setget set_target

func set_node_path(new_node_path: NodePath) -> void:
	if node_path != new_node_path:
		node_path = new_node_path
		update_node()

func set_subnames(new_subnames: String) -> void:
	if subnames != new_subnames:
		subnames = new_subnames
		update_node()

func set_target(new_target: Object) -> void:
	if target != new_target:
		target = new_target

		depopulate_gadgets()
		if target:
			populate_gadgets()

func update_node() -> void:
	if has_node(node_path):
		node = get_node(node_path)
		if subnames != "":
			set_target(node.get_indexed(subnames))
		else:
			set_target(node)
	else:
		node = null
		set_target(null)

func _ready() -> void:
	depopulate_controls()
	populate_controls()
	update_node()

func _process(delta: float) -> void:
	update_node()

func has_controls() -> bool:
	return has_node("ScrollContainer")

func populate_controls() -> void:
	if has_controls():
		return

	var vbox_container = VBoxContainer.new()
	vbox_container.name = "VBoxContainer"
	vbox_container.size_flags_horizontal = SIZE_EXPAND_FILL

	var scroll_container = ScrollContainer.new()
	scroll_container.name = "ScrollContainer"
	scroll_container.scroll_horizontal_enabled = false
	scroll_container.size_flags_horizontal = SIZE_FILL
	scroll_container.add_child(vbox_container)

	add_child(scroll_container)

func depopulate_controls() -> void:
	if not has_controls():
		return

	for child in get_children():
		remove_child(child)
		child.queue_free()

func populate_gadgets() -> void:
	if not has_controls():
		return

	if not target:
		return

	var vbox = $ScrollContainer/VBoxContainer
	var property_list = target.get_property_list()
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

			var value = target[property_name]
			var gadget: InspectorGadgetBase = get_gadget_for_type(value, property_name)
			if gadget:
				gadget.size_flags_horizontal = SIZE_EXPAND_FILL
				gadget.node_path = "../../../" + node_path
				if subnames != "":
					gadget.subnames = subnames + ":" + property_name
				else:
					gadget.subnames = ":" + property_name
				gadget.connect("change_property_begin", self, "change_property_begin")
				gadget.connect("change_property_end", self, "change_property_end")
				vbox.add_child(gadget)

				var separator = HSeparator.new()
				separator.size_flags_horizontal = SIZE_EXPAND_FILL
				vbox.add_child(separator)

func depopulate_gadgets() -> void:
	if not has_controls():
		return

	var vbox = $ScrollContainer/VBoxContainer
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

				var property_list = target.get_property_list()
				for property in property_list:
					if property['name'] == property_name:
						if property['hint'] == HINT_INSPECTOR_GADGET_RESOURCE_TYPE:
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
			gadget = GadgetString.new()
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

		TYPE_DICTIONARY:
			pass
		TYPE_ARRAY:
			gadget = GadgetArray.new()
		TYPE_RAW_ARRAY:
			gadget = GadgetArray.new()
		TYPE_INT_ARRAY:
			gadget = GadgetArray.new()
		TYPE_REAL_ARRAY:
			gadget = GadgetArray.new()
		TYPE_STRING_ARRAY:
			gadget = GadgetArray.new()
		TYPE_VECTOR2_ARRAY:
			gadget = GadgetArray.new()
		TYPE_VECTOR3_ARRAY:
			gadget = GadgetArray.new()
		TYPE_COLOR_ARRAY:
			gadget = GadgetArray.new()

	return gadget

func change_property_begin(object, key) -> void:
	emit_signal("change_property_begin", object, key)

func change_property_end(object, key) -> void:
	emit_signal("change_property_end", object, key)
