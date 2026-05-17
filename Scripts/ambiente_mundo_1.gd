extends AudioStreamPlayer
class_name AmbienteMundo1

@export var mix_rate: float = 22050.0
@export var buffer_length: float = 0.4
@export var ganancia_general: float = 0.34

var _playback: AudioStreamGeneratorPlayback = null
var _rng := RandomNumberGenerator.new()
var _sample_index: int = 0
var _ruido_l: float = 0.0
var _ruido_r: float = 0.0


func _ready() -> void:
	_rng.randomize()
	var generador := AudioStreamGenerator.new()
	generador.mix_rate = mix_rate
	generador.buffer_length = buffer_length
	stream = generador
	volume_db = -23.0
	play()
	_playback = get_stream_playback() as AudioStreamGeneratorPlayback
	set_process(true)


func _process(_delta: float) -> void:
	if _playback == null:
		return

	_llenar_buffer()


func _llenar_buffer() -> void:
	var frames := _playback.get_frames_available()
	for _i in range(frames):
		var t := float(_sample_index) / mix_rate
		var hum := (
			sin(TAU * 43.0 * t) * 0.10 +
			sin(TAU * 57.0 * t) * 0.06 +
			sin((TAU * 84.0 * t) + (sin(TAU * 0.09 * t) * 0.7)) * 0.03
		)
		var lfo := 0.5 + (0.5 * sin(TAU * 0.037 * t))
		var ruido_objetivo_l := (_rng.randf() * 2.0 - 1.0) * 0.05
		var ruido_objetivo_r := (_rng.randf() * 2.0 - 1.0) * 0.05
		_ruido_l = lerpf(_ruido_l, ruido_objetivo_l, 0.025)
		_ruido_r = lerpf(_ruido_r, ruido_objetivo_r, 0.025)
		var viento_l := _ruido_l * (0.38 + (0.22 * lfo))
		var viento_r := _ruido_r * (0.38 + (0.22 * (1.0 - lfo)))
		var brillo := sin((TAU * (172.0 + (6.0 * sin(TAU * 0.02 * t)))) * t) * 0.008
		var muestra_l := clampf((hum + viento_l + brillo) * ganancia_general, -1.0, 1.0)
		var muestra_r := clampf((hum + viento_r - brillo) * ganancia_general, -1.0, 1.0)
		_playback.push_frame(Vector2(muestra_l, muestra_r))
		_sample_index += 1
