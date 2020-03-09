class_name GridMoveset
extends Resource
tool

export(Dictionary) var input_map := {
	"move_forward": Object(),
	"move_back": Object(),
	"move_left": Object(),
	"move_right": Object(),
	"turn_left": Object(),
	"turn_right": Object(),
	"quickturn_left": Object(),
	"quickturn_right": Object(),
	"attack": Object(),

	"special_move_forward": Object(),
	"special_move_back": Object(),
	"special_move_left": Object(),
	"special_move_right": Object(),
	"special_turn_left": Object(),
	"special_turn_right": Object(),
	"special_quickturn_left": Object(),
	"special_quickturn_right": Object(),
	"special_attack": Object(),
} setget set_input_map

export(Array, Resource) var motions := [] setget set_motions

# Setters
func set_input_map(new_input_map: Dictionary) -> void:
	if input_map != new_input_map:
		input_map = new_input_map

		for key in input_map:
			if not input_map[key]:
				input_map[key] = Object()

func set_motions(new_motions: Array) -> void:
	if motions != new_motions:
		motions = new_motions

		for i in range(0, motions.size()):
			if motions[i] == null:
				motions[i] = GridMotion.new()
