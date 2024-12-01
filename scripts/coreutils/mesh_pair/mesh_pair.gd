class_name MeshPair extends MeshInstance3D

enum GRASS_DIRECTION {NONE, ALL, TOP, BOTTOM, TOP_BOTTOM, LEFT, RIGHT, LEFT_RIGHT}

var polygon_pair: PolygonPair
var face_ammount: int
var grass_direction := GRASS_DIRECTION.NONE ## Spawn grass
var use_legacy_polygon_sorter := false ## Enable this if grass doesn't spawn, slighly higher CPU demand.
var mark_static := false: ## If enabled, the shape won't change when the Hyperplane moves. Use this for making grounds or other static objects.
	set(val):
		if mark_static == val:
			return
		mark_static = val
		PolygonProcessor._clock_function()
var polygon_texture: Texture2D
var polygon_color := Color.WHITE
var disable_shadow := false ## Disable Terraria effect shadow
var disable_line := false ## Disable Terraria effect shadow
var line_width := 16.0
var line_texture: Texture2D
var line_color := Color.WHITE
var line_profile: Curve2D
