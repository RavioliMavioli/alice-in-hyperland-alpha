class_name Player extends CharacterBody2D

static var instance: Player
static var enable_input = true
static var init_position: Vector2

var character_node: Node2D:
	get: return %Model
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _init() -> void:
	instance = self

func _ready() -> void:
	init_position = self.global_position

func _physics_process(delta: float) -> void:
	_fall(delta)
	move_and_slide()

func _fall(delta) -> void:
	if !is_on_floor():
		velocity.y += gravity * delta
