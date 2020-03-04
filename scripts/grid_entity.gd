class_name GridEntity
extends Node2D

export(Texture) var sprite_texture := preload("res://textures/tiles/player.png") as Texture setget set_sprite_texture
export(int) var x = 0 setget set_x
export(int) var y = 0 setget set_y
export(GridUtil.Facing) var facing = GridUtil.Facing.NORTH setget set_facing
export(float) var opacity = 1.0
export(bool) var solid = true

func _ready():
	var offset = null
	if has_node("Offset"):
		offset = $Offset
	else:
		offset = Node2D.new()
		offset.name = "Offset"
		var half_tile = GridUtil.TILE_SIZE * 0.5
		offset.position = Vector2(half_tile, half_tile)
		add_child(offset)

	var sprite = null
	if offset.has_node("Sprite"):
		sprite = offset.get_node("Sprite")
	else:
		sprite = Sprite.new()
		sprite.name = "Sprite"
		offset.add_child(sprite)

	var tree = get_tree()
	if tree:
		var edited_scene_root = tree.get_edited_scene_root()
		if edited_scene_root:
			offset.set_owner(edited_scene_root)
			sprite.set_owner(edited_scene_root)

	update_position_x()
	update_position_y()
	update_sprite_texture()

# Setters
func set_sprite_texture(new_sprite_texture: Texture) -> void:
	if sprite_texture != new_sprite_texture:
		sprite_texture = new_sprite_texture

func set_x(new_x: int, update: bool = false):
	if x != new_x:
		x = new_x

		if Engine.is_editor_hint() || update:
			update_position_x()

func set_y(new_y: int, update: bool = false):
	if y != new_y:
		y = new_y

		if Engine.is_editor_hint() || update:
			update_position_y()

func set_facing(new_facing: int, update: bool = false) -> void:
	if facing != new_facing:
		facing = new_facing

		if Engine.is_editor_hint() || update:
			set_rotation(GridUtil.facing_to_angle(facing))

func set_rotation(new_rotation: float) -> void:
	$Offset.rotation_degrees = new_rotation

# Utility
func update_position_x():
	position.x = x * GridUtil.TILE_SIZE

func update_position_y():
	position.y = y * GridUtil.TILE_SIZE

func update_sprite_texture():
	$Offset/Sprite.texture = sprite_texture

func get_world() -> Node2D:
	return get_parent() as Node2D
