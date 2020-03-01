class_name GridEvent
extends Resource


enum EventType {
	NONE,
	SPAWN
}

export(float, 0, 1) var time
export(EventType) var event_type

export(Script) var spawn_class
export(Vector2) var spawn_relative_position
export(Array) var spawn_params

func run(args: Dictionary):
	match event_type:
		EventType.SPAWN:
			run_spawn(args)

func run_spawn(args: Dictionary) -> void:
	if not spawn_class:
		push_warning("Couldn't spawn: Invalid script class")
		return

	var inst = spawn_class.new()

	if not inst:
		push_warning("Couldn't spawn: Unable to instance class")
		return

	if not 'parent' in args:
		push_warning("Couldn't spawn: No parent argument")
		return

	if not 'position' in args:
		push_warning("Couldn't spawn: No position argument")
		return

	if not 'facing' in args:
		push_warning("Couldn't spawn: No position argument")
		return

	var pos = (args['position'] + GridUtil.rotate_vec2_by_facing(spawn_relative_position, args['facing']))
	inst.set_x(pos.x)
	inst.set_y(pos.y)
	inst.set_facing(args['facing'])
	args['parent'].add_child(inst)

	if inst.has_method('init'):
		inst.init(spawn_params)
