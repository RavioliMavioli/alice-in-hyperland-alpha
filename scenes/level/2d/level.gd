class_name Level extends Node2D

static var instance: Level

@export var level_3d: PackedScene

@onready var fps := %FPS
@onready var polygons := %Polygons
@onready var timers := %Timers
@onready var subviewport := %SubViewport

func _init() -> void:
	instance = self

func _ready() -> void:
	_init_level_3d()
	_init_polygons.call_deferred()
	
func _physics_process(_delta: float) -> void:
	fps.text = str(Engine.get_frames_per_second())

func _init_level_3d() -> void:
	var new_level: Level3D = level_3d.instantiate()
	subviewport.add_child(new_level)

func _init_polygons() -> void:
	PolygonProcessor.init_clock(timers)
	PolygonProcessor.init_polygon2D(polygons)
	PolygonProcessor.draw_init_polygon()
