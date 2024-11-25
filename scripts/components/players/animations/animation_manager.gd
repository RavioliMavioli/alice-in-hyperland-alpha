extends Node2D

var player: Player:
	get: return owner
var player_state: PlayerStateManager:
	get: return player.get_node_or_null("%State")
var animation_tree_node: AnimationTree:
	get: return player.character_node.get_node_or_null("AnimationTree")
var state_machine:AnimationNodeStateMachinePlayback:
	get: return animation_tree_node["parameters/playback"]

func _ready() -> void:
	animation_tree_node.active = true

func _process(delta: float) -> void:
	#################### State ########################
	#var player_state.STATE.keys()[player_state.current_state]
	#AI_STATE.keys()[current_state]
	match player_state.current_state:
		player_state.STATE.IDLE:
			state_machine.travel("idle")
		player_state.STATE.JUMP:
			state_machine.travel("jump")
		player_state.STATE.FALL:
			state_machine.travel("fall")
		player_state.STATE.DEAD:
			state_machine.travel("dead")
	#################### Facing ########################
		player_state.STATE.RUN:
			state_machine.travel("run_forward")
