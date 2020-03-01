class_name GridUI
extends Control

func get_compass() -> Compass:
	return $VBoxContainer/HBoxContainer/Compass as Compass

func get_health_bar() -> ProgressBar:
	return $VBoxContainer/HBoxContainer2/ProgressBar as ProgressBar

func set_compass_angle(angle: float) -> void:
	var compass := get_compass()
	if compass:
		compass.set_angle(angle)

func set_health(health: int) -> void:
	var health_bar = get_health_bar()
	if health_bar:
		health_bar.set_value(health)
