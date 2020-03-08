class_name MovesetEditorInspectorGadget
extends InspectorGadget

func set_moveset_motions(motions: Array) -> void:
	resource_gadget_metadata['grid_motions'] = motions

func set_ignore_motion(motion: GridMotion) -> void:
	resource_gadget_metadata['grid_motions_ignore'] = [motion]
