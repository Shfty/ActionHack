extends Control

signal moveset_changed(moveset)
signal moveset_invalid_changed(moveset_invalid)
signal moveset_motions_changed()
signal moveset_motions_changed_value(motions)

signal motion_selected(motion)
signal motion_invalid_changed(motion_invalid)
signal selected_motion_changed(selected_motion)

signal move_selected(move)
signal selected_move_changed(selected_move)

signal curve_selected(curve, min_value, max_value, color)

signal demo_replay()

signal property_change_begin(object, property)
signal property_change_end(object, property)
signal property_changed()

signal show_moveset_editor()
signal show_motion_editor()
signal hide_editors()

var moveset_path: String = ""
var moveset: GridMoveset = null setget set_moveset
var selected_motion: GridMotion = null
var selected_move: GridMove = null

# Setters
func set_moveset_path(new_moveset_path: String) -> void:
	moveset_path = new_moveset_path
	var moveset = load(moveset_path)

	for motion in moveset.motions:
		print("loaded motion: %s %s %s" % [motion.get_name(), motion.get_path(), motion.get_class()])

	set_moveset(moveset)

func set_moveset(new_moveset: GridMoveset) -> void:
	if moveset != new_moveset:
		moveset = new_moveset

	if moveset == null:
		set_selected_motion(null)

	emit_signal("moveset_changed", moveset)
	emit_signal("moveset_invalid_changed", moveset == null)
	moveset_motions_changed()

	if moveset:
		show_moveset_editor()
	else:
		hide_editors()

func set_selected_motion_by_name(motion_name: String) -> void:
	if not motion_name in moveset.input_map:
		push_error("Selected move not in moveset")
		set_selected_motion(null)
		return

	set_selected_motion(moveset.input_map[motion_name] as GridMotion)

func set_selected_motion(motion: GridMotion) -> void:
	selected_motion = motion
	set_selected_move(null)
	emit_signal("motion_selected", selected_motion)
	emit_signal("selected_motion_changed", selected_motion)
	emit_signal("motion_invalid_changed", selected_motion == null)
	show_motion_editor()

func set_selected_move(move: GridMove) -> void:
	selected_move = move
	emit_signal("selected_move_changed", selected_move)

# Overrides
func _ready() -> void:
	hide_editors()

# Slots
func save_moveset() -> void:
	if not moveset:
		return

	for motion in moveset.motions:
		print("saving motion: %s %s %s" % [motion.get_name(), motion.get_path(), motion.get_class()])

	var path = moveset.get_path()
	if path != "":
		ResourceSaver.save(path, moveset)

func close_moveset() -> void:
	set_moveset(null)

func motion_selected(motion: GridMotion) -> void:
	emit_signal("motion_selected", motion)

func move_selected(move: GridMove) -> void:
	emit_signal("move_selected", move)

func curve_selected(curve: Curve, min_value: float, max_value: float, color: Color) -> void:
	emit_signal("curve_selected", curve, min_value, max_value, color)

func property_change_begin(object, subnames) -> void:
	emit_signal("property_change_begin", object, subnames)

func property_change_end(object, subnames) -> void:
	emit_signal("property_change_end", object, subnames)
	property_changed()

func property_changed() -> void:
	emit_signal("property_changed")

func add_moveset_motion() -> void:
	if not moveset:
		return

	var motion = GridMotion.new()
	motion.set_name("New Motion")
	moveset.motions.append(motion)
	moveset_motions_changed()

func delete_moveset_motion(motion: GridMotion) -> void:
	if not moveset:
		return

	if not motion in moveset.motions:
		return

	if motion == selected_motion:
		set_selected_motion(null)

	for action in moveset.input_map:
		if moveset.input_map[action] == motion:
			moveset.input_map[action] = null

	moveset.motions.erase(motion)
	moveset_motions_changed()

func moveset_motions_changed() -> void:
	emit_signal("moveset_motions_changed")
	emit_signal("moveset_motions_changed_value", moveset.motions if moveset else [])
	save_moveset()

func show_moveset_editor() -> void:
	emit_signal("show_moveset_editor")

func show_motion_editor() -> void:
	emit_signal("show_motion_editor")

func hide_editors() -> void:
	emit_signal("hide_editors")

func moveset_motion_list_gadget_event(event) -> void:
	var name = event.name
	match name:
		"grid_motion_select":
			set_selected_motion(event['motion'])
		"grid_motion_delete":
			delete_moveset_motion(event['motion'])
