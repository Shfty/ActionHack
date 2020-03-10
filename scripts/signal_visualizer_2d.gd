extends Control
tool

func _ready() -> void:
	set_meta("_edit_lock_", true)
	queue_redraw()

func queue_redraw():
	update()
	yield(get_tree().create_timer(0.1), "timeout")
	queue_redraw()

func _draw() -> void:
	var root_node = get_owner()
	draw_connections(root_node)

func draw_connections(node: Node):
	if not node.has_method('is_visible_in_tree'):
		return

	if not node.is_visible_in_tree():
		return

	var signal_list = node.get_signal_list()
	for signal_dict in signal_list:
		var signal_name = signal_dict['name']
		var connections = node.get_signal_connection_list(signal_name)
		for connection in connections:
			draw_connection(connection)

	for child in node.get_children():
		draw_connections(child)

func draw_connection(connection: Dictionary):
	if not CONNECT_PERSIST & connection['flags'] == CONNECT_PERSIST:
		return

	var source = connection['source']
	var target = connection['target']

	if not target.has_method('is_visible_in_tree'):
		return

	if not target.is_visible_in_tree():
		return

	if not 'rect_global_position' in source or not 'rect_global_position' in target:
		return

	var from = source.rect_global_position + source.rect_size * 0.5
	var to = target.rect_global_position + target.rect_size * 0.5

	var delta = to - from
	var normal = (to - from).normalized()
	var tangent = normal.rotated(PI * 0.5)
	var length = (to - from).length()
	var center = (from + to) * 0.5

	var normal_offset = normal * 10.0
	var tangent_offset = tangent * 10.0

	draw_circle(from + tangent_offset, 2.0, Color.pink)
	draw_circle(to + tangent_offset, 2.0, Color.lightgreen)
	draw_arrow(from + normal_offset + tangent_offset, to - normal_offset + tangent_offset, Color.red)

	var font = get_font("font")

	var signal_name = connection['signal']
	var signal_string_size = font.get_string_size(signal_name)
	var signal_string_pos = normal.rotated(PI * 0.5) * signal_string_size.length()
	draw_line(from + tangent_offset + (normal * length * 0.25), from + (normal * length * 0.25) + signal_string_pos - (signal_string_pos.normalized() * signal_string_size.y), Color.pink)
	draw_string(font, from + tangent_offset + (normal * length * 0.25) + signal_string_pos - (signal_string_size * Vector2(0.5, -0.5)), connection['signal'])

	var method_name = connection['method']
	var method_string_size = font.get_string_size(method_name)
	var method_string_pos = normal.rotated(PI * 0.5) * method_string_size.length()
	draw_line(from + tangent_offset + (normal * length * 0.75), from + (normal * length * 0.75) + method_string_pos - (method_string_pos.normalized() * method_string_size.y), Color.lightgreen)
	draw_string(font, from + tangent_offset + (normal * length * 0.75) + method_string_pos - (method_string_size * Vector2(0.5, -0.5)), connection['method'])

func draw_arrow(from: Vector2, to: Vector2, color: Color, width: float = 1.0, antialiased: bool = false):
	draw_line(from, to, color, width, antialiased)

	var tf = (from - to).normalized()
	var left_spoke = tf.rotated(deg2rad(-30.0))
	var right_spoke = tf.rotated(deg2rad(30.0))
	draw_line(to, to + left_spoke * 10.0, color, width, antialiased)
	draw_line(to, to + right_spoke * 10.0, color, width, antialiased)
