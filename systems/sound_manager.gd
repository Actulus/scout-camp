extends Node

# ── Assign these in the Inspector once audio files are ready ─────────────────
@export var day_music:       AudioStream
@export var night_music:     AudioStream
@export var outdoor_ambient: AudioStream
@export var indoor_ambient:  AudioStream

# ── Internal state ────────────────────────────────────────────────────────────
const CROSSFADE_DURATION := 2.0

# Music: A/B pair for true simultaneous crossfade
var _music_a: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _active_music: AudioStreamPlayer
var _music_tween: Tween

# Ambient: single player, fade-out/in on switch
var _ambient: AudioStreamPlayer
var _ambient_tween: Tween
var _is_outdoor := true

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	_music_a = _make_player("Music")
	_music_b = _make_player("Music")
	_active_music = _music_a

	_ambient = _make_player("SFX")

	#GameManager.dawn_reached.connect(func(): set_music(day_music))
	#GameManager.dusk_reached.connect(func(): set_music(night_music))

	# Start ambient if a stream is already assigned
	if outdoor_ambient:
		_ambient.stream = outdoor_ambient
		_ambient.play()

func _make_player(bus: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = bus
	add_child(p)
	return p

# ── Public API ─────────────────────────────────────────────────────────────────

## Fire-and-forget sound effect on the SFX bus.
func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if not stream:
		return
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	p.stream = stream
	p.volume_db = volume_db
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()

## Crossfade to a new music track over CROSSFADE_DURATION seconds.
## Pass null to fade out and stop.
func set_music(stream: AudioStream) -> void:
	if _music_tween:
		_music_tween.kill()

	var outgoing := _active_music

	if not stream:
		_music_tween = create_tween()
		_music_tween.tween_property(outgoing, "volume_db", -80.0, CROSSFADE_DURATION)
		_music_tween.finished.connect(outgoing.stop, CONNECT_ONE_SHOT)
		return

	var incoming := _music_b if _active_music == _music_a else _music_a
	incoming.stream = stream
	incoming.volume_db = -80.0
	incoming.play()
	_active_music = incoming

	_music_tween = create_tween().set_parallel()
	_music_tween.tween_property(outgoing, "volume_db", -80.0, CROSSFADE_DURATION)
	_music_tween.tween_property(incoming, "volume_db",  0.0,  CROSSFADE_DURATION)
	_music_tween.finished.connect(outgoing.stop, CONNECT_ONE_SHOT)

## Switch to outdoor ambient (birds, wind). No-op if already outdoor.
func outdoor_mode() -> void:
	if _is_outdoor:
		return
	_is_outdoor = true
	_switch_ambient(outdoor_ambient)

## Switch to indoor ambient (muffled / silence). No-op if already indoor.
func indoor_mode() -> void:
	if not _is_outdoor:
		return
	_is_outdoor = false
	_switch_ambient(indoor_ambient)

# ── Internal ──────────────────────────────────────────────────────────────────

func _switch_ambient(stream: AudioStream) -> void:
	if _ambient_tween:
		_ambient_tween.kill()

	_ambient_tween = create_tween()
	_ambient_tween.tween_property(_ambient, "volume_db", -80.0, CROSSFADE_DURATION * 0.5)

	if stream:
		_ambient_tween.tween_callback(func():
			_ambient.stream = stream
			_ambient.volume_db = 0.0
			_ambient.play()
		)
	else:
		_ambient_tween.tween_callback(_ambient.stop)
