class_name InspectorGadgetBaseUtil

static func is_array_type(value) -> bool:
	var is_array = false
	is_array = is_array or value is Array
	is_array = is_array or value is PoolByteArray
	is_array = is_array or value is PoolColorArray
	is_array = is_array or value is PoolIntArray
	is_array = is_array or value is PoolRealArray
	is_array = is_array or value is PoolStringArray
	is_array = is_array or value is PoolVector2Array
	is_array = is_array or value is PoolVector3Array
	return is_array
