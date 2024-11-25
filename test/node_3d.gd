extends Node3D

var meshes: Array:
	get:
		var queue = %Dynamic.get_children()
		queue.append_array(%Static.get_children())
		return queue

func _ready() -> void:
	TriangleData.load_all_meshes(meshes)
	for c in %Static.get_children():
		if c is MeshPair:
			c.mark_static = true
