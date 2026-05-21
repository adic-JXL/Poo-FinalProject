extends CharacterBody2D
class_name Jugador

const SistemaEstaminaClass = preload("res://Scripts/sistema_estamina.gd")
const HabilidadGafasClass = preload("res://Scripts/habilidad_gafas.gd")
const EstadoNormalClass = preload("res://Scripts/estado_jugador_normal.gd")
const EstadoSprintClass = preload("res://Scripts/estado_jugador_sprint.gd")
const EstadoBloqueadoClass = preload("res://Scripts/estado_jugador_bloqueado.gd")
const EstadoAturdidoClass = preload("res://Scripts/estado_jugador_aturdido.gd")
const RUTAS_TEXTURAS_IDLE := [
	"res://Imagenes/Personaje/idle_00.png",
	"res://Imagenes/Personaje/idle_01.png",
	"res://Imagenes/Personaje/idle_02.png",
	"res://Imagenes/Personaje/idle_03.png",
]
const RUTAS_TEXTURAS_CAMINAR := [
	"res://Imagenes/Personaje/walk_00.png",
	"res://Imagenes/Personaje/walk_01.png",
	"res://Imagenes/Personaje/walk_02.png",
	"res://Imagenes/Personaje/walk_03.png",
]
const RUTAS_TEXTURAS_CORRER := [
	"res://Imagenes/Personaje/run_00.png",
	"res://Imagenes/Personaje/run_01.png",
	"res://Imagenes/Personaje/run_02.png",
	"res://Imagenes/Personaje/run_03.png",
]
const RUTAS_TEXTURAS_SALTAR := [
	"res://Imagenes/Personaje/jump_00.png",
	"res://Imagenes/Personaje/jump_01.png",
	"res://Imagenes/Personaje/jump_02.png",
	"res://Imagenes/Personaje/jump_03.png",
	"res://Imagenes/Personaje/jump_04.png",
]
const RUTAS_TEXTURAS_DANIO := [
	"res://Imagenes/Personaje/hurt_00.png",
	"res://Imagenes/Personaje/hurt_01.png",
	"res://Imagenes/Personaje/hurt_02.png",
]
const RUTAS_TEXTURAS_MUERTE := [
	"res://Imagenes/Personaje/death_00.png",
	"res://Imagenes/Personaje/death_01.png",
	"res://Imagenes/Personaje/death_02.png",
	"res://Imagenes/Personaje/death_03.png",
]
static var _stream_pisada_cache: AudioStreamWAV
static var _stream_gafas_cache: AudioStreamWAV
static var _stream_danio_cache: AudioStreamWAV

signal estado_cambiado(nuevo_estado: StringName)
signal vida_cambiada(vida_actual: int)
signal estamina_cambiada(actual: float, maxima: float)
signal sprint_cambiado(activo: bool)
signal invulnerabilidad_cambiada(activa: bool)
signal dano_recibido(cantidad: int, direccion: float)
signal gafas_actualizadas(activa: bool, duracion_restante: float, cooldown_restante: float, cooldown_actual: float, siguiente_cooldown: float)

@export_group("Configuracion")
@export var nombre: String = "Protagonista"
@export var vida: int = 3

@export_group("Movimiento")
@export var velocidad_base: float = 260.0
@export var fuerza_salto: float = 420.0
@export var aceleracion: float = 1600.0
@export var desaceleracion: float = 1800.0
@export var multiplicador_sprint: float = 1.75

@export_group("Estamina")
@export var estamina_maxima: float = 100.0
@export var costo_sprint_por_segundo: float = 35.0
@export var regeneracion_estamina_por_segundo: float = 24.0

@export_group("Combate")
@export var tiempo_invulnerabilidad: float = 1.3
@export var frecuencia_parpadeo_danio: float = 18.0
@export var fuerza_retroceso_x: float = 320.0
@export var fuerza_retroceso_y: float = 205.0
@export var duracion_aturdimiento: float = 0.3
@export var tiempo_invulnerabilidad_respawn: float = 1.35

@export_group("Gafas")
@export var gafas_duracion: float = 10.0
@export var gafas_cooldown_base: float = 2.0
@export var gafas_incremento_cooldown: float = 1.5
@export var gafas_cooldown_maximo: float = 10.0
@export var gafas_bonus_velocidad: float = 0.05
@export var gafas_bonus_salto: float = 0.15

@export_group("Game Feel")
@export var intervalo_particulas_sprint: float = 0.055
@export var velocidad_animacion_idle: float = 5.0
@export var velocidad_animacion_movimiento: float = 10.0
@export var velocidad_animacion_correr: float = 13.5
@export var velocidad_animacion_salto: float = 9.0
@export var duracion_animacion_muerte: float = 0.9
@export var espera_respawn_muerte: float = 0.8
@export var intervalo_pisadas_caminar: float = 0.34
@export var intervalo_pisadas_correr: float = 0.22
@export var color_polvo_sprint: Color = Color(0.58, 0.52, 0.39, 0.72)
@export var color_chispa_gafas: Color = Color(0.73, 1.0, 0.55, 0.95)
@export var color_chispa_danio: Color = Color(1.0, 0.36, 0.2, 0.9)

var estado_actual: StringName = &"sin_estado"
var sistema_estamina
var habilidad_gafas

var _vida_inicial: int = 0
var _gravedad: float = 0.0
var _direccion_actual: float = 1.0
var _escala_original_x: float = 1.0
var _escala_visual_original: Vector2 = Vector2.ONE
var _posicion_visual_original: Vector2 = Vector2.ZERO
var _sprint_activo: bool = false
var _controles_habilitados: bool = true
var _estado_instancia_actual
var _estados: Dictionary = {}
var _tiempo_invulnerable_restante: float = 0.0
var _modulate_visual_original: Color = Color(1, 1, 1, 1)
var _tiempo_aturdimiento_restante: float = 0.0
var _animacion_puerta_activa: bool = false
var _muerte_activa: bool = false
var _gafas_activas_previas: bool = false
var _tiempo_particula_sprint: float = 0.0
var _tiempo_pisada_restante: float = 0.0
var _tiempo_animacion_visual: float = 0.0
var _indice_frame_visual: int = 0
var _animacion_visual_actual: StringName = &"idle"
var _frames_idle: Array[Texture2D] = []
var _frames_caminar: Array[Texture2D] = []
var _frames_correr: Array[Texture2D] = []
var _frames_saltar: Array[Texture2D] = []
var _texturas_jugador_danio: Array[Texture2D] = []
var _frames_muerte: Array[Texture2D] = []

@onready var visual: Node2D = $Visual
@onready var sprite_visual: Sprite2D = get_node_or_null("Visual/Sprite2D") as Sprite2D
@onready var audio_pisadas: AudioStreamPlayer = get_node_or_null("AudioPisadas") as AudioStreamPlayer
@onready var audio_gafas: AudioStreamPlayer = get_node_or_null("AudioGafas") as AudioStreamPlayer
@onready var audio_danio: AudioStreamPlayer = get_node_or_null("AudioDanio") as AudioStreamPlayer


func _ready() -> void:
	add_to_group("jugador")
	_vida_inicial = max(vida, 1)
	_gravedad = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
	_escala_original_x = visual.scale.x
	_escala_visual_original = visual.scale
	_posicion_visual_original = visual.position
	_modulate_visual_original = visual.modulate

	sistema_estamina = SistemaEstaminaClass.new(estamina_maxima)
	sistema_estamina.valor_cambiado.connect(_on_estamina_valor_cambiado)
	habilidad_gafas = HabilidadGafasClass.new(gafas_duracion, gafas_cooldown_base, gafas_incremento_cooldown, gafas_cooldown_maximo)
	habilidad_gafas.estado_actualizado.connect(_on_gafas_estado_actualizado)
	_crear_estados()
	cambiar_a_estado(&"normal")

	_cargar_texturas_jugador()
	_configurar_audio()
	_establecer_textura_jugador(_obtener_frame_idle_actual())

	emit_signal("vida_cambiada", vida)
	emit_signal("estamina_cambiada", sistema_estamina.actual, sistema_estamina.maxima)
	emit_signal("sprint_cambiado", _sprint_activo)
	emit_signal("gafas_actualizadas", habilidad_gafas.esta_activa(), habilidad_gafas.obtener_duracion_restante(), habilidad_gafas.obtener_cooldown_restante(), habilidad_gafas.obtener_cooldown_actual(), habilidad_gafas.obtener_cooldown_siguiente())


func _physics_process(delta: float) -> void:
	if _muerte_activa:
		velocity = Vector2.ZERO
		return

	_actualizar_invulnerabilidad(delta)
	habilidad_gafas.actualizar(delta)

	if _animacion_puerta_activa:
		return

	if estado_actual != &"bloqueado" and not is_on_floor():
		velocity.y += _gravedad * delta

	var direccion := obtener_input()
	var quiere_sprint := Input.is_action_pressed("sprint")
	var quiere_saltar := Input.is_action_just_pressed("saltar")
	if _controles_habilitados and Input.is_action_just_pressed("usar_gafas"):
		activar_gafas()
	procesar_estado_actual(delta, direccion, quiere_sprint, quiere_saltar)

	move_and_slide()

	if _controles_habilitados and not is_zero_approx(direccion):
		_actualizar_orientacion(direccion)

	_actualizar_pisadas(delta, direccion)
	_actualizar_particulas_sprint(delta)
	_actualizar_animacion_visual(delta, direccion)


func obtener_input() -> float:
	return Input.get_axis("mover_izquierda", "mover_derecha")


func mover(direccion: float, delta: float) -> void:
	var multiplicador := multiplicador_sprint if _sprint_activo else 1.0
	mover_con_multiplicador(direccion, delta, multiplicador)


func mover_con_multiplicador(direccion: float, delta: float, multiplicador: float) -> void:
	var velocidad_objetivo := direccion * obtener_velocidad_movimiento_actual() * multiplicador
	var ajuste := aceleracion if not is_zero_approx(direccion) else desaceleracion
	velocity.x = move_toward(velocity.x, velocidad_objetivo, ajuste * delta)


func actualizar_movimiento_horizontal(direccion: float, quiere_sprint: bool, delta: float) -> void:
	procesar_estado_actual(delta, direccion, quiere_sprint, false)


func procesar_estado_actual(delta: float, direccion: float, quiere_sprint: bool, quiere_saltar: bool) -> void:
	if _estado_instancia_actual == null:
		return

	_estado_instancia_actual.procesar(delta, direccion, quiere_sprint, quiere_saltar)


func saltar() -> void:
	if is_on_floor():
		velocity.y = -obtener_fuerza_salto_actual()


func recibir_danio(cantidad: int, origen_x: float = 0.0) -> bool:
	if vida <= 0 or esta_invulnerable() or _muerte_activa:
		return false

	var direccion_danio := signf(global_position.x - origen_x)
	vida = max(vida - cantidad, 0)
	emit_signal("vida_cambiada", vida)
	_emitir_chispas_danio(direccion_danio)
	_reproducir_sonido_danio()
	if vida <= 0:
		velocity = Vector2.ZERO
		cambiar_a_estado(&"bloqueado")
		return true

	_activar_invulnerabilidad()
	_aplicar_retroceso(direccion_danio)
	emit_signal("dano_recibido", cantidad, direccion_danio)
	return true


func cambiar_estado(nuevo_estado: StringName) -> void:
	cambiar_a_estado(nuevo_estado)


func cambiar_a_estado(nuevo_estado: StringName) -> void:
	if (estado_actual == nuevo_estado and _estado_instancia_actual != null) or not _estados.has(nuevo_estado):
		return

	if _estado_instancia_actual != null:
		_estado_instancia_actual.salir()

	estado_actual = nuevo_estado
	_controles_habilitados = estado_actual != &"bloqueado" and estado_actual != &"aturdido"
	_estado_instancia_actual = _estados[estado_actual]
	_estado_instancia_actual.entrar()
	emit_signal("estado_cambiado", estado_actual)


func establecer_control_habilitado(activo: bool) -> void:
	if activo:
		cambiar_a_estado(&"normal")
		return

	cambiar_a_estado(&"bloqueado")


func tiene_control_habilitado() -> bool:
	return _controles_habilitados


func esta_invulnerable() -> bool:
	return _tiempo_invulnerable_restante > 0.0


func esta_aturdido() -> bool:
	return _tiempo_aturdimiento_restante > 0.0


func puede_activar_sprint(direccion: float) -> bool:
	return not is_zero_approx(direccion) and _controles_habilitados and (gafas_activas() or sistema_estamina.actual > 0.0)


func consumir_estamina_sprint(delta: float) -> bool:
	if gafas_activas():
		if sistema_estamina.actual < sistema_estamina.maxima:
			sistema_estamina.reiniciar()
		return true

	var costo: float = costo_sprint_por_segundo * delta
	return sistema_estamina.consumir(costo)


func regenerar_estamina(delta: float) -> void:
	sistema_estamina.regenerar(regeneracion_estamina_por_segundo * delta)


func obtener_estamina_actual() -> float:
	return sistema_estamina.actual


func obtener_estamina_maxima() -> float:
	return sistema_estamina.maxima


func obtener_velocidad_base_para_enemigos() -> float:
	return obtener_velocidad_movimiento_actual()


func obtener_velocidad_movimiento_actual() -> float:
	return velocidad_base * _obtener_factor_buff_velocidad_gafas()


func obtener_fuerza_salto_actual() -> float:
	return fuerza_salto * _obtener_factor_buff_salto_gafas()


func obtener_vida_inicial() -> int:
	return _vida_inicial


func activar_gafas() -> bool:
	var activada: bool = habilidad_gafas.intentar_activar()
	if activada:
		_emitir_chispas_gafas()
		_reproducir_sonido_gafas()
	return activada


func gafas_activas() -> bool:
	return habilidad_gafas.esta_activa()


func obtener_duracion_gafas_restante() -> float:
	return habilidad_gafas.obtener_duracion_restante()


func obtener_cooldown_gafas_restante() -> float:
	return habilidad_gafas.obtener_cooldown_restante()


func obtener_siguiente_cooldown_gafas() -> float:
	return habilidad_gafas.obtener_cooldown_siguiente()


func obtener_cooldown_actual_gafas() -> float:
	return habilidad_gafas.obtener_cooldown_actual()


func esta_haciendo_sprint() -> bool:
	return _sprint_activo


func esta_en_animacion_puerta() -> bool:
	return _animacion_puerta_activa


func esta_en_animacion_muerte() -> bool:
	return _muerte_activa


func reproducir_muerte() -> void:
	if _muerte_activa:
		return

	_muerte_activa = true
	velocity = Vector2.ZERO
	_tiempo_invulnerable_restante = 0.0
	_tiempo_aturdimiento_restante = 0.0
	_tiempo_pisada_restante = 0.0
	cambiar_a_estado(&"bloqueado")
	if audio_pisadas != null:
		audio_pisadas.stop()
	visual.modulate = _modulate_visual_original
	visual.rotation = 0.0
	visual.position = _posicion_visual_original

	var frames := _frames_muerte if not _frames_muerte.is_empty() else _frames_idle
	var duracion_frame := duracion_animacion_muerte / float(max(frames.size(), 1))
	for frame in frames:
		_establecer_textura_jugador(frame)
		await get_tree().create_timer(duracion_frame, true, false, true).timeout

	await get_tree().create_timer(espera_respawn_muerte, true, false, true).timeout


func animar_entrada_puerta(posicion_objetivo: Vector2, duracion: float = 0.24) -> void:
	_animacion_puerta_activa = true
	velocity = Vector2.ZERO
	cambiar_a_estado(&"bloqueado")

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "global_position", posicion_objetivo, duracion)

	var escala_destino := Vector2(signf(_direccion_actual) * absf(_escala_visual_original.x) * 0.2, _escala_visual_original.y * 0.2)
	var color_destino := _modulate_visual_original
	color_destino.a = 0.12
	tween.tween_property(visual, "scale", escala_destino, duracion)
	tween.tween_property(visual, "modulate", color_destino, duracion)
	await tween.finished


func animar_salida_puerta(posicion_origen: Vector2, posicion_objetivo: Vector2, duracion: float = 0.34) -> void:
	_animacion_puerta_activa = true
	velocity = Vector2.ZERO
	global_position = posicion_origen
	cambiar_a_estado(&"bloqueado")

	var escala_origen := Vector2(signf(_direccion_actual if not is_zero_approx(_direccion_actual) else 1.0) * absf(_escala_visual_original.x) * 0.22, _escala_visual_original.y * 0.22)
	var color_origen := _modulate_visual_original
	color_origen.a = 0.08
	visual.scale = escala_origen
	visual.modulate = color_origen

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "global_position", posicion_objetivo, duracion)
	tween.tween_property(visual, "scale", _escala_visual_original, duracion)
	tween.tween_property(visual, "modulate", _modulate_visual_original, duracion * 0.82)
	await tween.finished
	finalizar_animacion_puerta()


func finalizar_animacion_puerta() -> void:
	_animacion_puerta_activa = false
	velocity = Vector2.ZERO
	_restaurar_visual_base()
	cambiar_a_estado(&"normal")


func restaurar_para_respawn(posicion: Vector2) -> void:
	global_position = posicion
	velocity = Vector2.ZERO
	_tiempo_invulnerable_restante = 0.0
	_tiempo_aturdimiento_restante = 0.0
	_animacion_puerta_activa = false
	_muerte_activa = false
	_restaurar_visual_base()
	vida = _vida_inicial
	sistema_estamina.reiniciar()
	habilidad_gafas.reiniciar()
	establecer_sprint_activo(false)
	_tiempo_particula_sprint = 0.0
	_tiempo_pisada_restante = 0.0
	estado_actual = &"sin_estado"
	_estado_instancia_actual = null
	cambiar_a_estado(&"normal")
	_activar_invulnerabilidad(tiempo_invulnerabilidad_respawn)
	emit_signal("vida_cambiada", vida)


func procesar_retroceso(delta: float) -> void:
	_tiempo_aturdimiento_restante = max(_tiempo_aturdimiento_restante - delta, 0.0)
	velocity.x = move_toward(velocity.x, 0.0, desaceleracion * 0.9 * delta)

	if _tiempo_aturdimiento_restante == 0.0:
		cambiar_a_estado(&"normal")


func _actualizar_orientacion(direccion: float) -> void:
	_direccion_actual = signf(direccion)
	visual.scale.x = _direccion_actual * _escala_original_x


func establecer_sprint_activo(activo: bool) -> void:
	if _sprint_activo == activo:
		return

	_sprint_activo = activo
	emit_signal("sprint_cambiado", _sprint_activo)


func _on_estamina_valor_cambiado(actual: float, maxima: float) -> void:
	emit_signal("estamina_cambiada", actual, maxima)


func _on_gafas_estado_actualizado(activa: bool, duracion_restante: float, cooldown_restante: float, cooldown_actual: float, siguiente_cooldown: float) -> void:
	if activa != _gafas_activas_previas:
		_gafas_activas_previas = activa
		_cargar_texturas_jugador()
	emit_signal("gafas_actualizadas", activa, duracion_restante, cooldown_restante, cooldown_actual, siguiente_cooldown)


func _crear_estados() -> void:
	_estados = {
		&"normal": EstadoNormalClass.new(self),
		&"sprint": EstadoSprintClass.new(self),
		&"bloqueado": EstadoBloqueadoClass.new(self),
		&"aturdido": EstadoAturdidoClass.new(self),
	}


func _activar_invulnerabilidad(duracion: float = -1.0) -> void:
	var duracion_objetivo := tiempo_invulnerabilidad if duracion < 0.0 else duracion
	_tiempo_invulnerable_restante = max(duracion_objetivo, 0.0)
	if _tiempo_invulnerable_restante > 0.0:
		emit_signal("invulnerabilidad_cambiada", true)


func _actualizar_invulnerabilidad(delta: float) -> void:
	if _tiempo_invulnerable_restante <= 0.0:
		if visual.modulate != _modulate_visual_original:
			visual.modulate = _modulate_visual_original
		return

	_tiempo_invulnerable_restante = max(_tiempo_invulnerable_restante - delta, 0.0)
	var fase: float = sin((_tiempo_invulnerable_restante * frecuencia_parpadeo_danio) * TAU)
	var alpha: float = 0.35 if fase > 0.0 else 1.0
	visual.modulate = Color(_modulate_visual_original.r, _modulate_visual_original.g, _modulate_visual_original.b, alpha)
	_actualizar_textura_danio()

	if _tiempo_invulnerable_restante == 0.0:
		visual.modulate = _modulate_visual_original
		emit_signal("invulnerabilidad_cambiada", false)


func _aplicar_retroceso(direccion: float) -> void:
	var direccion_empuje := direccion
	if is_zero_approx(direccion_empuje):
		direccion_empuje = -_direccion_actual if not is_zero_approx(_direccion_actual) else 1.0

	velocity.x = direccion_empuje * fuerza_retroceso_x
	velocity.y = -fuerza_retroceso_y
	_tiempo_aturdimiento_restante = duracion_aturdimiento
	cambiar_a_estado(&"aturdido")


func _restaurar_visual_base() -> void:
	_animacion_visual_actual = &"idle"
	_indice_frame_visual = 0
	_tiempo_animacion_visual = 0.0
	visual.scale = Vector2(_direccion_actual * absf(_escala_visual_original.x), _escala_visual_original.y)
	visual.position = _posicion_visual_original
	visual.rotation = 0.0
	visual.modulate = _modulate_visual_original
	_establecer_textura_jugador(_obtener_frame_idle_actual())


func _obtener_factor_buff_velocidad_gafas() -> float:
	return 1.0 + gafas_bonus_velocidad if gafas_activas() else 1.0


func _obtener_factor_buff_salto_gafas() -> float:
	return 1.0 + gafas_bonus_salto if gafas_activas() else 1.0


func _establecer_textura_jugador(textura: Texture2D) -> void:
	if sprite_visual == null or textura == null:
		return

	sprite_visual.texture = textura


func _actualizar_textura_danio() -> void:
	if sprite_visual == null or _texturas_jugador_danio.is_empty():
		return

	var indice := int(floor(_tiempo_invulnerable_restante * 12.0)) % _texturas_jugador_danio.size()
	sprite_visual.texture = _texturas_jugador_danio[indice]


func _actualizar_animacion_visual(delta: float, direccion: float) -> void:
	if sprite_visual == null or _frames_idle.is_empty() or esta_invulnerable():
		return

	var en_suelo := is_on_floor()
	var moviendose := en_suelo and absf(direccion) > 0.05 and absf(velocity.x) > 5.0
	var animacion_objetivo: StringName = &"idle"
	if not en_suelo:
		animacion_objetivo = &"jump"
	elif moviendose:
		animacion_objetivo = &"run" if _sprint_activo else &"walk"

	if _animacion_visual_actual != animacion_objetivo:
		_animacion_visual_actual = animacion_objetivo
		_indice_frame_visual = 0
		_tiempo_animacion_visual = 0.0

	var frames := _obtener_frames_animacion(animacion_objetivo)
	if frames.is_empty():
		frames = _frames_idle

	if animacion_objetivo == &"jump":
		_aplicar_frame_salto(frames)
	elif not frames.is_empty():
		var velocidad_frames := velocidad_animacion_idle
		if animacion_objetivo == &"walk":
			velocidad_frames = velocidad_animacion_movimiento
		elif animacion_objetivo == &"run":
			velocidad_frames = velocidad_animacion_correr

		_tiempo_animacion_visual += delta
		if _tiempo_animacion_visual >= 1.0 / max(velocidad_frames, 0.1):
			_tiempo_animacion_visual = 0.0
			_indice_frame_visual = (_indice_frame_visual + 1) % frames.size()
		sprite_visual.texture = frames[_indice_frame_visual]

	if moviendose:
		var pulso := sin(Time.get_ticks_msec() * 0.025)
		var compresion := absf(pulso)
		var intensidad := 1.28 if _sprint_activo else 1.0
		visual.position = _posicion_visual_original + Vector2(0, pulso * 2.4)
		visual.rotation = deg_to_rad(pulso * (3.4 if _sprint_activo else 1.8))
		visual.scale = Vector2(
			_direccion_actual * absf(_escala_visual_original.x) * (1.0 - (compresion * 0.028 * intensidad)),
			_escala_visual_original.y * (1.0 + (compresion * 0.038 * intensidad))
		)
		return

	if animacion_objetivo == &"jump":
		var torsion := clampf(velocity.y / max(obtener_fuerza_salto_actual(), 1.0), -1.0, 1.0)
		visual.position = _posicion_visual_original + Vector2(0.0, clampf(velocity.y * 0.012, -4.0, 3.0))
		visual.rotation = deg_to_rad(torsion * 3.4)
		visual.scale = Vector2(
			_direccion_actual * absf(_escala_visual_original.x) * (1.0 + (maxf(-torsion, 0.0) * 0.03)),
			_escala_visual_original.y * (1.0 - (maxf(-torsion, 0.0) * 0.035))
		)
		return

	visual.position = _posicion_visual_original
	visual.rotation = 0.0
	visual.scale = Vector2(_direccion_actual * absf(_escala_visual_original.x), _escala_visual_original.y)


func _obtener_frames_animacion(animacion: StringName) -> Array[Texture2D]:
	match animacion:
		&"walk":
			return _frames_caminar
		&"run":
			return _frames_correr
		&"jump":
			return _frames_saltar
		_:
			return _frames_idle


func _aplicar_frame_salto(frames: Array[Texture2D]) -> void:
	if frames.is_empty():
		return

	var indice := frames.size() - 1
	if velocity.y < -170.0:
		indice = 0
	elif velocity.y < -50.0:
		indice = min(1, frames.size() - 1)
	elif absf(velocity.y) <= 45.0:
		indice = min(2, frames.size() - 1)
	elif velocity.y < 180.0:
		indice = min(3, frames.size() - 1)

	_indice_frame_visual = indice
	sprite_visual.texture = frames[_indice_frame_visual]


func _actualizar_particulas_sprint(delta: float) -> void:
	if not _sprint_activo or not is_on_floor() or absf(velocity.x) < velocidad_base * 0.45:
		_tiempo_particula_sprint = 0.0
		return

	_tiempo_particula_sprint = max(_tiempo_particula_sprint - delta, 0.0)
	if _tiempo_particula_sprint > 0.0:
		return

	_tiempo_particula_sprint = intervalo_particulas_sprint
	var origen := global_position + Vector2(-_direccion_actual * 7.0, 18.0)
	var desplazamiento := Vector2(-_direccion_actual * randf_range(12.0, 30.0), randf_range(-12.0, -4.0))
	_crear_particula(origen, desplazamiento, color_polvo_sprint, randf_range(2.2, 3.8), 0.34)


func _actualizar_pisadas(delta: float, direccion: float) -> void:
	if _muerte_activa or _animacion_puerta_activa or not is_on_floor() or absf(direccion) <= 0.05 or absf(velocity.x) < 32.0:
		_tiempo_pisada_restante = 0.0
		return

	_tiempo_pisada_restante = max(_tiempo_pisada_restante - delta, 0.0)
	if _tiempo_pisada_restante > 0.0:
		return

	_reproducir_sonido_pisada()
	_tiempo_pisada_restante = intervalo_pisadas_correr if _sprint_activo else intervalo_pisadas_caminar


func _emitir_chispas_gafas() -> void:
	for i in range(12):
		var angulo := (TAU / 12.0) * float(i) + randf_range(-0.22, 0.22)
		var desplazamiento := Vector2(cos(angulo), sin(angulo)) * randf_range(18.0, 35.0)
		var origen := global_position + Vector2(randf_range(-4.0, 4.0), randf_range(-12.0, 8.0))
		var color := color_chispa_gafas.lerp(Color(0.35, 0.95, 1.0, 0.95), randf())
		_crear_particula(origen, desplazamiento, color, randf_range(2.0, 4.0), randf_range(0.22, 0.38))


func _configurar_audio() -> void:
	if audio_pisadas != null:
		audio_pisadas.bus = &"Master"
		audio_pisadas.volume_db = -13.0
		audio_pisadas.stream = _obtener_stream_pisada()

	if audio_gafas != null:
		audio_gafas.bus = &"Master"
		audio_gafas.volume_db = -8.5
		audio_gafas.stream = _obtener_stream_gafas()

	if audio_danio != null:
		audio_danio.bus = &"Master"
		audio_danio.volume_db = -7.2
		audio_danio.stream = _obtener_stream_danio()


func _reproducir_sonido_pisada() -> void:
	if audio_pisadas == null:
		return

	audio_pisadas.pitch_scale = randf_range(0.985, 1.015) + (0.02 if _sprint_activo else 0.0)
	audio_pisadas.stop()
	audio_pisadas.play()


func _reproducir_sonido_gafas() -> void:
	if audio_gafas == null:
		return

	audio_gafas.pitch_scale = randf_range(0.99, 1.03)
	audio_gafas.stop()
	audio_gafas.play()


func _reproducir_sonido_danio() -> void:
	if audio_danio == null:
		return

	audio_danio.pitch_scale = randf_range(0.97, 1.02)
	audio_danio.stop()
	audio_danio.play()


func _emitir_chispas_danio(direccion_danio: float) -> void:
	var direccion := direccion_danio if not is_zero_approx(direccion_danio) else -_direccion_actual
	for _i in range(8):
		var desplazamiento := Vector2(direccion * randf_range(16.0, 38.0), randf_range(-26.0, -8.0))
		var origen := global_position + Vector2(randf_range(-6.0, 6.0), randf_range(-10.0, 12.0))
		_crear_particula(origen, desplazamiento, color_chispa_danio, randf_range(2.0, 3.5), randf_range(0.18, 0.3))


func _crear_particula(origen_global: Vector2, desplazamiento: Vector2, color_particula: Color, tamano: float, duracion: float) -> void:
	var contenedor := get_parent()
	if contenedor == null:
		contenedor = self

	var particula := Polygon2D.new()
	var mitad := tamano * 0.5
	particula.polygon = PackedVector2Array([
		Vector2(-mitad, -mitad),
		Vector2(mitad, -mitad),
		Vector2(mitad, mitad),
		Vector2(-mitad, mitad),
	])
	particula.color = color_particula
	particula.z_index = 20
	contenedor.add_child(particula)
	particula.global_position = origen_global

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(particula, "global_position", origen_global + desplazamiento, duracion)
	tween.tween_property(particula, "modulate:a", 0.0, duracion)
	tween.tween_property(particula, "scale", Vector2.ZERO, duracion)
	tween.finished.connect(particula.queue_free, CONNECT_ONE_SHOT)


func _cargar_texturas_jugador() -> void:
	var active := false
	if habilidad_gafas != null:
		active = habilidad_gafas.esta_activa()
	var prefijo := "res://Imagenes/Personaje_Girl/con_gafas/" if active else "res://Imagenes/Personaje_Girl/sin_gafas/"

	_frames_idle.clear()
	for i in range(4):
		var ruta := prefijo + "idle/idle_%02d.png" % i
		var tex := _cargar_textura_png(ruta)
		if tex != null:
			_frames_idle.append(tex)

	_frames_caminar.clear()
	for i in range(4):
		var ruta := prefijo + "walk/walk_%02d.png" % i
		var tex := _cargar_textura_png(ruta)
		if tex != null:
			_frames_caminar.append(tex)

	_frames_correr.clear()
	for i in range(4):
		var ruta := prefijo + "run/run_%02d.png" % i
		var tex := _cargar_textura_png(ruta)
		if tex != null:
			_frames_correr.append(tex)

	_frames_saltar.clear()
	for i in range(5):
		var ruta := prefijo + "jump/jump_%02d.png" % i
		var tex := _cargar_textura_png(ruta)
		if tex != null:
			_frames_saltar.append(tex)

	_texturas_jugador_danio.clear()
	for i in range(3):
		var ruta := prefijo + "hurt/hurt_%02d.png" % i
		var tex := _cargar_textura_png(ruta)
		if tex != null:
			_texturas_jugador_danio.append(tex)

	_frames_muerte.clear()
	for i in range(4):
		var ruta := prefijo + "death/death_%02d.png" % i
		var tex := _cargar_textura_png(ruta)
		if tex != null:
			_frames_muerte.append(tex)

	if _frames_idle.is_empty():
		_frames_idle.append(_cargar_textura_png("res://Imagenes/Personaje/player_idle.png"))
	if _frames_caminar.is_empty():
		_frames_caminar = _frames_idle.duplicate()
	if _frames_correr.is_empty():
		_frames_correr = _frames_caminar.duplicate()
	if _frames_saltar.is_empty():
		_frames_saltar = _frames_caminar.duplicate()


func _cargar_secuencia_png(rutas: Array) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	for ruta in rutas:
		var textura := _cargar_textura_png(ruta)
		if textura != null:
			frames.append(textura)

	return frames


func _obtener_frame_idle_actual() -> Texture2D:
	if _frames_idle.is_empty():
		return null

	return _frames_idle[clampi(_indice_frame_visual, 0, _frames_idle.size() - 1)]


func _cargar_textura_png(ruta: String) -> Texture2D:
	var imagen := Image.load_from_file(ProjectSettings.globalize_path(ruta))
	if imagen == null or imagen.is_empty():
		return null

	return ImageTexture.create_from_image(imagen)


func _obtener_stream_pisada() -> AudioStreamWAV:
	if _stream_pisada_cache != null:
		return _stream_pisada_cache

	var sample_rate := 22050
	var duracion := 0.12
	var total_samples := int(sample_rate * duracion)
	var data := PackedByteArray()
	data.resize(total_samples * 2)
	var ruido := 0.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 84129
	for i in range(total_samples):
		var t := float(i) / float(sample_rate)
		var envelope := exp(-20.0 * t)
		var golpe := sin(TAU * 74.0 * t) * 0.22 * exp(-26.0 * t)
		var objetivo_ruido := (rng.randf() * 2.0 - 1.0) * 0.34
		ruido = lerpf(ruido, objetivo_ruido, 0.18)
		var crujido_pasto := ruido * (0.52 + (0.18 * sin(TAU * 34.0 * t)))
		var muestra := (golpe + crujido_pasto) * envelope * 0.92
		var valor := int(clampf(muestra, -1.0, 1.0) * 32767.0)
		data[i * 2] = valor & 0xFF
		data[(i * 2) + 1] = (valor >> 8) & 0xFF

	_stream_pisada_cache = AudioStreamWAV.new()
	_stream_pisada_cache.format = AudioStreamWAV.FORMAT_16_BITS
	_stream_pisada_cache.mix_rate = sample_rate
	_stream_pisada_cache.stereo = false
	_stream_pisada_cache.loop_mode = AudioStreamWAV.LOOP_DISABLED
	_stream_pisada_cache.data = data
	return _stream_pisada_cache


func _obtener_stream_gafas() -> AudioStreamWAV:
	if _stream_gafas_cache != null:
		return _stream_gafas_cache

	var sample_rate := 22050
	var duracion := 0.46
	var total_samples := int(sample_rate * duracion)
	var data := PackedByteArray()
	data.resize(total_samples * 2)
	for i in range(total_samples):
		var t := float(i) / float(sample_rate)
		var envelope := exp(-5.6 * t)
		var tono_a := sin(TAU * 420.0 * t)
		var tono_b := sin(TAU * 640.0 * t + 0.18)
		var brillo := sin(TAU * 920.0 * t + sin(TAU * 5.0 * t) * 0.18) * 0.12
		var shimmer := sin(TAU * 8.5 * t) * 0.05
		var muestra := (tono_a * 0.30 + tono_b * 0.20 + brillo * 0.08 + shimmer) * envelope * 0.88
		var valor := int(clampf(muestra, -1.0, 1.0) * 32767.0)
		data[i * 2] = valor & 0xFF
		data[(i * 2) + 1] = (valor >> 8) & 0xFF

	_stream_gafas_cache = AudioStreamWAV.new()
	_stream_gafas_cache.format = AudioStreamWAV.FORMAT_16_BITS
	_stream_gafas_cache.mix_rate = sample_rate
	_stream_gafas_cache.stereo = false
	_stream_gafas_cache.loop_mode = AudioStreamWAV.LOOP_DISABLED
	_stream_gafas_cache.data = data
	return _stream_gafas_cache


func _obtener_stream_danio() -> AudioStreamWAV:
	if _stream_danio_cache != null:
		return _stream_danio_cache

	var sample_rate := 22050
	var duracion := 0.22
	var total_samples := int(sample_rate * duracion)
	var data := PackedByteArray()
	data.resize(total_samples * 2)
	for i in range(total_samples):
		var t := float(i) / float(sample_rate)
		var envelope := exp(-10.5 * t)
		var golpe := sin(TAU * 182.0 * t) * 0.34
		var aspereza := sin(TAU * 318.0 * t + sin(TAU * 21.0 * t) * 0.35) * 0.18
		var aire := sin(TAU * 640.0 * t) * 0.06
		var muestra := (golpe + aspereza + aire) * envelope * 0.92
		var valor := int(clampf(muestra, -1.0, 1.0) * 32767.0)
		data[i * 2] = valor & 0xFF
		data[(i * 2) + 1] = (valor >> 8) & 0xFF

	_stream_danio_cache = AudioStreamWAV.new()
	_stream_danio_cache.format = AudioStreamWAV.FORMAT_16_BITS
	_stream_danio_cache.mix_rate = sample_rate
	_stream_danio_cache.stereo = false
	_stream_danio_cache.loop_mode = AudioStreamWAV.LOOP_DISABLED
	_stream_danio_cache.data = data
	return _stream_danio_cache
