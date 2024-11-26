extends Sprite2D

var time := 0.0

func _physics_process(delta: float) -> void:
	time += delta
	material.set("shader_parameter/timer", time)
