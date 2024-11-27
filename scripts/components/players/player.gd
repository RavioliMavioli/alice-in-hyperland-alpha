class_name Player extends CharacterBody2D

static var instance: Player
static var enable_input = true
static var init_position: Vector2
static var player_pos: Vector2
static var player_pos3d: Vector3

var character_node: Node2D:
	get: return %Model
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

static func reset_pos() -> void:
	if Player.instance == null:
		return
	Player.instance.global_position = init_position
	Player.instance.velocity = Vector2.ZERO

func _init() -> void:
	instance = self

func _ready() -> void:
	init_position = self.global_position

func _physics_process(delta: float) -> void:
	_fall(delta)
	move_and_slide()
	player_pos = self.global_position

func _fall(delta) -> void:
	if !is_on_floor():
		velocity.y += gravity * delta
