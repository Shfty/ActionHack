class_name InspectorGadgetBase
extends MarginContainer

signal change_property_begin(object, property)
signal change_property_end(object, property)

export(NodePath) var node_path: NodePath setget set_node_path
export(String) var subnames: String setget set_subnames
export(bool) var editable := true

var _node: Node setget set_node
var _property: String setget set_property
var _value setget set_value

# Setters
func set_node_path(new_node_path: NodePath) -> void:
	if node_path != new_node_path:
		node_path = new_node_path
		update_node()
		update_property()
	update_configuration_warning()

func set_subnames(new_subnames: String) -> void:
	if subnames != new_subnames:
		subnames = new_subnames
		update_property()
	update_configuration_warning()

func set_node(new_node: Node) -> void:
	if _node != new_node:
		_node = new_node
		_node_changed()

func set_property(new_property: String) -> void:
	if not _node:
		return

	if _property != new_property:
		_property = new_property
		_property_changed()

func set_value(new_value) -> void:
	var value_type = typeof(_value)
	var new_type = typeof(new_value)
	if typeof(_value) != typeof(new_value):
		_value = new_value
		_value_changed()

	if _value != new_value:
		_value = new_value
		_value_changed()

# Overrides
func _init(in_node_path = null, in_subnames = null) -> void:
	if in_node_path:
		node_path = in_node_path

	if in_subnames:
		subnames = in_subnames

func _ready() -> void:
	_try_populate_controls()

	update_node()
	update_property()

func _process(delta: float) -> void:
	if not _node:
		return

	var value = _get_value()
	set_value(value)

func _get_configuration_warning() -> String:
	if not _node:
		return "Node path invalid"

	var value = _get_value()

	if not value:
		return "Subnames invalid"

	if not supports_type(value):
		return "Unsupported type"

	return ""

# Business logic
func _node_changed() -> void:
	_property_changed()

func _property_changed() -> void:
	_value_changed()

func _value_changed():
	_try_populate_value()

func _get_value():
	if not _node:
		return null

	if _property == "":
		return null

	var property_comps := _property.split(":")
	var key = property_comps[-1]
	property_comps.resize(property_comps.size() - 1)
	var property_subnames = property_comps.join(":")

	if property_comps.size() == 0:
		return null
	elif property_comps.size() == 1:
		return _node.get_indexed(_property)
	else:
		var value = _node.get_indexed(property_subnames)

		if key.is_valid_integer() and InspectorGadgetBaseUtil.is_array_type(value):
			return value[key.to_int()]
		elif value is Dictionary:
			if key == "keys":
				return value.keys()
			elif key == "values":
				return value.values()
			else:
				if key in value:
					return value[key]
		elif value is Object:
			return value[key]
		else:
			return _node.get_indexed(_property)

	return null

func _set_value(new_value) -> void:
	if not _node:
		return

	if _property == "":
		return

	var property_comps := _property.split(":")
	var key = property_comps[-1]
	property_comps.resize(property_comps.size() - 1)
	var property_subnames = property_comps.join(":")

	if property_comps.size() == 0:
		return
	elif property_comps.size() == 1:
		_set_indexed(_node, _property, new_value)
	else:
		var value = _node.get_indexed(property_subnames)

		if key.is_valid_integer() and InspectorGadgetBaseUtil.is_array_type(value):
			value[key.to_int()] = new_value
			_set_indexed(_node, property_subnames, value)
		elif value is Dictionary:
			if key in value:
				value[key] = new_value
				_set_indexed(_node, property_subnames, value)
		elif value is Object:
			value[key] = new_value
			_set_indexed(_node, property_subnames, value)
		else:
			_set_indexed(_node, _property, new_value)

func _set_indexed(node: Node, subnames: String, new_value) -> void:
	var subname_comps = subnames.split(":")

	var target_chain = []

	var target = node
	while subname_comps.size() > 0:
		var comp = subname_comps[0]
		subname_comps.remove(0)
		if comp == "":
			continue

		if comp.is_valid_integer():
			target_chain.append([comp.to_int(), target[comp.to_int()]])
			target = target[comp.to_int()]
		else:
			target_chain.append([comp, target[comp]])
			target = target[comp]

	target_chain[-1][1] = new_value

	while true:
		var pair = target_chain[-1]
		target_chain.resize(target_chain.size() - 1)
		var key = pair[0]
		var value = pair[1]

		if target_chain.size() > 0:
			target_chain[-1][1][key] = value
		else:
			change_property_begin(node, key)
			node[key] = value
			change_property_end(node, key)
			break

func _try_populate_controls() -> void:
	_depopulate_controls()
	populate_controls()

func _try_populate_value() -> void:
	if not has_controls():
		return

	var controls = get_controls()

	depopulate_value()

	if not _node:
		return

	var value = _get_value()
	if not supports_type(value):
		return

	populate_value(value)

func _depopulate_controls() -> void:
	if not has_controls():
		return

	var controls := get_controls()
	for control in controls:
		remove_child(control)
		control.queue_free()

# Virtuals
static func supports_type(value) -> bool:
	return false

func has_controls() -> bool:
	return false

func get_controls() -> Array:
	return []

func populate_controls() -> void:
	pass

func populate_value(value) -> void:
	pass

func depopulate_value() -> void:
	pass

# Utility
func update_node() -> void:
	if has_node(node_path):
		set_node(get_node(node_path))
	else:
		set_node(null)

func update_property() -> void:
	set_property(subnames)

func change_property_begin(object: Object, property: String) -> void:
	emit_signal("change_property_begin", object, property)

func change_property_end(object: Object, property: String) -> void:
	emit_signal("change_property_end", object, property)
