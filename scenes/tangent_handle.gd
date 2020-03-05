class_name DraggableRect
extends ColorRect

signal dragged()

var pressed = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		pressed = event.pressed
	elif event is InputEventMouseMotion:
		if pressed:
			rect_position += event.relative
			emit_signal("dragged")
