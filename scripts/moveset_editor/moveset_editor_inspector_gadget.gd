class_name MovesetEditorInspectorGadget
extends InspectorGadget

func set_moveset_motions(motions: Array) -> void:
	var motion_names := []
	for motion in motions:
		motion_names.append(motion.get_name())

	custom_gadget_metadata['grid_motion_names'] = motion_names
