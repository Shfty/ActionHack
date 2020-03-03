class_name MonsterController
extends GridController

export(float) var ticks_per_second = 2
export(float) var wakeup_range = 6.0
export(bool) var knows_sidestep = true
export(bool) var knows_quickturn = true

var awake = false
var aggro_target: GridEntity = null

var tick_progress = 0.0

func _ready() -> void:
	._ready()
	target_actor.connect("hitstun_triggered", self, "handle_hitstun_triggered")

func _physics_process(delta: float) -> void:
	tick_progress -= delta

	if tick_progress <= 0.0:
		tick()
		reset_tick_progress()

func get_tick_rate():
	return 1.0 / ticks_per_second

func reset_tick_progress(progress: float = get_tick_rate()):
	tick_progress = progress

func handle_hitstun_triggered(duration: float):
	reset_tick_progress(duration + get_tick_rate())

func tick():
	if awake:
		tick_awake()
	else:
		tick_asleep()

func tick_awake() -> void:
	if aggro_target:
		tick_aggro()
	else:
		sleep()

func tick_aggro() -> void:
	var delta = Vector2(aggro_target.x, aggro_target.y) - Vector2(target_actor.x, target_actor.y)
	delta = GridUtil.rotate_vec2_by_facing(delta, -target_actor.facing)

	if abs(delta.x) == abs(delta.y) and knows_sidestep:
		# Diagonal from target
		if knows_sidestep:
			if check_move(sign(delta.x), 0):
				# Not next to a wall, sidestep
				buffer_sidestep_tap(delta.x > 0)
			else:
				# Next to a wall
				if delta.y < 0:
					# Target in front
					buffer_tap("move_forward")
				else:
					# Target behind
					if knows_quickturn:
						buffer_quickturn_tap(delta.x < 0)
					else:
						buffer_turn_tap(delta.x < 0)
						yield(get_tree().create_timer(1.0 / ticks_per_second), "timeout")
						buffer_turn_tap(delta.x < 0)
	elif abs(delta.x) > abs(delta.y):
		# Target is to side
		if check_move(sign(delta.x), 0):
			# Not next to a wall, turn
			buffer_turn_tap(delta.x > 0)
		else:
			# Next to a wall, move along it
			buffer_tap("move_forward")
	elif delta.y > 0:
		# Target is behind
		if knows_quickturn:
			buffer_tap("quickturn_right")
		else:
			buffer_turn_tap(delta.x > 0)
	else:
		# Target is in front
		if delta.length() > 1:
			# Not in melee range
			if check_move(0, -1):
				# Not in front of wall
				buffer_tap("move_forward")
			else:
				# In front of wall, turn
				buffer_turn_tap(delta.x > 0)
		else:
			# In melee range
			buffer_tap("attack")

func check_move(x: int, y: int) -> bool:
	var world = target_actor.get_parent()
	if not world:
		return false

	var from_position = Vector2(target_actor.x, target_actor.y)
	var delta_position = GridUtil.rotate_vec2_by_facing(Vector2(x, y), target_actor.facing)
	var to_position = from_position + delta_position
	if not world.check_tile_map_collision(to_position.x, to_position.y):
		return true

	return false

func buffer_sidestep_tap(clockwise: bool) -> void:
	buffer_tap("move_right" if clockwise else "move_left")

func buffer_turn_tap(clockwise: bool) -> void:
	buffer_tap("turn_right" if clockwise else "turn_left")

func buffer_quickturn_tap(clockwise: bool) -> void:
	buffer_tap("quickturn_right" if clockwise else "quickturn_left")

func tick_asleep() -> void:
	var world = target_actor.get_parent()
	if not world:
		return

	for node in world.get_children():
		if node is GridEntity:
			if should_aggro_entity(node):
				wake_up()
				aggro(node)
				tick_awake()

func wake_up() -> void:
	awake = true

func aggro(target: GridEntity = null) -> void:
	if aggro_target:
		aggro_target.disconnect("tree_exiting", self, "target_dead")

	aggro_target = target
	aggro_target.connect("tree_exiting", self, "target_dead")

func target_dead() -> void:
	aggro_target = null
	sleep()

func sleep():
	awake = false

func should_aggro_entity(entity: GridEntity) -> bool:
	if entity == target_actor or not entity is GridCombatant:
		return false

	var delta = Vector2(entity.x, entity.y) - Vector2(target_actor.x, target_actor.y)
	if delta.length() > wakeup_range:
		return false

	for child in entity.get_children():
		if child is PlayerController:
			return true

	return false
