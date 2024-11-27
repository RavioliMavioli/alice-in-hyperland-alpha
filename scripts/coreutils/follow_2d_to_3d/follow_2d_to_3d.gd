extends Node

@onready var chara: MeshInstance3D = %Node3D.get_node("%Character")

func _physics_process(_delta: float) -> void:
	if Player.instance == null or Hyperplane.instance == null:
		return
	chara.global_position = Vector3(
		Player.player_pos.x,
		- Player.player_pos.y,
		(Hyperplane.instance.global_position.z + 0.01) * Constants.METER_TO_PIXEL
	) / Constants.METER_TO_PIXEL
	Player.player_pos3d = chara.global_position
