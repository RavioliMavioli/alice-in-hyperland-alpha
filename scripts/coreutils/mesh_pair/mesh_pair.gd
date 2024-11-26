class_name MeshPair extends MeshInstance3D

enum GRASS_DIRECTION {NONE, ALL, TOP, BOTTOM, TOP_BOTTOM, LEFT, RIGHT, LEFT_RIGHT}

var polygon_pair: PolygonPair
var face_ammount: int

@export var grass_direction := GRASS_DIRECTION.NONE
@export var mark_static := false:
	set(val):
		if mark_static == val:
			return
		mark_static = val
		PolygonProcessor._clock_function()

func _ready() -> void:
	face_ammount = mesh.get_faces().size()
