extends Node

signal all_mesh_ready

var queue_combiner := [{
		"parent": null,
		"csg_pair": null,
	}
]

func clear_all_data() -> void:
	queue_combiner.resize(0)

func append_all_csg(csg_parent: Node3D) -> void:
	var childs := csg_parent.get_children()
	for c in childs:
		if c is not CSGCombiner:
			continue
		add_combiner(c)

func add_combiner(csg: CSGCombiner) -> void:
	var mesh_data := csg.get_meshes()
	if mesh_data == null or mesh_data.is_empty():
		return
	queue_combiner.append({
		"parent": csg.get_parent(),
		"csg_pair": csg
	})

func generate_mesh_instances() -> void:
	for q in queue_combiner:
		var csg: CSGCombiner = q["csg_pair"]
		var parent: Node3D = q["parent"]
		if csg.get_meshes().is_empty():
			continue
			
		var mesh_instance := MeshPair.new()
		var csg_mesh = csg.get_meshes()[1]
		parent.add_child(mesh_instance)
		mesh_instance.mesh = csg_mesh
		mesh_instance.transform = csg.transform
		mesh_instance.material_override = csg.material_override
		
		mesh_instance.face_ammount = csg_mesh.get_faces().size()
		mesh_instance.grass_direction = csg.grass_direction
		mesh_instance.use_legacy_polygon_sorter = csg.use_legacy_polygon_sorter
		mesh_instance.mark_static = csg.mark_static
		mesh_instance.polygon_texture = csg.polygon_texture
		mesh_instance.polygon_color = csg.polygon_color
		mesh_instance.disable_shadow = csg.disable_shadow
		mesh_instance.disable_line = csg.disable_line
		mesh_instance.line_width = csg.line_width
		mesh_instance.line_texture = csg.line_texture
		mesh_instance.line_color = csg.line_color
		mesh_instance.line_profile = csg.line_profile
		q["csg_pair"] = null
		csg.queue_free.call_deferred()
	all_mesh_ready.emit()
	clear_all_data()
