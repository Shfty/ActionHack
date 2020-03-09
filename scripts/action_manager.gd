extends Node

signal property_changed()

var undo_redo = UndoRedo.new()

class PropertyChangeAction:
	var target_object
	var target_property
	var from_value
	var to_value

	func _init(in_target_object, in_property, in_from_value):
		target_object = in_target_object
		target_property = in_property
		from_value = in_from_value

var property_change_actions := []

func property_change_begin(object, property) -> void:
	property_change_actions.append(PropertyChangeAction.new(object, property, InspectorGadgetUtil.get_indexed_ex(object, property)))

func property_change_end(object, property) -> void:
	var action = null
	for action_comp in property_change_actions:
		if action_comp.target_object == object and action_comp.target_property == property:
			action = action_comp
			break

	if not action:
		return

	action.to_value = InspectorGadgetUtil.get_indexed_ex(object, property)
	undo_redo.create_action("Set %s" % [property])
	undo_redo.add_do_method(self, "do_change_property", action)
	undo_redo.add_undo_method(self, "undo_change_property", action)
	undo_redo.commit_action()
	property_change_actions.erase(action)

func do_change_property(action: PropertyChangeAction) -> void:
	print("Do change property %s on object %s to %s" % [action.target_property, action.target_object, action.to_value])
	InspectorGadgetUtil.set_indexed_ex(action.target_object, action.target_property, action.to_value)

func undo_change_property(action: PropertyChangeAction) -> void:
	print("Undo change property %s on object %s to %s" % [action.target_property, action.target_object, action.to_value])
	InspectorGadgetUtil.set_indexed_ex(action.target_object, action.target_property, action.from_value)

func _unhandled_key_input(event: InputEventKey) -> void:
	if event is InputEventWithModifiers:
		if event.pressed and event.scancode == KEY_Z:
			if event.control and event.shift:
				if undo_redo.redo():
					emit_signal("property_changed")
				else:
					print("Nothing to redo")
			elif event.control:
				if undo_redo.undo():
					emit_signal("property_changed")
				else:
					print("Nothing to undo")

