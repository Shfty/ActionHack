class_name GridActor
extends GridEntity
tool

signal rotation_changed(rotation)

export(Resource) var moveset = null

var input_buffer := []

var current_motion: GridMotion = null
var motion_duration := -1.0
var current_move_dict := {}

var motion_progress := 0.0
var prev_move: GridMove = null
var prev_move_progress := 0.0

var animation_progress := 0.0

# Overrides
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if current_motion:
		motion_progress += delta
		update_motion(motion_progress)

func update_motion(progress: float = 0.0):
	var current_move = get_current_move(progress)
	if current_move != prev_move or prev_move == null:
		var rotated_delta_position = GridUtil.rotate_vec2_by_facing(current_move.delta_position, facing)
		var target_x = x + rotated_delta_position.x
		var target_y = y + rotated_delta_position.y

		var world = get_world()
		if world:
			if world.check_tile_map_collision(target_x, target_y):
				input_buffer.clear()
				if current_motion.hit_wall_motion:
					set_motion(current_motion.hit_wall_motion)
				else:
					set_motion(null)
				return
			elif world.check_entity_collision(target_x, target_y, self):
				input_buffer.clear()
				if current_motion.hit_entity_motion:
					set_motion(current_motion.hit_entity_motion)
				else:
					set_motion(null)
				return
			else:
				x += rotated_delta_position.x
				y += rotated_delta_position.y
				facing += current_move.delta_facing

	prev_move = current_move

	var move_progress = 1.0
	if current_move.duration > 0.0:
		move_progress = (progress - current_move_dict[current_move]['start']) / current_move.duration

	for event in current_move.events:
		if prev_move_progress <= event.time and move_progress >= event.time:
			event.run({"source": self})
	prev_move_progress = move_progress

func get_curve_coord(motion_progress: float) -> float:
	if motion_duration == 0.0:
		return 1.0

	return motion_progress / motion_duration

func get_curve_index(curve_sample: float) -> int:
	return min(floor(curve_sample * current_motion.motion_moves.size()), current_motion.motion_moves.size() - 1) as int

func get_current_move(motion_progress: float) -> GridMove:
	var curve_sample = current_motion.motion_curve.interpolate(get_curve_coord(motion_progress))
	var curve_idx := get_curve_index(curve_sample)
	return current_motion.motion_moves[curve_idx] as GridMove

func _process(delta: float):
	if Engine.is_editor_hint():
		return

	if current_motion:
		update_animation(delta)
	else:
		$Offset/Sprite.position = lerp($Offset/Sprite.position, Vector2.ZERO, 0.1)
		$Offset/Sprite.rotation_degrees = lerp($Offset/Sprite.rotation_degrees, 0.0, 0.1)

func update_animation(delta: float = 0.0):
	var world_pos = Vector2(x, y) * GridUtil.TILE_SIZE
	var world_rot = GridUtil.facing_to_angle(facing)

	if current_motion:
		animation_progress = animation_progress + delta

		var current_move = get_current_move(motion_progress)
		var move_start = current_move_dict[current_move]['start']
		var move_end = current_move_dict[current_move]['end']

		var curve_sample = current_motion.motion_curve.interpolate(get_curve_coord(animation_progress))
		var curve_progress = curve_sample * current_motion.motion_moves.size()
		var curve_idx = get_curve_index(current_motion.motion_curve.interpolate(get_curve_coord(motion_progress)))
		curve_progress -= curve_idx

		var normalized_start = move_start / motion_duration
		var normalized_duration = current_move.duration / motion_duration
		var move_progress = (animation_progress - move_start) / current_move.duration

		var animation_delta = 1.0 - curve_progress

		var delta_position_rotated = GridUtil.rotate_vec2_by_facing(current_move.delta_position, facing)

		world_pos -= delta_position_rotated * animation_delta * GridUtil.TILE_SIZE
		world_rot -= GridUtil.facing_to_angle(current_move.delta_facing) * animation_delta

		var sprite_offset = Vector2.ZERO
		if current_move.curve_x:
			sprite_offset.x = current_move.curve_x.interpolate(move_progress) * GridUtil.TILE_SIZE

			if current_move.flip_curve_x:
				sprite_offset.x *= -1

		if current_move.curve_y:
			sprite_offset.y = current_move.curve_y.interpolate(move_progress) * GridUtil.TILE_SIZE

			if current_move.flip_curve_y:
				sprite_offset.y *= -1

		if sprite_offset != Vector2.ZERO:
			$Offset/Sprite.position = GridUtil.rotate_vec2_by_facing(sprite_offset, facing)
		else:
			$Offset/Sprite.position = lerp($Offset/Sprite.position, Vector2.ZERO, 0.1)

		if current_move.curve_facing:
			$Offset/Sprite.rotation_degrees = current_move.curve_facing.interpolate(move_progress) * 90

			if current_move.flip_curve_facing:
				$Offset/Sprite.rotation_degrees *= -1
		else:
			$Offset/Sprite.rotation_degrees = lerp($Offset/Sprite.rotation_degrees, 0.0, 0.1)

		# If finished, move to the next motion
		if not animation_progress < motion_duration:
			process_input()

	position = world_pos
	position.x = round(position.x)
	position.y = round(position.y)

	$Offset.rotation_degrees = world_rot
	emit_signal("rotation_changed", world_rot)

func buffer_input(input: String, pressed: bool) -> void:
	input_buffer.append([input, pressed])

	var should_process = false
	if current_motion:
		if current_motion.cancelable and not input in current_motion.lock_inputs:
			should_process = true
	else:
		should_process = true

	if should_process:
		process_input()

func process_input():
	if input_buffer.size() == 0:
		if current_motion:
			if current_motion.next_motion:
				set_motion(current_motion.next_motion)
			elif current_motion.looping:
				set_motion(current_motion)
			else:
				set_motion(null)
		return

	if not moveset:
		set_motion(null)
		return

	var input = input_buffer.front()
	var action = input[0]
	var pressed = input[1]

	if not action in moveset.map:
		set_motion(null)
		return

	var consume_input = false
	var process_next = true
	var set_motion = true
	var motion = null

	if current_motion:
		# Called by end of current motion
		var current_move = get_current_move(motion_progress)
		if pressed:
			if action in current_move.input_press_motions:
				# Pressing a link for the current move
				var press_motion = current_move.input_press_motions[action]
				if press_motion:
					motion = press_motion
					consume_input = true
					process_next = false
			elif not current_motion.lock_input_buffer:
				motion = moveset.map[action] as GridMotion
				consume_input = true
				process_next = false
			else:
				consume_input = true
				process_next = false
				set_motion = false
		else:
			if action in current_move.input_release_motions:
				# Releasing a link for the current move
				var release_motion = current_move.input_release_motions[action]
				if release_motion:
					motion = release_motion
					consume_input = true
					process_next = false
			else:
				# Releasing an irrelevant action
				set_motion = false
				consume_input = true
				process_next = false

	else:
		if pressed:
			# Pressed during idle
			motion = moveset.map[action] as GridMotion
			consume_input = true
			process_next = false
		else:
			# Released during idle
			consume_input = true
			process_next = true

	if set_motion:
		set_motion(motion)

	if consume_input:
		input_buffer.pop_front()

	if process_next:
		process_input()

func set_motion(motion: GridMotion):
	motion_progress = 0.0
	prev_move = null
	prev_move_progress = 0.0

	animation_progress = 0.0
	motion_duration = -1.0

	current_motion = motion
	current_move_dict.clear()

	if current_motion:
		var move_start = -1.0
		var move_end = -1.0
		for move in current_motion.motion_moves:
			if move_start == -1.0:
				move_start = 0.0
			else:
				move_start += move.duration

			if move_end == -1.0:
				move_end = move.duration
			else:
				move_end += move.duration

			current_move_dict[move] = {
				"start": move_start,
				"end": move_end
			}

		motion_duration = move_end
		update_motion()
