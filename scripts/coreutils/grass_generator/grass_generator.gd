extends Node

@export var grass_shader: Shader
@export var textures: Array[Texture2D]
@export var grass_script: GDScript

var initialized := false
var queue_grass: Array[Sprite2D]
var tween_duration: float:
	get:
		match Settings.polygon_draw_rate:
			Settings.POLYGON_DRAW_RATE._60FPS:
				return 0.12
			Settings.POLYGON_DRAW_RATE._30FPS:
				return 0.08
		return 0.05

func pass_vertices(arr: PackedVector2Array, mesh_pair: MeshPair, thread: Thread = null) -> void:
	if mesh_pair.grass_direction == mesh_pair.GRASS_DIRECTION.NONE:
		return
	if initialized and mesh_pair.mark_static:
		return
	if queue_grass.is_empty():
		_init_grass(mesh_pair)
	if !Settings.multi_threaded:
		_add_grass(arr, mesh_pair)
		return
	if thread == null:
		return
	if thread.is_started():
		thread.wait_to_finish()
	thread.start(func():
		Thread.set_thread_safety_checks_enabled(false)
		_add_grass(arr, mesh_pair)
	)
	initialized = true

func _init_grass(mesh_pair: MeshPair) -> void:
	@warning_ignore("integer_division") 
	var size := int(mesh_pair.face_ammount / 128)
	for i in range(size):
		var new_g := _create_new_grass(owner)
		_set_grass_material(new_g, grass_shader)
		
func _remove_grass() -> void:
	for g in queue_grass:
		if g == null:
			continue
		if !g.is_queued_for_deletion():
			g.queue_free()

func _add_grass(arr: PackedVector2Array, mesh_pair: MeshPair) -> void:
	var indx: int
	var angle: float
	var allowed_angle: float
	var j: int
	for i in range(arr.size()):
		if i >= queue_grass.size():
			return
		j = i + 1 if i + 1 < arr.size() else 0
		angle = arr[i].angle_to_point(arr[j])
		match mesh_pair.grass_direction:
			mesh_pair.GRASS_DIRECTION.ALL:
				allowed_angle = 360
			mesh_pair.GRASS_DIRECTION.TOP:
				allowed_angle = 0
			mesh_pair.GRASS_DIRECTION.BOTTOM:
				allowed_angle = 180
			mesh_pair.GRASS_DIRECTION.LEFT:
				allowed_angle = -90
			mesh_pair.GRASS_DIRECTION.RIGHT:
				allowed_angle = 90
		if rad_to_deg(angle) > - (allowed_angle + 10.0) and rad_to_deg(angle) < allowed_angle + 10.0:
			_toggle_grass(queue_grass[i], true)
			_create_grass_tween(queue_grass[i], arr[i], arr[j])
		else:
			_toggle_grass(queue_grass[i], false)
		indx = i
	_clear_unused_grass.call_deferred(indx, mesh_pair)

func _clear_unused_grass(indx: int, mesh_pair: MeshPair) -> void:
	if indx <= queue_grass.size():
		for i in range(indx, queue_grass.size()):
			if mesh_pair.mark_static:
				queue_grass[i].queue_free()
				continue
			_toggle_grass(queue_grass[i], false)
	if mesh_pair.mark_static:
		_clean_nulls(queue_grass)

func _create_new_grass(parent: Object) -> Sprite2D:
	var rng := randf_range(0.3, 0.8)
	var new_g := Sprite2D.new()
	
	new_g.set_script(grass_script)
	queue_grass.append(new_g)
	new_g.hide()
	
	new_g.texture = textures[randi_range(0, textures.size() - 1)]
	new_g.offset.y = - new_g.texture.get_size().y / 2
	new_g.scale = Vector2(rng, rng)
	new_g.modulate.a = rng - 0.1
	new_g.flip_h = randi_range(0,1)
	parent.add_child.call_deferred(new_g)
	
	new_g.set_meta("modulation", new_g.modulate.a)
	
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
	node.set_meta("default_shader_param",Vector3(rng_speed, 0.01, rng_strength))

func _create_grass_tween(grass: Sprite2D, arr_pos: Vector2, next_arr_pos: Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(grass, "global_position", arr_pos + owner.global_position, tween_duration)
	#tween.tween_property(grass, "global_rotation", arr_pos.angle_to_point(next_arr_pos), tween_duration)
	grass.global_rotation = arr_pos.angle_to_point(next_arr_pos)

func _toggle_grass(grass: Sprite2D, enable: bool) -> void:
	if grass.visible == enable:
		return
	if enable:
		var default_mod := 0.0
		var tween := get_tree().create_tween()
		if grass.has_meta("modulation"):
			default_mod = grass.get_meta("modulation")
		grass.modulate.a = 0.0
		tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(grass, "modulate:a", default_mod, tween_duration)
	grass.visible = enable
	grass.set_physics_process(enable)
	
func _clean_nulls(arr: Array) -> void:
	for i in range(arr.size()):
		if arr[i] == null:
			arr.remove_at(i)
