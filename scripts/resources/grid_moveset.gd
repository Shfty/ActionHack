class_name GridMoveset
extends Resource
tool

export(Dictionary) var input_map := {
	"move_forward": -1,
	"move_back": -1,
	"move_left": -1,
	"move_right": -1,
	"turn_left": -1,
	"turn_right": -1,
	"quickturn_left": -1,
	"quickturn_right": -1,
	"attack": -1,

	"special_move_forward": -1,
	"special_move_back": -1,
	"special_move_left": -1,
	"special_move_right": -1,
	"special_turn_left": -1,
	"special_turn_right": -1,
	"special_quickturn_left": -1,
	"special_quickturn_right": -1,
	"special_attack": -1
}

export(Array, Resource) var motions := []
