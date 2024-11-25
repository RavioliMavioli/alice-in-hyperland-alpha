extends Node

signal setting_changed(what: Variant)

enum POLYGON_DRAW_RATE {_60FPS, _30FPS, _15FPS}

var _init_we: Environment = load("res://data/world_environments/main_env.tres")
const FILE_PATH := "settings"

var is_fps: bool:
	get: return get_setting("is_fps", false)
	set(val): set_setting("is_fps", val)
var is_fullscreen: bool:
	get: return get_setting("is_fullscreen", false)
	set(val): set_setting("is_fullscreen", val)
var is_vsync: bool:
	get: return get_setting("is_vsync", true)
	set(val): set_setting("is_vsync", val)
var is_shaders: bool:
	get: return get_setting("is_shaders", true)
	set(val): set_setting("is_shaders", val)
var is_particles: bool:
	get: return get_setting("is_particles", true)
	set(val): set_setting("is_particles", val)
var is_post_process: bool:
	get: return get_setting("is_post_process", true)
	set(val): set_setting("is_post_process", val)

var audio_music_vol: float:
	get: return get_setting("audio_music_vol", 100.0)
	set(val): set_setting("audio_music_vol", val)
var audio_sfx_vol: float:
	get: return get_setting("audio_sfx_vol", 100.0)
	set(val): set_setting("audio_sfx_vol", val)

var multi_threaded: bool:
	get: return get_setting("multi_threaded", true)
	set(val): set_setting("multi_threaded", val)
var polygon_draw_rate: POLYGON_DRAW_RATE:
	get: return get_setting("polygon_draw_rate", POLYGON_DRAW_RATE._30FPS)
	set(val): set_setting("polygon_draw_rate", val)

func _ready() -> void:
	DataService.data_changed.connect(_data_changed)
	update_settings() # Init settings
	setting_changed.connect(func (setting):
		update_settings(setting)
	)
	
func update_settings(setting: Variant = null) -> void:
	if setting == null:
		_update_fps()
		_update_fullscreen()
		_update_vsync()
		_update_shaders()
		_update_particles()
		_update_post_process()
		_update_audio_vol()
		
		_update_polygon_draw_rate()
		return
	if setting is Array:
		for s in setting:
			_update_settings(s)
		return
	_update_settings(setting)

func get_setting(setting: String, default :Variant = null) -> Variant:
	return DataService.get_wrapper(FILE_PATH).get_data(setting, default)

func set_setting(setting :String, value :Variant) -> void:
	DataService.get_wrapper(FILE_PATH).set_data(setting, value)

func _data_changed(file_path:String, _section:String, key:String) -> void:
	if file_path != FILE_PATH:
		return
	setting_changed.emit(key)

func _update_settings(setting: String) -> void:
	match setting:
		"is_fps":
			_update_fps()
		"is_fullscreen":
			_update_fullscreen()
		"is_vsync":
			_update_vsync()
		"is_shaders":
			_update_shaders()
		"is_particles":
			_update_particles()
		"is_post_process":
			_update_post_process()
		"multi_threaded":
			_update_multi_threaded()
		"polygon_draw_rate":
			_update_polygon_draw_rate()
		_:
			_update_audio_vol()

func _update_fps() -> void:
	pass

func _update_fullscreen() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)

func _update_vsync() -> void:
	pass
		
func _update_shaders() -> void:
	pass
	
func _update_particles() -> void:
	pass
	
func _update_post_process() -> void:
	var n = get_tree().current_scene.get_node_or_null("%WorldEnvironment")
	if n != null:
		n.environment = _init_we if is_post_process else null

func _update_audio_vol() -> void:
	Audio.set_bgm_vol(audio_music_vol)
	Audio.set_sfx_vol(audio_sfx_vol)
	Audio.set_ui_vol(audio_sfx_vol)

func _update_multi_threaded() -> void:
	# This function has been taken care of automaticaly.
	pass

func _update_polygon_draw_rate() -> void:
	if PolygonProcessor.clock == null:
		return
	PolygonProcessor.clock.wait_time = polygon_draw_rate
