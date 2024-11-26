extends Node

var clock: Timer
var clock_speed: float:
	get:
		match Settings.polygon_draw_rate:
			Settings.POLYGON_DRAW_RATE._60FPS:
				return 1.0/60.0
			Settings.POLYGON_DRAW_RATE._30FPS:
				return 1.0/30.0
		return 1.0/15.0

var hyperplane: Hyperplane:
	get: return Hyperplane.instance

func init_clock(parent: Object) -> void:
	if clock != null:
		clock.queue_free()
	clock = Timer.new()
	parent.add_child(clock)
	clock.wait_time = clock_speed
	clock.autostart = false
	clock.one_shot = false
	clock.timeout.connect(_clock_function)

func init_polygon2D(parent: Object) -> void:
	for d in TriangleData.queue_data:
		var polygon: PolygonPair = d["polygon_pair"]
		var mesh: MeshPair = d["mesh_pair"]
		var thread: Thread = d["thread"]
		if polygon == null or mesh == null or thread == null:
			continue
		polygon.mesh_pair = mesh
		polygon.thread_pair = thread
		parent.add_child(polygon)
		polygon.global_position = Vector2(mesh.global_position.x, -mesh.global_position.y) * Constants.METER_TO_PIXEL

func start_polygon_update() -> void:
	if clock != null:
		clock.start()

func stop_polygon_update() -> void:
	if clock != null:
		clock.stop()

func _clock_function(include_static := false) -> void:
	if hyperplane == null:
		return
	for d in TriangleData.queue_data:
		var mesh: MeshPair = d["mesh_pair"]
		var triangles: Array[PackedVector3Array] = d["triangles"]
		var c_triangles: Array[PackedVector3Array] = d["children"]["triangles"]
		var thread: Thread = d["thread"]
		
		if thread == null or triangles == null or mesh == null:
			continue
		if Settings.multi_threaded:
			if thread.is_started():
				thread.wait_to_finish()
			thread.start(func():
				Thread.set_thread_safety_checks_enabled(false)
				_update_vertices(triangles, mesh, c_triangles, include_static)
			)
		else:
			_update_vertices(triangles, mesh, c_triangles, include_static)

func _sort_clockwise(arr: PackedVector2Array) -> PackedVector2Array:
	var center := _centeroid(arr)
	var arr_dict := []
	var fixed_arr := []
	for v in arr:
		var angle = center.angle_to_point(v)
		#if center.distance_to(v) > max_distance:
		#	return []
		arr_dict.append({"angle":angle, "vector": v})
	arr_dict.sort_custom(_sort_atan)
	for v in arr_dict:
		fixed_arr.append(v["vector"])
	return fixed_arr

func _update_vertices(sorted_triangles: Array[PackedVector3Array], mesh_pair: MeshPair, c_triangles: Array[PackedVector3Array], include_static := false) -> void:
	if !mesh_pair.mark_static or include_static:
		mesh_pair.polygon_pair.update_vertices.call_deferred(_calculate_points_from_triangle(sorted_triangles), _calculate_points_from_triangle(c_triangles))

func _calculate_points_from_triangle(sorted_triangles: Array[PackedVector3Array]) -> PackedVector2Array:
	var intersected_triangles := _intersected_triangles(sorted_triangles, hyperplane)
	var vec2_points := _intersection_points(intersected_triangles, hyperplane)
	var sorted_points := _sort_clockwise(vec2_points)
	var new_points := _merge_close_arr(sorted_points)
	return new_points

func _intersected_triangles(triangles: Array[PackedVector3Array], plane: Hyperplane) -> Array[PackedVector3Array]:
	var tmp_tris: Array[PackedVector3Array]
	var z_min: float
	var z_max: float
	var plane_z: float
	
	for t in triangles:
		z_min = t[0].z
		z_max = t[2].z
		plane_z = plane.global_position.z
		if z_min <= plane_z and z_max >= plane_z:
			tmp_tris.append(t)
	return tmp_tris

func _intersection_points(triangles: Array[PackedVector3Array], plane: Hyperplane) -> PackedVector2Array:
	var tmp_vec2: PackedVector2Array
	var vec: Vector3
	var C: float
	var intersect: Vector3
	var prev_p
	var plane_z := plane.global_position.z
	var i := 0
	var dist: float
	for t in triangles:
		prev_p = null
		for j in range(t.size() + 1):
			i = j if j < t.size() else 0
			if prev_p == null:
				prev_p = t[i]
				continue
			vec = prev_p - t[i]
			C = (plane_z - prev_p.z) / vec.z
			intersect = Vector3(
				prev_p.x + (vec.x * C),
				prev_p.y + (vec.y * C),
				prev_p.z + (vec.z * C)
			)
			prev_p = t[i]
			dist = prev_p.distance_to(intersect) + intersect.distance_to(t[i])
			if abs(dist - prev_p.distance_to(t[i])) < Constants.TOLERANCE:
				tmp_vec2.append(Vector2(intersect.x, -intersect.y) * Constants.METER_TO_PIXEL)
	
	return tmp_vec2

func _merge_close_arr(arr: PackedVector2Array, tolerance := Constants.DIST_TOLERANCE) -> PackedVector2Array:
	var new_arr: PackedVector2Array
	var prev_v: Vector2
	for v in arr:
		if prev_v == null:
			prev_v = v
			continue
		if v.distance_to(prev_v) >= Constants.DIST_TOLERANCE:
			new_arr.append(v)
			prev_v = v
	return new_arr

func _centeroid(arr: PackedVector2Array) -> Vector2:
	var center := Vector2.ZERO
	for v in arr:
		center += v
	center /= arr.size()
	return center

func _sort_atan(a, b):
	if a["angle"] < b["angle"]:
		return true
	return false
