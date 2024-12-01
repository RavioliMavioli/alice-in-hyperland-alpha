class_name PlayerStateManager extends Node2D

var player: Player:
	get: return owner
var sprite_node: AnimatedSprite2D:
	get: return player.character_node.get_node_or_null("AnimatedSprite2D")
var movement_controls: PlayerMovementControls:
	get: return player.get_node_or_null("%PlayerMovementControls")

enum STATE {IDLE, RUN, JUMP, FALL, DEAD}
enum FLIP {LEFT, RIGHT}

var current_state: STATE
var current_flip: FLIP

func _physics_process(_delta: float) -> void:
	if sprite_node == null:
		return
	# Graphical related process
	#################### Character State ########################
	#################### State ########################
	
	if player.is_on_floor():
		current_state = STATE.IDLE
		
		if player.velocity.x != 0:
			current_state = STATE.RUN

		if player.is_on_wall():
			current_state = STATE.IDLE
	else:
		current_state = STATE.JUMP
		if player.velocity.y > 0:
			current_state = STATE.FALL
	if movement_controls.direction != 0 and !player.is_on_wall():
		if player.velocity.x >= 0:
			current_flip = FLIP.RIGHT
			sprite_node.flip_h = false
		else:
			current_flip = FLIP.LEFT
			sprite_node.flip_h = true
	$Velocity.text = str(player.velocity)
##################################################################################

func get_current_state_id():
	return STATE.keys()[current_state]
func get_current_flip_id():
	return FLIP.keys()[current_flip]
