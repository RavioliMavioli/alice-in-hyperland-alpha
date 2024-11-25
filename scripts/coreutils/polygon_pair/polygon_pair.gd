class_name PolygonPair extends Polygon2D

var mesh_pair: MeshPair
var thread_pair: Thread
var has_children := false
var new_pol: PackedVector2Array

@onready var line := %Line
@onready var collision := %Collision
@onready var grass_generator := %GrassGenerator

func _ready() -> void:
	global_position = Vector2(mesh_pair.global_position.x, mesh_pair.global_position.y) * Constants.METER_TO_PIXEL

func update_vertices(arr: PackedVector2Array, child_arr: PackedVector2Array) -> void:
	if !child_arr.is_empty() and !Geometry2D.clip_polygons(arr, child_arr).is_empty():
		new_pol = Geometry2D.clip_polygons(arr, child_arr)[0]
	else:
		new_pol = arr
	if !Settings.multi_threaded:
		_thread_function(arr, child_arr)
		return
	if thread_pair.is_started():
		thread_pair.wait_to_finish()
	thread_pair.start(func():
		thread_pair.set_thread_safety_checks_enabled(false)
		_thread_function(arr, child_arr)
	)
	grass_generator.pass_vertices(new_pol, mesh_pair)

func _thread_function(arr: PackedVector2Array, child_arr: PackedVector2Array) -> void:
	if arr.is_empty() or arr == null:
		_empty_polygon()
		hide()
		return
	if Geometry2D.triangulate_polygon(arr).is_empty():
		return
	if new_pol.is_empty():
		return
	polygon = new_pol
	line.points = new_pol
	collision.polygon = new_pol
	show()
func _empty_polygon() -> void:
	polygon = []
	line.points = []
	collision.polygon = []
