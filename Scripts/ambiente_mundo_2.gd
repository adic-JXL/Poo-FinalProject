extends AudioStreamPlayer
class_name AmbienteMundo2

@export var mix_rate: float = 32000.0
@export var buffer_length: float = 0.28
@export var volumen_base_db: float = -6.8
@export var volumen_peligro_db: float = -2.4
@export var ganancia_base: float = 0.88
@export var ganancia_peligro: float = 1.18

var _playback: AudioStreamGeneratorPlayback = null
var _rng := RandomNumberGenerator.new()
var _sample_index: int = 0
var _ruido_l: float = 0.0
var _ruido_r: float = 0.0
var _presion: float = 0.0
var _presion_objetivo: float = 0.0
var _claridad: float = 0.0
var _claridad_objetivo: float = 0.0


func _ready() -> void:
	_rng.randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	bus = &"Master"
	var generador := AudioStreamGenerator.new()
	generador.mix_rate = mix_rate
	generador.buffer_length = buffer_length
	stream = generador
	volume_db = volumen_base_db
	play()
	_playback = get_stream_playback() as AudioStreamGeneratorPlayback
	set_process(true)


func _process(delta: float) -> void:
	if _playback == null:
		_playback = get_stream_playback() as AudioStreamGeneratorPlayback
		if _playback == null:
			return

	_presion = move_toward(_presion, _presion_objetivo, delta * 0.92)
	_claridad = move_toward(_claridad, _claridad_objetivo, delta * 1.9)
	volume_db = lerpf(volumen_base_db, volumen_peligro_db, _presion)
	_llenar_buffer()


func establecer_presion(valor: float) -> void:
	_presion_objetivo = clampf(valor, 0.0, 1.0)


func establecer_claridad_gafas(activa: bool) -> void:
	_claridad_objetivo = 1.0 if activa else 0.0


func _llenar_buffer() -> void:
	var frames := _playback.get_frames_available()
	for _i in range(frames):
		var t := float(_sample_index) / mix_rate
		var grave_base := (
			sin(TAU * 31.0 * t) * 0.18 +
			sin(TAU * 43.0 * t) * 0.12 +
			sin((TAU * 58.0 * t) + (sin(TAU * 0.07 * t) * 0.6)) * 0.05
		)
		var presion_grave := (
			sin(TAU * 24.0 * t) * 0.22 +
			sin(TAU * 38.0 * t) * 0.13 +
			maxf(0.0, sin(TAU * (1.08 + (_presion * 0.24)) * t)) * 0.08
		) * _presion
		var lfo := 0.5 + (0.5 * sin(TAU * 0.031 * t))
		var ruido_objetivo_l := (_rng.randf() * 2.0 - 1.0) * 0.07
		var ruido_objetivo_r := (_rng.randf() * 2.0 - 1.0) * 0.07
		_ruido_l = lerpf(_ruido_l, ruido_objetivo_l, 0.022)
		_ruido_r = lerpf(_ruido_r, ruido_objetivo_r, 0.022)
		var viento_l := _ruido_l * (0.54 + (0.18 * lfo))
		var viento_r := _ruido_r * (0.54 + (0.18 * (1.0 - lfo)))
		var claridad_tono := sin(TAU * 92.0 * t + (sin(TAU * 0.05 * t) * 0.22)) * 0.017 * _claridad
		var aspereza := sin(TAU * 78.0 * t) * 0.012 * (1.0 - _claridad)
		var respiracion := sin(TAU * (0.18 + (_presion * 0.05)) * t) * 0.05
		var mezcla := grave_base + presion_grave + respiracion
		var ganancia := lerpf(ganancia_base, ganancia_peligro, _presion)
		var muestra_l := clampf((mezcla + viento_l + claridad_tono + aspereza) * ganancia, -1.0, 1.0)
		var muestra_r := clampf((mezcla + viento_r + claridad_tono - aspereza) * ganancia, -1.0, 1.0)
		_playback.push_frame(Vector2(muestra_l, muestra_r))
		_sample_index += 1
