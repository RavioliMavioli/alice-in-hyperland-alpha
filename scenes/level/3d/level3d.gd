class_name Level3D extends Node3D

static var instance: Level3D

func _init() -> void:
	instance = self
	
var meshes: Array:
	get:
		var queue = %Dynamic.get_children()
		queue.append_array(%Static.get_children())
		return queue

func _ready() -> void:
	_init_meshes.call_deferred()

func _init_meshes() -> void:
	MeshGenerator.clear_all_data()
	MeshGenerator.append_all_csg(%Dynamic)
	MeshGenerator.append_all_csg(%Static)
	MeshGenerator.generate_mesh_instances()

	TriangleData.load_all_meshes(meshes)
	for c in %Static.get_children():
		if c is MeshPair:
			c.mark_static = true
