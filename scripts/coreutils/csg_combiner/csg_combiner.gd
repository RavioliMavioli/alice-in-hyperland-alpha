class_name CSGCombiner extends CSGCombiner3D

@export_group("Use Profile Template")
@export var profile := PolygonProfile.PROFILE.CUSTOM

@export_group("Grass")
@export var grass_direction := MeshPair.GRASS_DIRECTION.NONE ## Spawn grass

@export_group("Polygon")
@export var use_legacy_polygon_sorter := false ## Enable this if grass doesn't spawn, slighly higher CPU demand.
@export var mark_static := false: ## If enabled, the shape won't change when the Hyperplane moves. Use this for making grounds or other static objects.
	set(val):
		if mark_static == val:
			return
		mark_static = val
		PolygonProcessor._clock_function()
@export var polygon_texture: Texture2D
@export var polygon_color := Color.WHITE

@export_group("Shadow")
@export var disable_shadow := false ## Disable Terraria effect shadow

@export_group("Line")
@export var disable_line := false ## Disable Terraria effect shadow
@export var line_width := 16.0
@export var line_texture: Texture2D
@export var line_color := Color.WHITE
@export var line_profile: Curve2D

func _ready() -> void:
	_setup_profile()

func _setup_profile() -> void:
	if profile == PolygonProfile.PROFILE.CUSTOM:
		return
	var str_profile := str(PolygonProfile.PROFILE.keys()[profile]).to_lower()
	
	polygon_texture = PolygonProfile.profiles[str_profile]["polygon_texture"]
	polygon_color = PolygonProfile.profiles[str_profile]["polygon_color"]
	disable_shadow = PolygonProfile.profiles[str_profile]["disable_shadow"]
	disable_line = PolygonProfile.profiles[str_profile]["disable_line"]
	line_width = PolygonProfile.profiles[str_profile]["line_width"]
	line_texture = PolygonProfile.profiles[str_profile]["line_texture"]
	line_color = PolygonProfile.profiles[str_profile]["line_color"]
	line_profile = PolygonProfile.profiles[str_profile]["line_profile"]
