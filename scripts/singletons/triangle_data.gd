extends Node

var polygon_scene: PackedScene = preload("res://scripts/coreutils/polygon_pair/polygon_pair.tscn")

var queue_data := [{
	"mesh_pair": null,
	"triangles": null,
	"polygon_pair": null,
	"thread": null,
	"children":{
		"mesh_pair": null,
		"triangles": null
	}
}]

func reset_data() -> void:
	queue_data = []

func load_all_meshes(meshes: Array) -> void:
	## Heavy function, must not be executed in the game loop
	TriangleData.reset_data()
	for n in meshes:
		if n is MeshPair and n != null:
			TriangleData.add_mesh(n)
			#_remove_mesh(n)

func add_mesh(mesh: MeshPair) -> void:
	## Heavy function, must not be executed in the game loop
	var triangles := _triangles_from_mesh(mesh)
	var sorted_triangles := _sort_triangle_by_z(triangles)
	var polygon_pair: PolygonPair = polygon_scene.instantiate()
	var c_mesh: MeshPair
	var c_triangles: Array[PackedVector3Array]
	var c_sorted_triangles: Array[PackedVector3Array]
	mesh.polygon_pair = polygon_pair
	
	if mesh.get_children().size() != 0 and mesh.get_child(0) is MeshPair:
		c_mesh = mesh.get_child(0)
		c_triangles = _triangles_from_mesh(c_mesh, c_mesh.global_position - mesh.global_position)
		c_sorted_triangles = _sort_triangle_by_z(c_triangles)
		polygon_pair.has_children = true
	
	queue_data.append({
		"mesh_pair": mesh,
		"triangles": sorted_triangles,
		"polygon_pair": polygon_pair,
		"thread": Thread.new(),
		"children":{
			"mesh_pair": c_mesh,
			"triangles": c_sorted_triangles,
		}
	})

func _triangles_from_mesh(mesh: MeshPair, offset := Vector3.ZERO) -> Array[PackedVector3Array]:
	var triangles: PackedVector3Array = mesh.mesh.get_faces()
	var sets_of_triangles: Array[PackedVector3Array]
	var tmp_triangle: PackedVector3Array
	var new_p: Vector3
	var i := 0
	
	for p in triangles:
		new_p = _rotate(p, mesh)
		new_p = _scale(new_p, mesh)
		new_p += offset
		tmp_triangle.append(new_p)
		i += 1
		if i >= 3:
			sets_of_triangles.append(tmp_triangle)
			tmp_triangle = []
			i = 0
	return sets_of_triangles
	
func _sort_triangle_by_z(triangles: Array[PackedVector3Array]) -> Array[PackedVector3Array]:
	var tmp_tris: Array[PackedVector3Array]
	var tris: Array[Vector3]
	for t: PackedVector3Array in triangles:
		tris = []
		for y in t:
			tris.append(y)
		tris.sort_custom(_sort_custom_by_z)
		tmp_tris.append(tris as PackedVector3Array)
	return tmp_tris

func _sort_custom_by_z(a: Vector3, b: Vector3):
	return a.z < b.z

func _remove_mesh(mesh: MeshPair) -> void:
	mesh.mesh = null

func _scale(point: Vector3, mesh: MeshPair) -> Vector3:
	return point * mesh.scale

func _rotate(point: Vector3, mesh: MeshPair) -> Vector3:
	var new_p := point.rotated(Vector3(1,0,0), mesh.global_rotation.x)
	new_p = new_p.rotated(Vector3(0,1,0), mesh.global_rotation.y)
	new_p = new_p.rotated(Vector3(0,0,1), mesh.global_rotation.z)
	return new_p
	
