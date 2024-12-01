extends Node

enum PROFILE {
	CUSTOM,
	DARK_GROUND
}

var profiles := {
	"custom": {},
	"dark_ground": {
		"polygon_texture": load("res://resources/asd.png"),
		"polygon_color": Color.WHITE,
		"disable_shadow": true,
		"disable_line": false,
		"line_width": 16.0,
		"line_texture": load("res://resources/images/sprites/environments/grounds/gnd1.png"),
		"line_color": Color.WHITE,
		"line_profile": null
	}
}
