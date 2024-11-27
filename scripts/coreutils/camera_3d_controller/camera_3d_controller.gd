extends Node

const OFFSET_Y := -100.0

var camera3d: Camera_3D:
	get: return Camera_3D.instance
var hyperplane: Hyperplane:
	get: return Hyperplane.instance

func _physics_process(_delta: float) -> void:
	if camera3d == null or hyperplane == null:
		return
	camera3d.global_position = Vector3(
		Camera.camera_pos.x / Constants.METER_TO_PIXEL,
		- (Camera.camera_pos.y + OFFSET_Y) / Constants.METER_TO_PIXEL,
		camera3d.global_position.z
	)
	hyperplane.global_position = Vector3(
		Player.player_pos.x / Constants.METER_TO_PIXEL,
		- (Player.player_pos.y + OFFSET_Y) / Constants.METER_TO_PIXEL,
		hyperplane.global_position.z
	)
	
	Camera.camera_pos3d = camera3d.global_position
