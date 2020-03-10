extends Control

signal motion_selected(motion)
signal move_selected(move)
signal curve_selected(curve, min_value, max_value, color)
signal zoom_changed(zoom)

export(float) var zoom_sensitivity := 0.1

var zoom := 1.0
var button_group = ButtonGroup.new()

var cached_moveset: GridMoveset = null
var cached_motion: GridMotion = null

onready var timeline_hbox = $HBoxContainer

# Setters
func set_zoom(new_zoom: float) -> void:
	new_zoom = clamp(new_zoom, 0.01, 8)
	if zoom != new_zoom:
		zoom = new_zoom
		emit_signal("zoom_changed", zoom)
		size_flags_stretch_ratio = zoom

func populate_moveset(moveset: GridMoveset):
	cached_moveset = moveset

func populate_motion(motion: GridMotion):
	cached_motion = motion

	for child in timeline_hbox.get_children():
		if child is VBoxContainer:
			timeline_hbox.remove_child(child)
			child.queue_free()

	if not motion:
		return

	populate_motion_internal(motion, true)

func repopulate_motion() -> void:
	populate_motion(cached_motion)

func populate_motion_internal(motion: GridMotion, active: bool = false) -> void:
	var add_move_button = Button.new()
	add_move_button.text = "+"
	add_move_button.set_anchors_and_margins_preset(Control.PRESET_TOP_RIGHT)
	add_move_button.connect("pressed", self, "add_motion_move", [motion])

	var motion_button = Button.new()
	motion_button.text = motion.get_name()
	motion_button.clip_text = true
	motion_button.toggle_mode = true
	motion_button.pressed = active
	motion_button.group = button_group
	motion_button.mouse_filter = MOUSE_FILTER_PASS
	motion_button.size_flags_horizontal = SIZE_EXPAND_FILL
	motion_button.size_flags_vertical = SIZE_EXPAND_FILL
	motion_button.connect("pressed", self, "handle_motion_selected", [motion])
	motion_button.add_child(add_move_button)

	var curve_rect = CurveRect.new()
	curve_rect.set_curve(motion.motion_curve)
	curve_rect.set_min_value(0.0)
	curve_rect.set_max_value(1.0)
	curve_rect.anchor_right = 1
	curve_rect.anchor_bottom = 1
	curve_rect.mouse_filter = MOUSE_FILTER_IGNORE

	var curve_button = Button.new()
	curve_button.mouse_filter = MOUSE_FILTER_PASS
	curve_button.size_flags_horizontal = SIZE_EXPAND_FILL
	curve_button.size_flags_vertical = SIZE_EXPAND_FILL
	curve_button.rect_clip_content = true
	curve_button.toggle_mode = true
	curve_button.group = button_group
	curve_button.connect("pressed", self, "handle_curve_selected", [motion.motion_curve, 0.0, 1.0, Color.white])
	curve_button.add_child(curve_rect)

	var move_hbox = HBoxContainer.new()
	move_hbox.size_flags_horizontal = SIZE_EXPAND_FILL
	move_hbox.size_flags_vertical = SIZE_EXPAND_FILL
	move_hbox.size_flags_stretch_ratio = 4.0
	move_hbox.set("custom_constants/separation", 0)

	for move in motion.motion_moves:
		move_hbox.add_child(populate_move(motion, move))

	var vbox = VBoxContainer.new()
	vbox.set_meta("grid_motion", motion)
	vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	vbox.size_flags_vertical = SIZE_EXPAND_FILL
	vbox.size_flags_stretch_ratio = motion.get_duration() if motion.motion_moves.size() > 0 else 1.0
	vbox.add_child(motion_button)
	vbox.add_child(curve_button)
	vbox.add_child(move_hbox)
	vbox.set("custom_constants/separation", 0)

	timeline_hbox.add_child(vbox)

	if motion.next_motion_idx != -1:
		populate_motion_internal(cached_moveset.motions[motion.next_motion_idx])

func populate_move(motion: GridMotion, move: GridMove) -> Button:
	var delete_button = Button.new()
	delete_button.text = "-"
	delete_button.set_anchors_and_margins_preset(Control.PRESET_TOP_RIGHT)
	delete_button.connect("pressed", self, "delete_motion_move", [motion, move])

	var move_button = Button.new()
	move_button.text = move.get_name()
	move_button.size_flags_horizontal = SIZE_EXPAND_FILL
	move_button.size_flags_vertical = SIZE_EXPAND_FILL
	move_button.clip_text = true
	move_button.toggle_mode = true
	move_button.group = button_group
	move_button.set_meta("grid_move", move)
	move_button.mouse_filter = MOUSE_FILTER_PASS
	move_button.size_flags_horizontal = SIZE_EXPAND_FILL
	move_button.size_flags_vertical = SIZE_EXPAND_FILL
	move_button.connect("pressed", self, "handle_move_selected", [move])
	move_button.add_child(delete_button)

	var curve_rect_x = CurveRect.new()
	curve_rect_x.set_curve(move.curve_x)
	curve_rect_x.color = Color.red
	curve_rect_x.anchor_right = 1
	curve_rect_x.anchor_bottom = 1
	curve_rect_x.mouse_filter = MOUSE_FILTER_IGNORE

	var curve_button_x = Button.new()
	curve_button_x.mouse_filter = MOUSE_FILTER_PASS
	curve_button_x.size_flags_horizontal = SIZE_EXPAND_FILL
	curve_button_x.size_flags_vertical = SIZE_EXPAND_FILL
	curve_button_x.toggle_mode = true
	curve_button_x.group = button_group
	curve_button_x.connect("pressed", self, "handle_curve_selected", [move.curve_x, -1.0, 1.0, Color.red])
	curve_button_x.add_child(curve_rect_x)

	var curve_rect_y = CurveRect.new()
	curve_rect_y.set_curve(move.curve_y)
	curve_rect_y.color = Color.green
	curve_rect_y.anchor_right = 1
	curve_rect_y.anchor_bottom = 1
	curve_rect_y.mouse_filter = MOUSE_FILTER_IGNORE

	var curve_button_y = Button.new()
	curve_button_y.mouse_filter = MOUSE_FILTER_PASS
	curve_button_y.size_flags_horizontal = SIZE_EXPAND_FILL
	curve_button_y.size_flags_vertical = SIZE_EXPAND_FILL
	curve_button_y.toggle_mode = true
	curve_button_y.group = button_group
	curve_button_y.connect("pressed", self, "handle_curve_selected", [move.curve_y, -1.0, 1.0, Color.green])
	curve_button_y.add_child(curve_rect_y)

	var curve_rect_facing = CurveRect.new()
	curve_rect_facing.set_curve(move.curve_facing)
	curve_rect_facing.color = Color.blue
	curve_rect_facing.anchor_right = 1
	curve_rect_facing.anchor_bottom = 1
	curve_rect_facing.mouse_filter = MOUSE_FILTER_IGNORE

	var curve_button_facing = Button.new()
	curve_button_facing.mouse_filter = MOUSE_FILTER_PASS
	curve_button_facing.size_flags_horizontal = SIZE_EXPAND_FILL
	curve_button_facing.size_flags_vertical = SIZE_EXPAND_FILL
	curve_button_facing.toggle_mode = true
	curve_button_facing.group = button_group
	curve_button_facing.connect("pressed", self, "handle_curve_selected", [move.curve_facing, -1.0, 1.0, Color.blue])
	curve_button_facing.add_child(curve_rect_facing)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	vbox.size_flags_vertical = SIZE_EXPAND_FILL
	vbox.size_flags_stretch_ratio = move.duration
	vbox.set("custom_constants/separation", 0)
	vbox.add_child(move_button)
	vbox.add_child(curve_button_x)
	vbox.add_child(curve_button_y)
	vbox.add_child(curve_button_facing)

	return vbox

func handle_motion_selected(motion: GridMotion):
	emit_signal("motion_selected", motion)

func handle_curve_selected(curve: Curve, min_value: float, max_value: float, color: Color):
	emit_signal("curve_selected", curve, min_value, max_value, color)

func handle_move_selected(move: GridMove):
	emit_signal("move_selected", move)

func adjust_zoom(delta: float):
	set_zoom(zoom + (delta * zoom))

func set_animation_progress(animation_progress: float) -> void:
	for child in timeline_hbox.get_children():
		if child.get_meta("grid_motion") == current_motion:
			$PlayHead.rect_position.x = child.rect_position.x + (child.rect_size.x * animation_progress)
			break

var current_motion = null
func set_current_motion(new_current_motion: GridMotion) -> void:
	if current_motion != new_current_motion:
		current_motion = new_current_motion

func add_motion_move(motion: GridMotion) -> void:
	motion.add_move()
	repopulate_motion()

func delete_motion_move(motion: GridMotion, move: GridMove) -> void:
	motion.delete_move(move)
	repopulate_motion()
