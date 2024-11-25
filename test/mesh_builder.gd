extends Node

func build_mesh(triangles: Array[PackedVector3Array], offset: Vector3 = Vector3.ZERO) -> void:
	var new_obj := MeshInstance3D.new()
	var new_mesh := Mesh.new()
	var st = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for t in triangles:
		for p in t:
			st.set_normal(Vector3(0, 0, 1))
			st.set_uv(Vector2(0, 0))
			# Call last for each vertex, adds the above attributes.
			st.add_vertex(p)

# Commit to a mesh.
	new_mesh = st.commit()
	new_obj.mesh = new_mesh
	owner.add_child(new_obj)
	new_obj.global_position = offset
