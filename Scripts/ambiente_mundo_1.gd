extends AudioStreamPlayer
class_name AmbienteMundo1

@export var mix_rate: float = 32000.0
@export var buffer_length: float = 0.32
@export var ganancia_general: float = 1.02
@export var ganancia_jefe: float = 1.22
@export var volumen_normal_db: float = -5.5
@export var volumen_jefe_db: float = -1.8

var _playback: AudioStreamGeneratorPlayback = null
var _rng := RandomNumberGenerator.new()
var _sample_index: int = 0
var _ruido_l: float = 0.0
var _ruido_r: float = 0.0
var _mezcla_jefe: float = 0.0
var _objetivo_jefe: float = 0.0
var _transicion_jefe_reproducida: bool = false
static var _stream_transicion_jefe: AudioStreamWAV

@onready var audio_transicion: AudioStreamPlayer = AudioStreamPlayer.new()


func _ready() -> void:
	_rng.randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	bus = &"Master"
	var generador := AudioStreamGenerator.new()
	generador.mix_rate = mix_rate
	generador.buffer_length = buffer_length
	stream = generador
	volume_db = volumen_normal_db
	play()
	_playback = get_stream_playback() as AudioStreamGeneratorPlayback
	audio_transicion.bus = &"Master"
	audio_transicion.volume_db = -2.8
	audio_transicion.stream = _obtener_stream_transicion_jefe()
	add_child(audio_transicion)
	set_process(true)


func _process(delta: float) -> void:
	if _playback == null:
		_playback = get_stream_playback() as AudioStreamGeneratorPlayback
		if _playback == null:
			return

	_mezcla_jefe = move_toward(_mezcla_jefe, _objetivo_jefe, delta * 0.68)
	volume_db = lerpf(volumen_normal_db, volumen_jefe_db, _mezcla_jefe)
	if _playback == null:
		return

	_llenar_buffer()


func establecer_modo_jefe(activo: bool) -> void:
	_objetivo_jefe = 1.0 if activo else 0.0
	if activo and not _transicion_jefe_reproducida:
		_transicion_jefe_reproducida = true
		if audio_transicion != null:
			audio_transicion.stop()
			audio_transicion.play()
	elif not activo:
		_transicion_jefe_reproducida = false


func _llenar_buffer() -> void:
	var frames := _playback.get_frames_available()
	for _i in range(frames):
		var t := float(_sample_index) / mix_rate
		var hum_normal := (
			sin(TAU * 41.0 * t) * 0.16 +
			sin(TAU * 54.0 * t) * 0.10 +
			sin((TAU * 82.0 * t) + (sin(TAU * 0.09 * t) * 0.7)) * 0.06
		)
		var hum_jefe := (
			sin(TAU * 29.0 * t) * 0.28 +
			sin(TAU * 46.0 * t) * 0.17 +
			sin(TAU * 69.0 * t) * 0.08
		)
		var lfo := 0.5 + (0.5 * sin(TAU * 0.037 * t))
		var ruido_objetivo_l := (_rng.randf() * 2.0 - 1.0) * 0.08
		var ruido_objetivo_r := (_rng.randf() * 2.0 - 1.0) * 0.08
		_ruido_l = lerpf(_ruido_l, ruido_objetivo_l, 0.025)
		_ruido_r = lerpf(_ruido_r, ruido_objetivo_r, 0.025)
		var viento_l := _ruido_l * (0.54 + (0.28 * lfo))
		var viento_r := _ruido_r * (0.54 + (0.28 * (1.0 - lfo)))
		var brillo := sin((TAU * (122.0 + (5.0 * sin(TAU * 0.02 * t)))) * t) * 0.009
		var aire_agudo := sin(TAU * 164.0 * t + (sin(TAU * 0.09 * t) * 0.32)) * 0.005
		var pulso_jefe := maxf(0.0, sin(TAU * 1.3 * t)) * 0.08 * _mezcla_jefe
		var latido_jefe := sin(TAU * 0.62 * t) * 0.06 * _mezcla_jefe
		var hum := lerpf(hum_normal, hum_jefe, _mezcla_jefe)
		var ganancia := lerpf(ganancia_general, ganancia_jefe, _mezcla_jefe)
		var muestra_l := clampf((hum + viento_l + brillo + aire_agudo + pulso_jefe + latido_jefe) * ganancia, -1.0, 1.0)
		var muestra_r := clampf((hum + viento_r - brillo + aire_agudo + pulso_jefe + latido_jefe) * ganancia, -1.0, 1.0)
		_playback.push_frame(Vector2(muestra_l, muestra_r))
		_sample_index += 1


func _obtener_stream_transicion_jefe() -> AudioStreamWAV:
	if _stream_transicion_jefe != null:
		return _stream_transicion_jefe

	var sample_rate := 22050
	var duracion := 0.85
	var total_samples := int(sample_rate * duracion)
	var data := PackedByteArray()
	data.resize(total_samples * 2)
	for i in range(total_samples):
		var t := float(i) / float(sample_rate)
		var envelope := sin(clampf(t / duracion, 0.0, 1.0) * PI)
		var grave := sin(TAU * 62.0 * t)
		var medio := sin(TAU * 124.0 * t)
		var muestra := (grave * 0.75 + medio * 0.22) * envelope * 0.62
		var valor := int(clampf(muestra, -1.0, 1.0) * 32767.0)
		data[i * 2] = valor & 0xFF
		data[(i * 2) + 1] = (valor >> 8) & 0xFF

	_stream_transicion_jefe = AudioStreamWAV.new()
	_stream_transicion_jefe.format = AudioStreamWAV.FORMAT_16_BITS
	_stream_transicion_jefe.mix_rate = sample_rate
	_stream_transicion_jefe.stereo = false
	_stream_transicion_jefe.loop_mode = AudioStreamWAV.LOOP_DISABLED
	_stream_transicion_jefe.data = data
	return _stream_transicion_jefe
