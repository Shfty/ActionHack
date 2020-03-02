class_name GridHitbox
extends GridEntity
tool

var initial_duration := -1.0
var duration := -1.0
var damage := 0
var damage_motion: GridMotion = null
var hit := false

func init(params: Array):
	duration = params[0] as float
	initial_duration = duration

	damage = params[1] as int

	if params.size() > 2:
		damage_motion = params[2] as GridMotion

	solid = false

func _ready():
	._ready()
	set_sprite_texture(preload("res://textures/hitbox.png"))

func _process(delta: float) -> void:
	var progress = duration / initial_duration
	opacity = progress

	if not hit:
		for sibling in get_parent().get_children():
			if sibling == self:
				continue

			if not sibling is GridActor:
				continue

			if sibling.x != x or sibling.y != y:
				continue

			if sibling.has_method('take_damage'):
				var motion = null
				if damage_motion:
					motion = damage_motion.duplicate()
					for i in range(0, motion.motion_moves.size()):
						var move_mod = motion.motion_moves[i].duplicate()
						move_mod.delta_position = GridUtil.rotate_vec2_by_facing(move_mod.delta_position, facing)
						motion.motion_moves[i] = move_mod
				sibling.take_damage(damage, motion)

			hit = true
			break

	duration = max(duration - delta, 0)
	if duration <= 0:
		var parent = get_parent()
		parent.remove_child(self)
		queue_free()
