class_name Camera extends Camera2D

var limit := Vector4(-100000, -100000, 100000, 100000)
static var instance: Camera

const VIEWPORT_RES := Vector2(1024, 576)
const VERTICAL_OFFSET := -80.0

var offset_x := 0.0
var target_offset_x := 0.0

func set_cam_limit(_limit: Vector4) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "limit", _limit, 3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

func _init() -> void:
	instance = self

func _ready() -> void:
	if Player.instance != null:
		self.global_position = Player.instance.global_position

func _physics_process(delta):
	_camera_physics(delta)
	_cap_to_limit(delta)
	
func _camera_physics(delta: float) -> void:
	if Player.instance == null:
		return
	var player_pos: Vector2 = Player.instance.global_position
	var dir = Input.get_axis("A", "D")
	if dir != 0:
		#if Player.enable_input == false: return
		target_offset_x = dir * 75
	offset_x = lerp(offset_x, target_offset_x, delta * 1.5)
	self.global_position.x = lerp(self.global_position.x, player_pos.x + offset_x, delta * 3.5)
	self.global_position.y = lerp(self.global_position.y, player_pos.y + VERTICAL_OFFSET, delta * 1.0)
	
func _cap_to_limit(delta: float) -> void:
	self.global_position = Vector2(	clamp(self.global_position.x, limit.x, limit.w),
									clamp(self.global_position.y, limit.y, limit.z))
