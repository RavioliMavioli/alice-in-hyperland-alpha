extends Node

const DUR := 0.75

@onready var subviewport: SubViewportContainer = %SubViewportContainer

var tween: Tween
var toggled := false
var default_size: Vector2
var default_pos: Vector2
var default_mod: float

func _ready() -> void:
	default_size = subviewport.size
	default_pos = subviewport.position
	default_mod = subviewport.modulate.a

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Tab"):
		if tween != null and tween.is_running():
			tween.kill()
		tween = get_tree().create_tween()
		tween.set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween.tween_property(subviewport, "size", Vector2(1024, 576) if !toggled else default_size, DUR)
		tween.tween_property(subviewport, "position", Vector2.ZERO if !toggled else default_pos, DUR)
		tween.tween_property(subviewport, "modulate:a", 1.0 if !toggled else default_mod, DUR)
		toggled = !toggled
