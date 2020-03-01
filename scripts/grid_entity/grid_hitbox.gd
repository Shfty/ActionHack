class_name GridHitbox
extends GridEntity
tool

var initial_duration := -1.0
var duration := -1.0
var damage := 0
var hit := false

func init(params: Array):
	duration = params[0] as float
	damage = params[1] as int
	initial_duration = duration
	solid = false

func _ready():
	set_sprite_texture(preload("res://textures/hitbox.png"))

func _process(delta: float) -> void:
	var progress = duration / initial_duration
	opacity = progress

	if not hit:
		for sibling in get_parent().get_children():
			if sibling == self or not sibling is GridActor:
				continue

			if sibling.x == x and sibling.y == y:
				if sibling.has_method('take_damage'):
					sibling.take_damage(damage)
				hit = true
				break

	duration = max(duration - delta, 0)
	if duration <= 0:
		var parent = get_parent()
		parent.remove_child(self)
		queue_free()
