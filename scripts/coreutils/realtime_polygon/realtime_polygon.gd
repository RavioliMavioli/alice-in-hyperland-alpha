@tool

extends Node

@onready var timer := $Timer
var node3d: Node3D:
	get: return %Node3D
var level: Level:
	get: return owner
var hyperplane: Hyperplane:
	get: return node3d.get_node("%Hyperplane")
var polygons: Node2D:
	get: return level.get_node("%Polygons")
	
func _ready() -> void:
	return
	if !Engine.is_editor_hint():
		for n in polygons:
			if n != null and !n.is_queued_for_deletion():
				n.queue_free()
		for t in level.timers:
			if t != null and !t.is_queued_for_deletion():
				t.queue_free()
		return
	#timer.autostart = true
	timer.one_shot = false
	timer.wait_time = 3.0
	timer.timeout.connect(_update)
	#timer.start()
	
func _update() -> void:
	for n in polygons:
		if n != null and !n.is_queued_for_deletion():
			n.queue_free()
	PolygonProcessor.init_polygon2D(polygons)
	PolygonProcessor._clock_function.call_deferred(true)
	
