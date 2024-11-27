extends Node

@onready var collider: Area2D = %Grass
@onready var state: PlayerStateManager = %State

var player_vel: float:
	get: return owner.velocity.x

func _physics_process(_delta: float) -> void:
	collider.scale.x = -1 if state.current_flip == state.FLIP.LEFT else 1
