class_name PolygonPair extends Polygon2D

const SHADOW_SIZE := 10.0

var mesh_pair: MeshPair
var thread_pair: Thread
var offset_pol: PackedVector2Array
var occluder_pol := OccluderPolygon2D.new()
var subviewport_polygon_pair := Polygon2D.new()

@onready var line := %Line
@onready var shadow := %Shadow
@onready var collision := %Collision
@onready var grass_generator := %GrassGenerator
@onready var occluder := %Occluder

func _ready() -> void:
	global_position = Vector2(mesh_pair.global_position.x, mesh_pair.global_position.y) * Constants.METER_TO_PIXEL
	occluder.occluder = occluder_pol
	_setup_shadow()
	_setup_line()

func update_vertices(arr: PackedVector2Array) -> void:
	if mesh_pair == null:
		return
	_update_polygon(arr)
	grass_generator.pass_vertices(arr, mesh_pair, thread_pair)

func _update_polygon(arr: PackedVector2Array) -> void:
	if arr.is_empty() or arr == null:
		_empty_polygon()
		hide()
		return
	if Geometry2D.triangulate_polygon(arr).is_empty():
		return
	if !Geometry2D.offset_polygon(arr,-SHADOW_SIZE).is_empty():
		offset_pol = Geometry2D.offset_polygon(arr,-SHADOW_SIZE)[0]
	if !mesh_pair.disable_shadow:
		shadow.uv = offset_pol
		shadow.polygon = offset_pol
	uv = arr
	polygon = arr
	line.points = arr
	collision.polygon = arr
	occluder_pol.polygon = arr
	collision.disabled = false
	show()

func _empty_polygon() -> void:
	if !mesh_pair.disable_shadow:
		shadow.uv.resize(0)
		shadow.polygon.resize(0)
	uv.resize(0)
	polygon.resize(0)
	line.points.resize(0)
	collision.polygon.resize(0)
	occluder_pol.polygon.resize(0)
	collision.disabled = true

func _setup_shadow() -> void:
	if mesh_pair.disable_shadow:
		shadow.queue_free()

func _setup_line() -> void:
	if mesh_pair.disable_line:
		line.queue_free()
	else:
		line.width = mesh_pair.line_width
		line.texture = mesh_pair.line_texture
		line.width_curve = mesh_pair.line_profile
		line.default_color = mesh_pair.line_color
