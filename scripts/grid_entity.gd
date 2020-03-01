class_name GridEntity
extends Node2D

export(Texture) var sprite_texture := preload("res://textures/player.png") as Texture setget set_sprite_texture
export(int) var x = 0 setget set_x
export(int) var y = 0 setget set_y
export(GridUtil.Facing) var facing = GridUtil.Facing.NORTH setget set_facing
export(float) var opacity = 1.0
export(bool) var solid = true

# Setters
func set_sprite_texture(new_sprite_texture: Texture) -> void:
	if sprite_texture != new_sprite_texture:
		sprite_texture = new_sprite_texture
	update_sprite_texture()

func set_x(new_x: int):
	if x != new_x:
		x = new_x
		update_position_x()


func set_y(new_y: int):
	if y != new_y:
		y = new_y
		update_position_y()

func set_facing(new_facing: int) -> void:
	if facing != new_facing:
		facing = new_facing
		rotation = deg2rad(GridUtil.facing_to_angle(facing))

# Utility
func update_position_x():
		position.x = x * GridUtil.TILE_SIZE

func update_position_y():
		position.y = y * GridUtil.TILE_SIZE

func update_sprite_texture():
	for child in get_children():
		if child is Sprite:
			remove_child(child)
			child.queue_free()

	var sprite = Sprite.new()
	sprite.position = Vector2(0, 0)
	sprite.texture = sprite_texture
	add_child(sprite)

func get_world() -> Node2D:
	return get_parent() as Node2D
