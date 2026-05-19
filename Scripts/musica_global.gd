extends AudioStreamPlayer

@export var mix_rate: float = 32000.0
@export var buffer_length: float = 0.45
@export var volumen_db: float = -19.5
@export var bpm: float = 92.0

var _playback: AudioStreamGeneratorPlayback = null
var _sample_index: int = 0
var _melodia := [72, 76, 79, 76, 74, 72, 69, 71, 72, 76, 81, 79, 76, 74, 72, -1]
var _bajo := [48, 48, 55, 55, 45, 45, 52, 52]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	bus = &"Master"
	volume_db = volumen_db
	var generador := AudioStreamGenerator.new()
	generador.mix_rate = mix_rate
	generador.buffer_length = buffer_length
	stream = generador
	play()
	_playback = get_stream_playback() as AudioStreamGeneratorPlayback
	set_process(true)


func _process(_delta: float) -> void:
	if _playback == null:
		_playback = get_stream_playback() as AudioStreamGeneratorPlayback
		if _playback == null:
			return

	_llenar_buffer()


func _llenar_buffer() -> void:
	var frames := _playback.get_frames_available()
	var step_duration := 60.0 / bpm * 0.5
	for _i in range(frames):
		var t := float(_sample_index) / mix_rate
		var step := int(floor(t / step_duration))
		var local_t := fmod(t, step_duration)
		var nota := int(_melodia[step % _melodia.size()])
		var nota_bajo := int(_bajo[int(floor(t / (step_duration * 2.0))) % _bajo.size()])

		var campana := 0.0
		if nota >= 0:
			var freq := _midi_a_frecuencia(nota)
			var env := _envolvente_campana(local_t, step_duration)
			campana = (
				sin(TAU * freq * t) * 0.115 +
				sin(TAU * freq * 2.0 * t) * 0.035 +
				sin(TAU * freq * 3.01 * t) * 0.012
			) * env

		var freq_bajo := _midi_a_frecuencia(nota_bajo)
		var pulso_bajo := sin(TAU * freq_bajo * t) * 0.035
		var pad := (
			sin(TAU * _midi_a_frecuencia(60) * t) * 0.020 +
			sin(TAU * _midi_a_frecuencia(67) * t) * 0.017 +
			sin(TAU * _midi_a_frecuencia(72) * t) * 0.012
		) * (0.78 + 0.22 * sin(TAU * 0.07 * t))

		var brillo := sin(TAU * 1840.0 * t) * 0.004 * maxf(0.0, sin(TAU * 0.21 * t))
		var muestra_l := clampf(campana + pulso_bajo + pad + brillo, -1.0, 1.0)
		var muestra_r := clampf((campana * 0.92) + pulso_bajo + (pad * 1.08) - brillo, -1.0, 1.0)
		_playback.push_frame(Vector2(muestra_l, muestra_r))
		_sample_index += 1


func _envolvente_campana(local_t: float, step_duration: float) -> float:
	var ataque := clampf(local_t / 0.025, 0.0, 1.0)
	var decaimiento := exp(-4.2 * local_t / maxf(step_duration, 0.01))
	return ataque * decaimiento


func _midi_a_frecuencia(nota: int) -> float:
	return 440.0 * pow(2.0, (float(nota) - 69.0) / 12.0)
