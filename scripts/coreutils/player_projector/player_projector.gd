extends MeshInstance3D

func _physics_process(delta: float) -> void:
	self.global_position = (Vector3(
		Player.player_pos.x,
		- Player.player_pos.y,
		Hyperplane.instance.global_position.z * Constants.METER_TO_PIXEL
	) / Constants.METER_TO_PIXEL ) + (Vector3(0,0,0.01))
