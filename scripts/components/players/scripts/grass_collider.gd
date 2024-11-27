extends Node

@onready var collider: Area2D = %Grass
@onready var state: PlayerStateManager = %State

var player_vel: float:
	get: return owner.velocity.x

func _physics_process(_delta: float) -> void:
	if state.current_flip == state.FLIP.LEFT:
		collider.scale.x = -1
	else:
		collider.scale.x = 1
