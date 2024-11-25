class_name PlayerMovementControls extends Node2D

@export var running_speed := 200.0

var player: Player:
	get: return owner

const TERMINAL_VELOCITY := 850.0
const DRAG := 5.0
const DRAG_ON_AIR := 10.0
var direction: int
var walked: float = false
var walk: Timer

func _ready() -> void:
	walk = Timer.new()
	walk.autostart = false
	walk.one_shot = false 
	walk.wait_time = 0.2
	self.add_child(walk)
	walk.timeout.connect(func():
		$AudioStreamPlayer.play()
	)

func _input(event: InputEvent) -> void:
	direction = Input.get_axis("A", "D") as int
	if event.is_action_pressed("A") or event.is_action_pressed("D"):
		if Player.instance.is_on_floor() and Player.enable_input and !Player.instance.is_on_wall():
			walk.start()
			walked = true
	if direction == 0:
		walk.stop()
		walked = false
	
func _process(delta: float) -> void:
	_run(delta)
	_cap_to_terminal_velocity()

func _run(delta: float) -> void:
	if Player.instance == null:
		return
	if !Player.instance.is_on_floor() or Player.instance.is_on_wall():
		walk.stop()
		walked = false
	elif direction != 0 and !walked and Player.enable_input:
		walk.start()
		walked = true
	if Player.enable_input == false:
		direction = 0
	var SPEED_devider: float = DRAG if player.is_on_floor() else DRAG_ON_AIR
	if abs(player.velocity.x) > running_speed:
		SPEED_devider = 3.0
	player.velocity.x = move_toward(player.velocity.x,
									( direction * running_speed),
									running_speed * (50 / SPEED_devider) * delta	)

func _cap_to_terminal_velocity() -> void:
	player.velocity = Vector2(	clamp(player.velocity.x, -TERMINAL_VELOCITY, TERMINAL_VELOCITY),
								clamp(player.velocity.y, -TERMINAL_VELOCITY, TERMINAL_VELOCITY)	)
