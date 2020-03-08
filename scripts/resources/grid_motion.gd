class_name GridMotion
extends Resource
tool

export(Array, Resource) var motion_moves setget set_moves
export(Curve) var motion_curve = null

export(bool) var looping = false
export(bool) var cancelable = false
export(bool) var lock_input_buffer = false
export(Array, String) var lock_inputs setget set_lock_inputs

var hit_wall_motion = null
var hit_entity_motion = null
var next_motion = null

func _init() -> void:
	if not motion_curve:
		motion_curve = Curve.new()
		motion_curve.add_point(Vector2.ZERO, 0, tan(deg2rad(45)))
		motion_curve.add_point(Vector2.ONE, tan(deg2rad(45)), 0)

func set_moves(new_motion_moves: Array) -> void:
	if motion_moves != new_motion_moves:
		motion_moves = new_motion_moves
		if motion_moves.size() > 0:
			if not motion_moves[-1]:
				motion_moves[-1] = Object()

func set_lock_inputs(new_lock_inputs: Array) -> void:
	if lock_inputs != new_lock_inputs:
		lock_inputs = new_lock_inputs

func get_duration() -> float:
	var duration = 0.0
	for move in motion_moves:
		duration += move.duration
	return duration

func _get_property_list() -> Array:
	return [
		{
			'name': 'hit_wall_motion',
			'type': TYPE_OBJECT,
			'hint': InspectorGadget.HINT_INSPECTOR_GADGET_RESOURCE_TYPE,
			'hint_string': "GridMotion",
			'usage': PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			'name': 'hit_entity_motion',
			'type': TYPE_OBJECT,
			'hint': InspectorGadget.HINT_INSPECTOR_GADGET_RESOURCE_TYPE,
			'hint_string': "GridMotion",
			'usage': PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			'name': 'next_motion',
			'type': TYPE_OBJECT,
			'hint': InspectorGadget.HINT_INSPECTOR_GADGET_RESOURCE_TYPE,
			'hint_string': "GridMotion",
			'usage': PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		}
	]
