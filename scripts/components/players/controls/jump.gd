class_name PlayerJumpControls extends Node2D

signal touched_floor

@export var jump_velocity := 150.0

enum TIMER {JUMP, COYOTE, COOLDOWN}
const JUMP_AMPLIFIER := 150.0
const JUMP_DURATION_WAIT_TIME := 0.4
const COYOTE_JUMP_WAIT_TIME := 0.1
const COOLDOWN_WAIT_TIME := 0.15

var ground_clearance: Area2D:
	get: return %GroundClearance
var player: Player:
	get: return owner
	
var jump_timer: SceneTreeTimer
var coyote_timer: SceneTreeTimer
var cooldown_timer: SceneTreeTimer
var was_on_floor := false

func jump() -> void: # Public method if you want to jump from other script
	_create_timer(TIMER.JUMP)
	_create_timer(TIMER.COOLDOWN)
	$AudioStreamPlayer.play()

func _input(event: InputEvent) -> void:
	if Player.enable_input == false:
		return
	if event.is_action_released("Space"):
		jump_timer = null
		coyote_timer = null
	if event.is_action_pressed("Space"):
		_do_jump()

func _process(delta: float) -> void:
	_coyote()
	_touched_floor_signal()
	if Player.enable_input == false:
		return
	_jump_process()
	_ceiling_collide()
	
func _do_jump() -> void:
	# Space Buffer
	var ground_check = ground_clearance.has_overlapping_bodies()
	if cooldown_timer != null:
		return
	if coyote_timer == null:
		if ground_check and !player.is_on_floor():
			await touched_floor # Wait until player touches the ground
		# Prevent flying
		if !player.is_on_floor():
			return
		# Cancel jump when the button is not pressed while still on jump buffer
		if !Input.is_action_pressed("Space"):
			return
	# Main jump
	jump()
	
func _jump_process() -> void:
	if jump_timer != null:
		player.velocity.y = -jump_velocity - (jump_timer.time_left/JUMP_DURATION_WAIT_TIME * JUMP_AMPLIFIER)

func _coyote() -> void:
	if was_on_floor and !player.is_on_floor():
		_create_timer(TIMER.COYOTE)

func _ceiling_collide() -> void:
	if player.is_on_ceiling():
		if player.velocity.y < 0:
			player.velocity.y = 0
		jump_timer = null
		coyote_timer = null

func _create_timer(type: TIMER) -> void:
	match type:
		TIMER.JUMP:
			jump_timer = get_tree().create_timer(JUMP_DURATION_WAIT_TIME)
			jump_timer.timeout.connect(_jump_timeout)
		TIMER.COYOTE:
			coyote_timer = get_tree().create_timer(COYOTE_JUMP_WAIT_TIME)
			coyote_timer.timeout.connect(_coyote_timeout)
		TIMER.COOLDOWN:
			cooldown_timer = get_tree().create_timer(COOLDOWN_WAIT_TIME)
			cooldown_timer.timeout.connect(_cooldown_timeout)

func _jump_timeout() -> void:
	jump_timer = null
	
func _coyote_timeout() -> void:
	coyote_timer = null

func _cooldown_timeout() -> void:
	cooldown_timer = null

func _touched_floor_signal() -> void:
	if player.is_on_floor() and !was_on_floor:
		touched_floor.emit()
		$AudioStreamPlayer2.play()
	was_on_floor = player.is_on_floor()
