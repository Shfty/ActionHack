class_name GridEntity
extends Node2D

export(Texture) var sprite_texture := preload("res://textures/player.png") as Texture setget set_sprite_texture
export(int) var x = 0 setget set_x
export(int) var y = 0 setget set_y
export(GridUtil.Facing) var facing = GridUtil.Facing.NORTH setget set_facing
export(float) var opacity = 1.0
export(bool) var solid = true

var _sprite = null

func _ready():
	get_sprite()
	update_position_x()
	update_position_y()

# Setters
func set_sprite_texture(new_sprite_texture: Texture) -> void:
	if sprite_texture != new_sprite_texture:
		sprite_texture = new_sprite_texture

	update_sprite_texture(get_sprite())

func set_x(new_x: int):
	if x != new_x:
		x = new_x

		if Engine.is_editor_hint():
			update_position_x()

func set_y(new_y: int):
	if y != new_y:
		y = new_y

		if Engine.is_editor_hint():
			update_position_y()

func set_facing(new_facing: int) -> void:
	if facing != new_facing:
		facing = new_facing

		if Engine.is_editor_hint():
			rotation = deg2rad(GridUtil.facing_to_angle(facing))

# Utility
func update_position_x():
		position.x = x * GridUtil.TILE_SIZE

func update_position_y():
		position.y = y * GridUtil.TILE_SIZE

func update_sprite_texture(sprite: Sprite):
	sprite.texture = sprite_texture

func get_sprite() -> Sprite:
	if _sprite == null:
		_sprite = Sprite.new()
		update_sprite_texture(_sprite)
		add_child(_sprite)

	for child in get_children():
		if child == _sprite:
			continue

		if child is Sprite:
			remove_child(child)
			child.queue_free()

	return _sprite

func get_world() -> Node2D:
	return get_parent() as Node2D
