class_name PolygonPair extends Polygon2D

var mesh_pair: MeshPair
var thread_pair: Thread
var has_children := false
var new_pol: PackedVector2Array
var occluder_pol := OccluderPolygon2D.new()

@onready var line := %Line
@onready var collision := %Collision
@onready var grass_generator := %GrassGenerator
@onready var occluder := %Occluder

func _ready() -> void:
	global_position = Vector2(mesh_pair.global_position.x, mesh_pair.global_position.y) * Constants.METER_TO_PIXEL
	occluder.occluder = occluder_pol

func update_vertices(arr: PackedVector2Array, child_arr: PackedVector2Array) -> void:
	if !child_arr.is_empty() and !Geometry2D.clip_polygons(arr, child_arr).is_empty():
		new_pol = Geometry2D.clip_polygons(arr, child_arr)[0]
	else:
		new_pol = arr
	_update_polygon(new_pol)
	grass_generator.pass_vertices(new_pol, mesh_pair, thread_pair)

func _update_polygon(arr: PackedVector2Array) -> void:
	if arr.is_empty() or arr == null:
		_empty_polygon()
		hide()
		return
	if Geometry2D.triangulate_polygon(arr).is_empty():
		return
	if new_pol.is_empty():
		return
	show()
	polygon = new_pol
	uv = new_pol
	line.points = new_pol
	collision.polygon = new_pol
	occluder_pol.polygon = new_pol
	collision.disabled = false

func _empty_polygon() -> void:
	polygon.resize(0)
	uv.resize(0)
	line.points.resize(0)
	collision.polygon.resize(0)
	occluder_pol.polygon.resize(0)
	collision.disabled = true
