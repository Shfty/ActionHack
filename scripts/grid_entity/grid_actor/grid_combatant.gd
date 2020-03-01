class_name GridCombatant
extends GridActor
tool

signal health_changed(health)
signal damage_taken(damage)
signal hitstun_triggered(duration)

export(int) var health = 5 setget set_health
export(int) var hitstun_threshold = 1
export(float) var hitstun_recovery_rate = 0.5
export(float) var hitstun_duration = 0.2

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

func take_damage(damage: int) -> void:
	emit_signal("damage_taken", damage)

	hitstun_armor -= damage
	if hitstun_armor <= 0:
		hitstun()

	set_health(health - damage)

func hitstun() -> void:
	emit_signal("hitstun_triggered", hitstun_duration)
	hitstun_armor = hitstun_threshold

func die() -> void:
	get_parent().remove_child(self)
	queue_free()
