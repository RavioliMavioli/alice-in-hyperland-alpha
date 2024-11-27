extends Sprite2D

const SWAY_DUR := 2.0
const PLAYER_VEL_TO_SWAY := 199.0

var time := 0.0
var physics_querry := PhysicsPointQueryParameters2D.new()
var collided_area: Area2D
var tween: Tween

func _ready() -> void:
	physics_querry.collide_with_areas = true
	physics_querry.collide_with_bodies = false
	physics_querry.collision_mask = _set_collision_mask([3])

func _physics_process(delta: float) -> void:
	_set_shader(delta)
	_physics_querry()
	
func _set_shader(delta: float) -> void:
	time += delta
	material.set("shader_parameter/timer", time)
	if time >= 100000:
		time = 0
	
func _physics_querry() -> void:
	physics_querry.position = global_position
	var results: Array = get_world_2d().direct_space_state.intersect_point(physics_querry, 1)
	if results.is_empty():
		collided_area = null
		return
	for result in results:
		var collider :Node = result["collider"]
		if collider != collided_area:
			collided_area = collider
			_collide(collided_area)

func _collide(area: Area2D) -> void:
	if !area.owner.is_on_floor():
		return
	if abs(area.owner.velocity.x) < PLAYER_VEL_TO_SWAY:
		return
	var default_shader_param: Vector3 = get_meta("default_shader_param")
	if tween != null and tween.is_running():
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel()
	time = 0.0
	material.set("shader_parameter/speed", 3.0)
	material.set("shader_parameter/minStrength", 0.15)
	material.set("shader_parameter/maxStrength", 0.15)
	tween.tween_property(material,"shader_parameter/speed", default_shader_param.x, SWAY_DUR * 1.5 )
	tween.tween_property(material,"shader_parameter/minStrength", default_shader_param.y, SWAY_DUR )
	tween.tween_property(material,"shader_parameter/maxStrength", default_shader_param.z, SWAY_DUR )

func _set_collision_mask(num: Array[int]) -> int:
	var num_bit: int = 0
	for n in num:
		num_bit += pow(2, n-1) as int # From godot multiple layer collision documentation
	return num_bit
