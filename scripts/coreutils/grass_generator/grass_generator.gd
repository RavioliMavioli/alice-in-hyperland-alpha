extends Node

@export var grass_shader: Shader
@export var textures: Array[Texture2D]

var grass_thread := Thread.new()
var queue_grass: Array[Sprite2D]
var tween_duration: float:
	get:
		match Settings.polygon_draw_rate:
			Settings.POLYGON_DRAW_RATE._60FPS:
				return 0.1
			Settings.POLYGON_DRAW_RATE._30FPS:
				return 0.075
		return 0.05

func pass_vertices(arr: PackedVector2Array, mesh_pair: MeshPair) -> void:
	if queue_grass.is_empty():
		_init_grass(mesh_pair)
	if !Settings.multi_threaded:
		_add_grass(arr)
		return
	if grass_thread.is_started():
		grass_thread.wait_to_finish()
	grass_thread.start(func():
		grass_thread.set_thread_safety_checks_enabled(false)
		_add_grass(arr)
	)
		
func _init_grass(mesh_pair: MeshPair) -> void:
	var size := int(mesh_pair.mesh.get_faces().size() / 128)
	for i in range(size):
		var new_g := _create_new_grass(owner)
		_set_grass_material(new_g, grass_shader)
		
func _remove_grass() -> void:
	for g in queue_grass:
		if g == null:
			continue
		if !g.is_queued_for_deletion():
			g.queue_free()

func _add_grass(arr: PackedVector2Array) -> void:
	var indx: int
	var angle: float
	var j: int
	for i in range(arr.size()):
		if i >= queue_grass.size():
			return
		j = i + 1 if i + 1 < arr.size() else 0
		queue_grass[i].show()
		_create_grass_tween.call_deferred(queue_grass[i], arr[i], arr[j])
		indx = i
	if indx <= queue_grass.size():
		for i in range(indx, queue_grass.size()):
			queue_grass[i].hide()

func _create_new_grass(parent: Object) -> Sprite2D:
	var rng := randf_range(0.3, 0.8)
	var new_g := Sprite2D.new()
	
	parent.add_child.call_deferred(new_g)
	
	queue_grass.append(new_g)
	new_g.hide()
	
	new_g.texture = textures[randi_range(0, textures.size() - 1)]
	new_g.offset.y = - new_g.texture.get_size().y / 2
	new_g.scale = Vector2(rng, rng)
	new_g.modulate.a = rng - 0.1
	new_g.flip_h = randi_range(0,1)
	
	return new_g

func _set_grass_material(node: Sprite2D, shader: Shader) -> void:
	var new_mat := ShaderMaterial.new()
	var rng_strength := randf_range(0.03, 0.2)
	var rng_speed := randf_range(1.0, 3.0)
	new_mat.shader = shader
	new_mat.set_shader_parameter("minStrength", 0.01)
	new_mat.set_shader_parameter("maxStrength", rng_strength)
	new_mat.set_shader_parameter("speed", rng_speed)
	node.material = new_mat

func _create_grass_tween(grass: Sprite2D, arr_pos: Vector2, next_arr_pos: Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(grass, "global_position", arr_pos + owner.global_position, tween_duration)
	tween.tween_property(grass, "global_rotation", arr_pos.angle_to_point(next_arr_pos), tween_duration)
