class_name TextureSubregionRect
extends Control
tool

export(Texture) var texture
export(Vector2) var offset

func _process(delta: float) -> void:
	update()

func _draw():
	draw_texture_rect_region(texture, Rect2(Vector2.ZERO, rect_size), Rect2(offset, rect_size))
