extends Node

enum AUDIO_BUS {MASTER = 0, MIX = 1, SFX = 2, BGM = 3, UI = 4}

const MAX_HZ := 20500.0
const MIN_HZ := 750.0
const MIN_AMP := 0.0
const MAX_AMP := 5.0

var low_pass: AudioEffectLowPassFilter:
	get: return AudioServer.get_bus_effect(AUDIO_BUS.MIX, 0)
var amp: AudioEffectAmplify:
	get: return AudioServer.get_bus_effect(AUDIO_BUS.MIX, 1)

func set_low_pass(val: float) -> void:
	low_pass.cutoff_hz = clamp(val, MIN_HZ, MAX_HZ)
func set_amp(val: float) -> void:
	amp.volume_db = clamp(val, MIN_AMP, MAX_AMP)
	
func get_cutoff() -> float:
	return low_pass.cutoff_hz
func get_amp_db() -> float:
	return amp.volume_db
func get_bus_str(bus: AUDIO_BUS) -> String:
	return AudioServer.get_bus_name(bus)

func set_sfx_vol(val: float) -> void:
	AudioServer.set_bus_volume_db(AUDIO_BUS.SFX, _percent_to_db(val))
func set_bgm_vol(val: float) -> void:
	AudioServer.set_bus_volume_db(AUDIO_BUS.BGM, _percent_to_db(val))
func set_ui_vol(val: float) -> void:
	AudioServer.set_bus_volume_db(AUDIO_BUS.UI, _percent_to_db(val))

func _percent_to_db(val: float) -> float:
	var val_n: float = clampf(val, 0.0, 100.0) / 100.0
	return linear_to_db(val_n)
