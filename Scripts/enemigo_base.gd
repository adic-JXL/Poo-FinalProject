extends CharacterBody2D
class_name EnemigoBase

signal jugador_danado(cantidad: int)
signal vida_cambiada(vida_actual: int)

@export_group("Configuracion")
@export var vida: int = 1
@export var danio_contacto: int = 1
@export var tiempo_recarga_ataque: float = 1.0
@export var fuerza_retroceso_post_ataque_x: float = 72.0
@export var fuerza_retroceso_post_ataque_y: float = 20.0
@export var duracion_retroceso_post_ataque: float = 0.18

@export_group("Movimiento")
@export var velocidad: float = 70.0
@export var aceleracion: float = 900.0
@export var usa_gravedad: bool = true

@export_group("Audio")
@export var radio_audio_jugador: float = 360.0
@export var intervalo_audio_base_min: float = 2.1
@export var intervalo_audio_base_max: float = 4.6
@export var volumen_audio_base_db: float = -21.5
@export var volumen_audio_ataque_db: float = -16.5

var _gravedad: float = 0.0
var _puede_atacar: bool = true
var _congelado: bool = false
var _posicion_inicial: Vector2 = Vector2.ZERO
var _vida_inicial: int = 1
var _multiplicador_velocidad_temporal: float = 1.0
var _tiempo_retroceso_post_ataque_restante: float = 0.0
var _tiempo_audio_base_restante: float = 0.0
var _jugador_audio: Node2D = null
var _audio_base: AudioStreamPlayer2D = null
var _audio_ataque: AudioStreamPlayer2D = null
var _rng := RandomNumberGenerator.new()

static var _stream_audio_base_cache: AudioStreamWAV
static var _stream_audio_ataque_cache: AudioStreamWAV

@onready var visual: Node2D = $Visual
@onready var area_ataque: Area2D = $AreaAtaque
@onready var temporizador_ataque: Timer = $TemporizadorAtaque


func _ready() -> void:
	add_to_group("enemigo")
	_rng.randomize()
	_gravedad = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
	_posicion_inicial = global_position
	_vida_inicial = max(vida, 1)
	area_ataque.body_entered.connect(_on_area_ataque_body_entered)
	temporizador_ataque.timeout.connect(_on_temporizador_ataque_timeout)
	_configurar_audio()
	_inicializar_enemigo()
	emit_signal("vida_cambiada", vida)


func _physics_process(delta: float) -> void:
	if _congelado:
		velocity = Vector2.ZERO
		if _audio_base != null and _audio_base.playing:
			_audio_base.stop()
		return

	_actualizar_audio(delta)

	if usa_gravedad and not is_on_floor():
		velocity.y += _gravedad * delta

	if _tiempo_retroceso_post_ataque_restante > 0.0:
		_tiempo_retroceso_post_ataque_restante = max(_tiempo_retroceso_post_ataque_restante - delta, 0.0)
		move_and_slide()
		_post_procesar_movimiento()
		return

	_procesar_comportamiento(delta)
	move_and_slide()
	_post_procesar_movimiento()
	_intentar_atacar_colisiones_directas()
	_intentar_atacar_cuerpos_superpuestos()


func mover_horizontal(direccion: float, delta: float, multiplicador: float = 1.0) -> void:
	var velocidad_objetivo := direccion * velocidad * multiplicador * _multiplicador_velocidad_temporal
	mover_hacia_velocidad_objetivo(velocidad_objetivo, delta)


func mover_hacia_velocidad_objetivo(velocidad_objetivo: float, delta: float) -> void:
	velocity.x = move_toward(velocity.x, velocidad_objetivo, aceleracion * delta)


func detener(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, aceleracion * delta)


func recibir_danio(cantidad: int) -> void:
	vida = max(vida - cantidad, 0)
	emit_signal("vida_cambiada", vida)

	if vida == 0:
		queue_free()


func establecer_congelado(congelado: bool) -> void:
	_congelado = congelado

	if _congelado:
		velocity = Vector2.ZERO
		if _audio_base != null and _audio_base.playing:
			_audio_base.stop()


func esta_congelado() -> bool:
	return _congelado


func establecer_multiplicador_velocidad(factor: float) -> void:
	_multiplicador_velocidad_temporal = max(factor, 0.0)


func obtener_multiplicador_velocidad() -> float:
	return _multiplicador_velocidad_temporal


func reiniciar_enemigo() -> void:
	global_position = _posicion_inicial
	velocity = Vector2.ZERO
	vida = _vida_inicial
	_puede_atacar = true
	_congelado = false
	_multiplicador_velocidad_temporal = 1.0
	_tiempo_retroceso_post_ataque_restante = 0.0
	_tiempo_audio_base_restante = 0.0
	temporizador_ataque.stop()
	if _audio_base != null:
		_audio_base.stop()
	if _audio_ataque != null:
		_audio_ataque.stop()
	_inicializar_enemigo()
	emit_signal("vida_cambiada", vida)


func _inicializar_enemigo() -> void:
	pass


func _procesar_comportamiento(delta: float) -> void:
	detener(delta)


func _post_procesar_movimiento() -> void:
	pass


func _puede_danar_objetivo(objetivo: Node) -> bool:
	return _puede_atacar and objetivo.is_in_group("jugador") and objetivo.has_method("recibir_danio")


func _atacar_objetivo(objetivo: Node) -> void:
	if not objetivo.recibir_danio(danio_contacto, global_position.x):
		return

	_reproducir_audio_ataque()
	_aplicar_retroceso_post_ataque(objetivo)
	_puede_atacar = false
	temporizador_ataque.start(tiempo_recarga_ataque)
	emit_signal("jugador_danado", danio_contacto)


func _on_area_ataque_body_entered(body: Node) -> void:
	if _puede_danar_objetivo(body):
		_atacar_objetivo(body)


func _on_temporizador_ataque_timeout() -> void:
	_puede_atacar = true


func _intentar_atacar_cuerpos_superpuestos() -> void:
	if not _puede_atacar or area_ataque == null or not area_ataque.monitoring:
		return

	for body in area_ataque.get_overlapping_bodies():
		if _puede_danar_objetivo(body):
			_atacar_objetivo(body)
			return


func _intentar_atacar_colisiones_directas() -> void:
	if not _puede_atacar:
		return

	for indice in range(get_slide_collision_count()):
		var collision := get_slide_collision(indice)
		var collider = collision.get_collider()

		if _puede_danar_objetivo(collider):
			_atacar_objetivo(collider)
			return


func _aplicar_retroceso_post_ataque(objetivo: Node) -> void:
	if duracion_retroceso_post_ataque <= 0.0 or fuerza_retroceso_post_ataque_x <= 0.0:
		return

	var objetivo_2d := objetivo as Node2D
	var direccion := -signf((objetivo_2d.global_position.x if objetivo_2d != null else global_position.x) - global_position.x)
	if is_zero_approx(direccion):
		direccion = -signf(velocity.x) if not is_zero_approx(velocity.x) else -1.0

	velocity.x = direccion * fuerza_retroceso_post_ataque_x
	if usa_gravedad and fuerza_retroceso_post_ataque_y > 0.0 and is_on_floor():
		velocity.y = -fuerza_retroceso_post_ataque_y
	_tiempo_retroceso_post_ataque_restante = duracion_retroceso_post_ataque


func _configurar_audio() -> void:
	_audio_base = AudioStreamPlayer2D.new()
	_audio_base.name = "AudioBase"
	_audio_base.bus = &"Master"
	_audio_base.volume_db = volumen_audio_base_db
	_audio_base.max_distance = 900.0
	_audio_base.attenuation = 1.25
	_audio_base.stream = _obtener_stream_audio_base()
	add_child(_audio_base)

	_audio_ataque = AudioStreamPlayer2D.new()
	_audio_ataque.name = "AudioAtaque"
	_audio_ataque.bus = &"Master"
	_audio_ataque.volume_db = volumen_audio_ataque_db
	_audio_ataque.max_distance = 960.0
	_audio_ataque.attenuation = 1.15
	_audio_ataque.stream = _obtener_stream_audio_ataque()
	add_child(_audio_ataque)

	_tiempo_audio_base_restante = _rng.randf_range(intervalo_audio_base_min, intervalo_audio_base_max)


func _actualizar_audio(delta: float) -> void:
	if _audio_base == null:
		return

	_tiempo_audio_base_restante = max(_tiempo_audio_base_restante - delta, 0.0)
	if _tiempo_audio_base_restante > 0.0:
		return

	var jugador_actual := _obtener_jugador_audio()
	if jugador_actual == null:
		_tiempo_audio_base_restante = 0.9
		return

	if global_position.distance_squared_to(jugador_actual.global_position) > pow(radio_audio_jugador, 2.0):
		_tiempo_audio_base_restante = 0.8
		return

	_audio_base.pitch_scale = _rng.randf_range(0.93, 1.07)
	_audio_base.stop()
	_audio_base.play()
	_tiempo_audio_base_restante = _rng.randf_range(intervalo_audio_base_min, intervalo_audio_base_max)


func _reproducir_audio_ataque() -> void:
	if _audio_ataque == null:
		return

	_audio_ataque.pitch_scale = _rng.randf_range(0.94, 1.09)
	_audio_ataque.stop()
	_audio_ataque.play()


func _obtener_jugador_audio() -> Node2D:
	if _jugador_audio != null and is_instance_valid(_jugador_audio):
		return _jugador_audio

	var jugadores := get_tree().get_nodes_in_group("jugador")
	if jugadores.is_empty():
		return null

	_jugador_audio = jugadores[0] as Node2D
	return _jugador_audio


func _obtener_stream_audio_base() -> AudioStreamWAV:
	if _stream_audio_base_cache != null:
		return _stream_audio_base_cache

	var sample_rate := 22050
	var duracion := 0.46
	var total_samples := int(sample_rate * duracion)
	var data := PackedByteArray()
	data.resize(total_samples * 2)
	for i in range(total_samples):
		var t := float(i) / float(sample_rate)
		var envelope := sin(clampf(t / duracion, 0.0, 1.0) * PI)
		var grave := sin(TAU * 82.0 * t) * 0.38
		var medio := sin(TAU * 126.0 * t + (sin(TAU * 6.0 * t) * 0.15)) * 0.18
		var raspado := sin(TAU * 164.0 * t) * 0.08
		var muestra := (grave + medio + raspado) * envelope * 0.42
		var valor := int(clampf(muestra, -1.0, 1.0) * 32767.0)
		data[i * 2] = valor & 0xFF
		data[(i * 2) + 1] = (valor >> 8) & 0xFF

	_stream_audio_base_cache = AudioStreamWAV.new()
	_stream_audio_base_cache.format = AudioStreamWAV.FORMAT_16_BITS
	_stream_audio_base_cache.mix_rate = sample_rate
	_stream_audio_base_cache.stereo = false
	_stream_audio_base_cache.loop_mode = AudioStreamWAV.LOOP_DISABLED
	_stream_audio_base_cache.data = data
	return _stream_audio_base_cache


func _obtener_stream_audio_ataque() -> AudioStreamWAV:
	if _stream_audio_ataque_cache != null:
		return _stream_audio_ataque_cache

	var sample_rate := 22050
	var duracion := 0.18
	var total_samples := int(sample_rate * duracion)
	var data := PackedByteArray()
	data.resize(total_samples * 2)
	for i in range(total_samples):
		var t := float(i) / float(sample_rate)
		var envelope := 1.0 - clampf(t / duracion, 0.0, 1.0)
		var golpe := sin(TAU * 118.0 * t) * 0.62
		var chasquido := sin(TAU * 214.0 * t) * 0.22
		var muestra := (golpe + chasquido) * envelope * 0.5
		var valor := int(clampf(muestra, -1.0, 1.0) * 32767.0)
		data[i * 2] = valor & 0xFF
		data[(i * 2) + 1] = (valor >> 8) & 0xFF

	_stream_audio_ataque_cache = AudioStreamWAV.new()
	_stream_audio_ataque_cache.format = AudioStreamWAV.FORMAT_16_BITS
	_stream_audio_ataque_cache.mix_rate = sample_rate
	_stream_audio_ataque_cache.stereo = false
	_stream_audio_ataque_cache.loop_mode = AudioStreamWAV.LOOP_DISABLED
	_stream_audio_ataque_cache.data = data
	return _stream_audio_ataque_cache
