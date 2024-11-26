extends Node2D

@onready var fps := %FPS

func _ready() -> void:
	PolygonProcessor.init_clock(self)
	PolygonProcessor.init_polygon2D(self)
	# Initialize first draw
	await get_tree().create_timer(0.1).timeout
	PolygonProcessor._clock_function.call_deferred(true)
	
func _physics_process(_delta: float) -> void:
	fps.text = str(Engine.get_frames_per_second())
