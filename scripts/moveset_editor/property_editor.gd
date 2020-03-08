extends PanelContainer

signal property_change_begin(object, property)
signal property_change_end(object, property)
signal moveset_motions_changed()

export(Array, String) var property_blacklist := [
	"motion_moves",
	"motion_curve",
	"curve_x",
	"curve_y",
	"curve_facing"
]

onready var vbox_container = $VBoxContainer/ScrollContainer/VBoxContainer
onready var motion_name_line_edit = $VBoxContainer/MotionNameLineEdit

var cached_object: Object

func populate_properties(object: Object):
	cached_object = object

	visible = true
	clear_properties()

	if not object:
		motion_name_line_edit.visible = false
		motion_name_line_edit.editable = false
		motion_name_line_edit.text = ""
		if motion_name_line_edit.is_connected("text_entered", self, "set_resource_name"):
			motion_name_line_edit.disconnect("text_entered", self, "set_resource_name")
		return

	if object is Resource:
		motion_name_line_edit.visible = true
		motion_name_line_edit.editable = true
		motion_name_line_edit.text = object.get_name()
		motion_name_line_edit.connect("text_entered", self, "set_resource_name")

	for property in object.get_property_list():
		if property['name'] in property_blacklist:
			continue

		if PROPERTY_USAGE_SCRIPT_VARIABLE & property['usage'] == PROPERTY_USAGE_SCRIPT_VARIABLE:
			match property['type']:
				TYPE_BOOL:
					populate_bool_property(object, property)
				TYPE_INT:
					populate_numeric_property(object, property, false)
				TYPE_REAL:
					populate_numeric_property(object, property, true)
				TYPE_VECTOR2:
					populate_vector2_property(object, property)
				TYPE_OBJECT:
					if object is GridMotion:
						populate_motion_choice_property(object, property)
					else:
						populate_unhandled_property(object, property)
				_:
					populate_unhandled_property(object, property)

func repopulate_properties() -> void:
	populate_properties(cached_object)

func curve_selected(curve: Curve, min_value: float, max_value: float, color: Color) -> void:
	visible = false

func populate_bool_property(object: Object, property: Dictionary) -> void:
	var label = create_label(property)

	var checkbox = CheckBox.new()
	checkbox.pressed = object[property['name']]
	checkbox.connect("toggled", self, "set_move_property", [object, property['name']])

	var hbox = HBoxContainer.new()
	hbox.add_child(label)
	hbox.add_child(checkbox)

	vbox_container.add_child(hbox)

func populate_numeric_property(object: Object, property: Dictionary, real: bool) -> void:
	var label = create_label(property)

	var spinbox = SpinBox.new()
	spinbox.allow_lesser = true
	if real:
		spinbox.step = 0.1
	else:
		spinbox.rounded = true
		spinbox.step = 1
	spinbox.value = object[property['name']]

	spinbox.connect("value_changed", self, "set_move_property", [object, property['name']])

	var hbox = HBoxContainer.new()
	hbox.add_child(label)
	hbox.add_child(spinbox)

	vbox_container.add_child(hbox)

func populate_vector2_property(object: Object, property: Dictionary) -> void:
	var label = create_label(property)

	var spinbox_x = SpinBox.new()
	spinbox_x.allow_lesser = true
	spinbox_x.step = 0.1
	spinbox_x.value = object[property['name']].x
	spinbox_x.connect("value_changed", self, "set_vector2_x_property", [object, property['name']])

	var spinbox_y = SpinBox.new()
	spinbox_y.allow_lesser = true
	spinbox_y.step = 0.1
	spinbox_y.value = object[property['name']].y
	spinbox_y.connect("value_changed", self, "set_vector2_y_property", [object, property['name']])

	var vbox = VBoxContainer.new()
	vbox.add_child(spinbox_x)
	vbox.add_child(spinbox_y)

	var hbox = HBoxContainer.new()
	hbox.add_child(label)
	hbox.add_child(vbox)

	vbox_container.add_child(hbox)

func populate_motion_choice_property(object: Object, property: Dictionary) -> void:
	var label = create_label(property)
	var owner = get_owner()

	var current_value = object[property['name']]
	var motion_menu_button = MovesetEditorUtil.create_motion_menu(owner.moveset, object[property['name']], cached_object)
	motion_menu_button.get_popup().connect("index_pressed", self, "set_motion_choice_property", [object, property['name'], owner.moveset])

	var hbox = HBoxContainer.new()
	hbox.add_child(label)
	hbox.add_child(motion_menu_button)

	vbox_container.add_child(hbox)

func populate_unhandled_property(object: Object, property: Dictionary) -> void:
	var label = create_label(property)
	vbox_container.add_child(label)

func create_label(property: Dictionary) -> Label:
	var label = Label.new()
	label.text = property['name'].capitalize()
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	return label

func set_move_property(value, object: Object, property: String) -> void:
	emit_signal("property_change_begin", object, property)
	object[property] = value
	emit_signal("property_change_end", object, property)

func set_vector2_x_property(value: float, object: Object, property_name: String) -> void:
	set_move_property(Vector2(value, object[property_name].y), object, property_name)

func set_vector2_y_property(value: float, object: Object, property_name: String) -> void:
	set_move_property(Vector2(object[property_name].x, value), object, property_name)

func set_motion_choice_property(value: int, object: Object, property_name: String, moveset: GridMoveset) -> void:
	if value == 0:
		set_move_property(null, object, property_name)
	else:
		set_move_property(moveset.motions[value - 1], object, property_name)

func clear_properties():
	for child in vbox_container.get_children():
		vbox_container.remove_child(child)
		child.queue_free()

func set_resource_name(name: String) -> void:
	if not cached_object:
		return

	emit_signal("property_change_begin", cached_object, "resource_name")
	cached_object.set_name(name)
	emit_signal("property_change_end", cached_object, "resource_name")
	emit_signal("moveset_motions_changed")
