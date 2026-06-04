extends Node
## Drives the day/night cycle: advances GameManager.current_time each frame,
## then updates DirectionalLight3D, ProceduralSkyMaterial, and ambient light
## to match. Refs are cached lazily so scene changes are handled automatically.

# ── DirectionalLight (sun) ────────────────────────────────────────────────────
const LIGHT_DAWN := Color("#FFB04A")   # warm orange
const LIGHT_NOON := Color("#FFF5E0")   # near-white
const LIGHT_DUSK := Color("#FF6B35")   # red-orange

const E_DAWN := 0.5
const E_NOON := 1.2
const E_DUSK := 0.4

# ── ProceduralSkyMaterial ─────────────────────────────────────────────────────
# sky_top  = upper half of sky dome
const SKY_TOP_DAWN := Color(0.05, 0.12, 0.28)  # deep pre-dawn blue
const SKY_TOP_NOON := Color(0.09, 0.42, 0.78)  # clear midday blue
const SKY_TOP_DUSK := Color(0.10, 0.07, 0.28)  # purple dusk

# sky_horizon = strip at horizon
const SKY_HOR_DAWN := Color(0.90, 0.40, 0.08)  # orange glow
const SKY_HOR_NOON := Color(0.54, 0.76, 0.91)  # pale blue
const SKY_HOR_DUSK := Color(0.82, 0.20, 0.04)  # deep red

# ── Ambient (COLOR source, full runtime control) ──────────────────────────────
const AMB_DAWN   := Color(0.18, 0.13, 0.10)
const AMB_NOON   := Color(0.52, 0.58, 0.68)
const AMB_DUSK   := Color(0.16, 0.09, 0.07)
const AMB_E_DAWN := 0.25
const AMB_E_NOON := 0.80
const AMB_E_DUSK := 0.20

# ── Fog ───────────────────────────────────────────────────────────────────────
const FOG_DAWN := Color(0.78, 0.62, 0.52)   # warm morning mist
const FOG_NOON := Color(0.72, 0.75, 0.79)   # cool midday haze
const FOG_DUSK := Color(0.70, 0.42, 0.28)   # orange-red dusk haze

# ── Cached refs ───────────────────────────────────────────────────────────────
var _sun: DirectionalLight3D
var _world_env: WorldEnvironment
var _env: Environment
var _sky_mat: ProceduralSkyMaterial

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	if not scene or scene.scene_file_path.contains("main_menu"):
		return
	_update_lighting(0.5)  # TODO: restore dynamic cycle

# ── Lighting update ───────────────────────────────────────────────────────────

func _update_lighting(t: float) -> void:
	_ensure_refs()
	if not _sun or not _env:
		return

	# sin curve: 0 at t=0 (dawn) and t=1 (dusk), peaks at 1 when t=0.5 (noon)
	var elev := sin(t * PI)

	# --- DirectionalLight3D ---
	_sun.rotation_degrees = Vector3(
		-lerpf(10.0, 75.0, elev),   # elevation: low sunrise → high noon → low sunset
		lerpf(-90.0, 90.0, t),      # azimuth: east → south → west
		0.0
	)

	var light_col: Color
	var light_e: float
	var sky_top: Color
	var sky_hor: Color
	var amb_col: Color
	var amb_e: float
	var fog_col: Color

	if t <= 0.5:
		var f := t * 2.0
		light_col = LIGHT_DAWN.lerp(LIGHT_NOON, f)
		light_e   = lerpf(E_DAWN, E_NOON, f)
		sky_top   = SKY_TOP_DAWN.lerp(SKY_TOP_NOON, f)
		sky_hor   = SKY_HOR_DAWN.lerp(SKY_HOR_NOON, f)
		amb_col   = AMB_DAWN.lerp(AMB_NOON, f)
		amb_e     = lerpf(AMB_E_DAWN, AMB_E_NOON, f)
		fog_col   = FOG_DAWN.lerp(FOG_NOON, f)
	else:
		var f := (t - 0.5) * 2.0
		light_col = LIGHT_NOON.lerp(LIGHT_DUSK, f)
		light_e   = lerpf(E_NOON, E_DUSK, f)
		sky_top   = SKY_TOP_NOON.lerp(SKY_TOP_DUSK, f)
		sky_hor   = SKY_HOR_NOON.lerp(SKY_HOR_DUSK, f)
		amb_col   = AMB_NOON.lerp(AMB_DUSK, f)
		amb_e     = lerpf(AMB_E_NOON, AMB_E_DUSK, f)
		fog_col   = FOG_NOON.lerp(FOG_DUSK, f)

	_sun.light_color  = light_col
	_sun.light_energy = light_e

	# AMBIENT_SOURCE_BG (the default) uses baked sky radiance and ignores
	# ambient_light_color / ambient_light_energy changes entirely.
	_env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_env.ambient_light_color  = amb_col
	_env.ambient_light_energy = amb_e

	_env.fog_light_color = fog_col

	# --- ProceduralSkyMaterial: shift visible sky colours with time of day
	if _sky_mat:
		_sky_mat.sky_top_color       = sky_top
		_sky_mat.sky_horizon_color   = sky_hor
		_sky_mat.ground_horizon_color = sky_hor.darkened(0.3)

# ── Lazy ref cache ────────────────────────────────────────────────────────────

func _ensure_refs() -> void:
	if not is_instance_valid(_world_env):
		_world_env = get_tree().get_first_node_in_group("world_environment")
		if _world_env:
			_env = _world_env.environment
			if _env and _env.sky:
				_sky_mat = _env.sky.sky_material as ProceduralSkyMaterial

	if not is_instance_valid(_sun):
		_sun = get_tree().get_first_node_in_group("sun_light")
