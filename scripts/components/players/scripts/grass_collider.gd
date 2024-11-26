extends Node

const SWAY_DUR := 2.0
const PLAYER_VEL_TO_SWAY := 150.0

@onready var collider: Area2D = %Grass
@onready var state: PlayerStateManager = %State

var player_vel: float:
	get: return owner.velocity.x

func _ready() -> void:
	collider.area_entered.connect(func (area):
		if !Player.instance.is_on_floor():
			return
		if abs(player_vel) < PLAYER_VEL_TO_SWAY:
			return
		var sprite: Sprite2D = area.get_parent()
		if sprite == null:
			return
		var tween: Tween
		var default_shader_param: Vector3 = sprite.get_meta("default_shader_param")
		if sprite.has_meta("tween"):
			tween = sprite.get_meta("tween")
			tween.kill()
			tween = _create_tween(sprite)
		else:
			tween = _create_tween(sprite)
			
		tween.set_parallel()
		sprite.time = 0.0
		sprite.material.set("shader_parameter/speed", 3.0)
		sprite.material.set("shader_parameter/minStrength", 0.15)
		sprite.material.set("shader_parameter/maxStrength", 0.15)
		tween.tween_property(sprite.material,"shader_parameter/speed", default_shader_param.x, SWAY_DUR * 1.5 )
		tween.tween_property(sprite.material,"shader_parameter/minStrength", default_shader_param.y, SWAY_DUR )
		tween.tween_property(sprite.material,"shader_parameter/maxStrength", default_shader_param.z, SWAY_DUR )
	)

func _physics_process(_delta: float) -> void:
	if state.current_flip == state.FLIP.LEFT:
		collider.scale.x = -1
	else:
		collider.scale.x = 1

func _create_tween(sprite: Sprite2D) -> Tween:
	var tween := get_tree().create_tween()
	sprite.set_meta("tween", tween)
	return tween
