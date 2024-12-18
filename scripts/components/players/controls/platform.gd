class_name PlayerPlatformControls extends Node2D

var player: Player:
	get: return owner
var platform_check: Area2D:
	get: return %PlatformCheck

func _physics_process(_delta: float) -> void:
	if Player.enable_input == false:
		return
	if !platform_check.has_overlapping_bodies():
		return
	if Input.is_action_pressed("Down"):
		player.global_position.y += 1.0
		
