class_name GridCombatant
extends GridActor
tool

signal health_changed(health)
signal damage_taken(damage)
signal hitstun_triggered(duration)

export(int) var health = 5 setget set_health
export(int) var hitstun_threshold = 1
export(float) var hitstun_recovery_rate = 0.5

onready var hitstun_armor: int = hitstun_threshold
var hitstun_recovery_progress := 0.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if hitstun_armor < hitstun_threshold:
		hitstun_recovery_progress += delta * hitstun_recovery_rate
		if hitstun_recovery_progress >= 1.0:
			hitstun_armor = hitstun_armor + 1
			hitstun_recovery_progress = 0.0

func set_health(new_health: int) -> void:
	if health != new_health:
		health = new_health
		emit_signal("health_changed", health)
		if health <= 0:
			die()

func take_damage(damage: int, damage_motion: GridMotion = null) -> void:
	emit_signal("damage_taken", damage)

	hitstun_armor -= damage
	if hitstun_armor <= 0:
		hitstun(damage_motion)

	set_health(health - damage)

func hitstun(motion: GridMotion) -> void:
	hitstun_armor = hitstun_threshold
	if motion:
		var motion_mod = motion.duplicate()
		for i in range(0, motion_mod.motion_moves.size()):
			var move_mod = motion_mod.motion_moves[i].duplicate()
			move_mod.delta_position = GridUtil.rotate_vec2_by_facing(move_mod.delta_position, -facing)
			motion_mod.motion_moves[i] = move_mod
		set_motion(current_moveset, motion_mod)
	else:
		set_motion(current_moveset, preload("res://resources/grid_motion/basic/hitstun.tres"))

	var check_motion = current_motion
	var duration = 0.0
	while true:
		if not check_motion:
			break

		duration += check_motion.get_duration()
		check_motion = moveset.get_motion(check_motion.next_motion_idx)

	emit_signal("hitstun_triggered", duration)

func die() -> void:
	get_parent().remove_child(self)
	queue_free()
