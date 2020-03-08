class_name GridEvent
extends Resource


enum EventType {
	NONE,
	SPAWN
}

export(float, 0, 1) var time := 0.0
export(EventType) var event_type := EventType.NONE

export(Script) var spawn_class: Script = null
export(Vector2) var spawn_relative_position := Vector2.ZERO
export(Array) var spawn_params := []

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

	if not 'source' in args:
		push_warning("Couldn't spawn: No source argument")
		return

	var source = args['source'] as GridEntity
	var position = Vector2(source.x, source.y)

	var pos = (position + GridUtil.rotate_vec2_by_facing(spawn_relative_position, source.facing))
	inst.set_x(pos.x)
	inst.set_y(pos.y)
	inst.set_facing(source.facing)
	inst.source = source
	source.get_parent().add_child(inst)

	if inst.has_method('init'):
		inst.init(spawn_params)
