extends Area2D
class_name MuroCarne

signal jugador_alcanzado

@export var velocidad_base: float = 72.0
@export var amplitud_pulso: float = 0.04
@export var velocidad_pulso: float = 1.55
@export var adelanto_camara: float = 316.0
@export var tamano_textura: Vector2i = Vector2i(52, 188)
@export var volumen_rumble_db: float = -13.5

var _jugador: Node2D = null
var _activo: bool = true
var _congelado: bool = false
var _multiplicador_velocidad: float = 1.0
var _posicion_inicio: Vector2 = Vector2.ZERO

static var _textura_cuerpo_cache: Texture2D
static var _textura_ojo_cache: Texture2D
static var _textura_boca_cache: Texture2D
static var _stream_rumble_cache: AudioStreamWAV

@onready var visual: Node2D = $Visual
@onready var cuerpo: Sprite2D = $Visual/Cuerpo
@onready var ojo_izquierdo: Sprite2D = $Visual/OjoIzquierdo
@onready var ojo_derecho: Sprite2D = $Visual/OjoDerecho
@onready var boca: Sprite2D = $Visual/Boca

var _audio_rumble: AudioStreamPlayer2D = null


func _ready() -> void:
	add_to_group("muro_carne")
	_posicion_inicio = global_position
	body_entered.connect(_on_body_entered)
	_configurar_visual()
	_configurar_audio()


func _physics_process(delta: float) -> void:
	if not _activo or _congelado:
		_actualizar_audio(false)
		return

	global_position.x += obtener_velocidad_actual() * delta
	_animar_pulso()
	_actualizar_audio(true)


func configurar_objetivo(jugador: Node2D) -> void:
	_jugador = jugador


func establecer_activo(activo: bool) -> void:
	_activo = activo
	monitoring = activo
	monitorable = activo


func establecer_congelado(congelado: bool) -> void:
	_congelado = congelado
	if _congelado:
		_actualizar_audio(false)


func establecer_multiplicador_velocidad(multiplicador: float) -> void:
	_multiplicador_velocidad = max(multiplicador, 0.1)


func reiniciar(posicion_objetivo: Vector2 = Vector2.INF) -> void:
	if posicion_objetivo == Vector2.INF:
		posicion_objetivo = _posicion_inicio

	global_position = posicion_objetivo
	_posicion_inicio = posicion_objetivo
	visual.scale = Vector2.ONE
	establecer_activo(true)
	establecer_congelado(false)
	_actualizar_audio(true)


func obtener_velocidad_actual() -> float:
	return velocidad_base * _multiplicador_velocidad


func obtener_x_impulso_camara() -> float:
	return global_position.x + adelanto_camara


func _on_body_entered(body: Node) -> void:
	if body == null or not body.is_in_group("jugador"):
		return

	if not _activo:
		return

	emit_signal("jugador_alcanzado")


func _animar_pulso() -> void:
	if visual == null:
		return

	var pulso := sin(Time.get_ticks_msec() * 0.001 * velocidad_pulso)
	visual.scale = Vector2(1.0 + (pulso * amplitud_pulso * 0.55), 1.0 + (absf(pulso) * amplitud_pulso))


func _configurar_visual() -> void:
	if cuerpo != null:
		cuerpo.texture = _obtener_textura_cuerpo()
		cuerpo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	if ojo_izquierdo != null:
		ojo_izquierdo.texture = _obtener_textura_ojo()
		ojo_izquierdo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	if ojo_derecho != null:
		ojo_derecho.texture = _obtener_textura_ojo()
		ojo_derecho.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	if boca != null:
		boca.texture = _obtener_textura_boca()
		boca.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _configurar_audio() -> void:
	_audio_rumble = AudioStreamPlayer2D.new()
	_audio_rumble.name = "AudioRumble"
	_audio_rumble.bus = &"Master"
	_audio_rumble.volume_db = volumen_rumble_db
	_audio_rumble.max_distance = 1400.0
	_audio_rumble.attenuation = 1.05
	_audio_rumble.stream = _obtener_stream_rumble()
	add_child(_audio_rumble)


func _actualizar_audio(activo: bool) -> void:
	if _audio_rumble == null:
		return

	if not activo:
		if _audio_rumble.playing:
			_audio_rumble.stop()
		return

	if not _audio_rumble.playing:
		_audio_rumble.play()

	var factor_velocidad := clampf(obtener_velocidad_actual() / maxf(velocidad_base, 1.0), 0.75, 1.25)
	var mezcla_factor := (factor_velocidad - 0.75) / 0.5
	_audio_rumble.pitch_scale = lerpf(0.9, 1.08, clampf(mezcla_factor, 0.0, 1.0))
	_audio_rumble.volume_db = volumen_rumble_db + ((factor_velocidad - 1.0) * 4.0)


func _obtener_textura_cuerpo() -> Texture2D:
	if _textura_cuerpo_cache != null:
		return _textura_cuerpo_cache

	var ancho: int = maxi(tamano_textura.x, 24)
	var alto: int = maxi(tamano_textura.y, 96)
	var imagen := Image.create(ancho, alto, false, Image.FORMAT_RGBA8)
	var centro_x := float(ancho) * 0.5

	for y in range(alto):
		for x in range(ancho):
			var nx := float(x) / float(ancho)
			var ny := float(y) / float(alto)
			var curvatura := absf((x - centro_x) / centro_x)
			var vena := sin((ny * 22.0) + (nx * 13.0)) * 0.08
			var carne := Color(0.52, 0.14, 0.18, 1.0).lerp(Color(0.73, 0.22, 0.28, 1.0), ny * 0.45)
			var sombra := 0.16 + (curvatura * 0.21) + absf(sin((nx * 15.0) + (ny * 6.0))) * 0.05
			carne = carne.darkened(sombra - vena)
			if int(x + (y * 0.4)) % 11 == 0:
				carne = carne.lightened(0.08)
			if int(y + (x * 0.7)) % 17 == 0:
				carne = carne.darkened(0.12)
			if ny < 0.09 or ny > 0.92:
				carne = carne.darkened(0.18)
			imagen.set_pixel(x, y, carne)

	_textura_cuerpo_cache = ImageTexture.create_from_image(imagen)
	return _textura_cuerpo_cache


func _obtener_textura_ojo() -> Texture2D:
	if _textura_ojo_cache != null:
		return _textura_ojo_cache

	var imagen := Image.create(16, 10, false, Image.FORMAT_RGBA8)
	var centro := Vector2(7.5, 4.5)
	for y in range(imagen.get_height()):
		for x in range(imagen.get_width()):
			var punto := Vector2(x, y)
			var distancia := ((punto - centro) / Vector2(7.5, 4.2)).length()
			if distancia <= 1.0:
				var color := Color(0.98, 0.93, 0.72, 1.0)
				if distancia > 0.82:
					color = Color(0.20, 0.06, 0.08, 1.0)
				if absf(x - centro.x) < 1.4:
					color = Color(0.08, 0.03, 0.04, 1.0)
				imagen.set_pixel(x, y, color)
			else:
				imagen.set_pixel(x, y, Color(0, 0, 0, 0))

	_textura_ojo_cache = ImageTexture.create_from_image(imagen)
	return _textura_ojo_cache


func _obtener_textura_boca() -> Texture2D:
	if _textura_boca_cache != null:
		return _textura_boca_cache

	var imagen := Image.create(24, 12, false, Image.FORMAT_RGBA8)
	for y in range(imagen.get_height()):
		for x in range(imagen.get_width()):
			var color := Color(0, 0, 0, 0)
			if y >= 3 and y <= 8 and x >= 2 and x <= 21:
				color = Color(0.25, 0.04, 0.05, 1.0)
				if y == 3 or y == 8 or x == 2 or x == 21:
					color = Color(0.61, 0.16, 0.18, 1.0)
			if y <= 4 and x % 4 == 0 and x >= 4 and x <= 20:
				color = Color(0.95, 0.93, 0.86, 1.0)
			imagen.set_pixel(x, y, color)

	_textura_boca_cache = ImageTexture.create_from_image(imagen)
	return _textura_boca_cache


func _obtener_stream_rumble() -> AudioStreamWAV:
	if _stream_rumble_cache != null:
		return _stream_rumble_cache

	var sample_rate := 22050
	var duracion := 0.92
	var total_samples := int(sample_rate * duracion)
	var data := PackedByteArray()
	data.resize(total_samples * 2)
	for i in range(total_samples):
		var t := float(i) / float(sample_rate)
		var grave := sin(TAU * 28.0 * t) * 0.46
		var medio := sin(TAU * 47.0 * t + (sin(TAU * 0.9 * t) * 0.35)) * 0.18
		var vibracion := sin(TAU * 82.0 * t) * 0.06
		var muestra := (grave + medio + vibracion) * 0.52
		var valor := int(clampf(muestra, -1.0, 1.0) * 32767.0)
		data[i * 2] = valor & 0xFF
		data[(i * 2) + 1] = (valor >> 8) & 0xFF

	_stream_rumble_cache = AudioStreamWAV.new()
	_stream_rumble_cache.format = AudioStreamWAV.FORMAT_16_BITS
	_stream_rumble_cache.mix_rate = sample_rate
	_stream_rumble_cache.stereo = false
	_stream_rumble_cache.loop_mode = AudioStreamWAV.LOOP_FORWARD
	_stream_rumble_cache.loop_begin = 0
	_stream_rumble_cache.loop_end = total_samples
	_stream_rumble_cache.data = data
	return _stream_rumble_cache
