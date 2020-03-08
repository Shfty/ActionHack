class_name GadgetResource
extends InspectorGadgetBase
tool

var metadata := {}

func _init(in_node_path: NodePath = NodePath(), in_subnames: String = "", in_metadata: Dictionary = {}).(in_node_path, in_subnames):
	metadata = in_metadata
