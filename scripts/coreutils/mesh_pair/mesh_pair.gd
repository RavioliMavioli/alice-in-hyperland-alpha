class_name MeshPair extends MeshInstance3D

var polygon_pair: PolygonPair

@export var mark_static := false:
	set(val):
		if mark_static == val:
			return
		mark_static = val
		PolygonProcessor._clock_function()
