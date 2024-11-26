extends Node

const OFFSET_Y := -100.0

var player: Player:
	get: return Player.instance
var camera3d: Camera_3D:
	get: return Camera_3D.instance
var hyperplane: Hyperplane:
	get: return Hyperplane.instance

func _physics_process(delta: float) -> void:
	if player == null or camera3d == null or hyperplane == null:
		return
	camera3d.global_position = Vector3(
		player.global_position.x / Constants.METER_TO_PIXEL,
		- (player.global_position.y + OFFSET_Y) / Constants.METER_TO_PIXEL,
		camera3d.global_position.z
	)
	hyperplane.global_position = Vector3(
		player.global_position.x / Constants.METER_TO_PIXEL,
		- (player.global_position.y + OFFSET_Y) / Constants.METER_TO_PIXEL,
		hyperplane.global_position.z
	)
