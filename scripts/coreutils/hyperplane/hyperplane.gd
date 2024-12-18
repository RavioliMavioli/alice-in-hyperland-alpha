class_name Hyperplane extends MeshInstance3D

enum STATUS {ACTIVE, IDLE, DISABLED}

static var instance: Hyperplane
static var status := STATUS.IDLE

const TWEEN_DUR := 0.33

var init_hyperplane_pos: Vector3
var dir: int
var prev_dir: int
var accel := 0.0
var tween: Tween

func _init() -> void:
	instance = self

func _ready() -> void:
	init_hyperplane_pos = global_position
	
func _input(_event: InputEvent) -> void:
	dir = int(Input.get_axis("W", "S"))
	if status == STATUS.DISABLED:
		return
	if prev_dir == dir:
		return
	if dir != 0:
		_create_tween()
		tween.tween_property(self, "accel", 1.0 * dir, TWEEN_DUR)
		status = STATUS.ACTIVE
		PolygonProcessor.start_polygon_update()
	else:
		_create_tween()
		tween.tween_property(self, "accel", 0.0, TWEEN_DUR)
		tween.finished.connect(func():
			status = STATUS.IDLE
			PolygonProcessor.stop_polygon_update()
		)
	prev_dir = dir

func _physics_process(delta: float) -> void:
	var target := Constants.H_SPEED_MULT * accel * delta
	if accel == 0:
		return
	global_position.z = clampf(global_position.z + target, -1.5, 1.5)

func _create_tween() -> void:
	if tween != null:
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
