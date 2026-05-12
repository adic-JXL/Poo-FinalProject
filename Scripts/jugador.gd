extends CharacterBody2D
class_name Jugador

const SistemaEstaminaClass = preload("res://Scripts/sistema_estamina.gd")
const EstadoNormalClass = preload("res://Scripts/estado_jugador_normal.gd")
const EstadoSprintClass = preload("res://Scripts/estado_jugador_sprint.gd")
const EstadoBloqueadoClass = preload("res://Scripts/estado_jugador_bloqueado.gd")
const EstadoAturdidoClass = preload("res://Scripts/estado_jugador_aturdido.gd")

signal estado_cambiado(nuevo_estado: StringName)
signal vida_cambiada(vida_actual: int)
signal estamina_cambiada(actual: float, maxima: float)
signal sprint_cambiado(activo: bool)
signal invulnerabilidad_cambiada(activa: bool)
signal dano_recibido(cantidad: int, direccion: float)

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
@export var tiempo_invulnerabilidad: float = 1.0
@export var frecuencia_parpadeo_danio: float = 18.0
@export var fuerza_retroceso_x: float = 260.0
@export var fuerza_retroceso_y: float = 170.0
@export var duracion_aturdimiento: float = 0.22

var estado_actual: StringName = &"sin_estado"
var sistema_estamina

var _vida_inicial: int = 0
var _gravedad: float = 0.0
var _direccion_actual: float = 1.0
var _escala_original_x: float = 1.0
var _sprint_activo: bool = false
var _controles_habilitados: bool = true
var _estado_instancia_actual
var _estados: Dictionary = {}
var _tiempo_invulnerable_restante: float = 0.0
var _modulate_visual_original: Color = Color(1, 1, 1, 1)
var _tiempo_aturdimiento_restante: float = 0.0

@onready var visual: Node2D = $Visual


func _ready() -> void:
	add_to_group("jugador")
	_vida_inicial = max(vida, 1)
	_gravedad = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
	_escala_original_x = visual.scale.x
	_modulate_visual_original = visual.modulate

	sistema_estamina = SistemaEstaminaClass.new(estamina_maxima)
	sistema_estamina.valor_cambiado.connect(_on_estamina_valor_cambiado)
	_crear_estados()
	cambiar_a_estado(&"normal")

	emit_signal("vida_cambiada", vida)
	emit_signal("estamina_cambiada", sistema_estamina.actual, sistema_estamina.maxima)
	emit_signal("sprint_cambiado", _sprint_activo)


func _physics_process(delta: float) -> void:
	_actualizar_invulnerabilidad(delta)

	if estado_actual != &"bloqueado" and not is_on_floor():
		velocity.y += _gravedad * delta

	var direccion := obtener_input()
	var quiere_sprint := Input.is_action_pressed("sprint")
	var quiere_saltar := Input.is_action_just_pressed("saltar")
	procesar_estado_actual(delta, direccion, quiere_sprint, quiere_saltar)

	move_and_slide()

	if _controles_habilitados and not is_zero_approx(direccion):
		_actualizar_orientacion(direccion)


func obtener_input() -> float:
	return Input.get_axis("mover_izquierda", "mover_derecha")


func mover(direccion: float, delta: float) -> void:
	var multiplicador := multiplicador_sprint if _sprint_activo else 1.0
	mover_con_multiplicador(direccion, delta, multiplicador)


func mover_con_multiplicador(direccion: float, delta: float, multiplicador: float) -> void:
	var velocidad_objetivo := direccion * velocidad_base * multiplicador
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
		velocity.y = -fuerza_salto


func recibir_danio(cantidad: int, origen_x: float = 0.0) -> bool:
	if esta_invulnerable():
		return false

	vida = max(vida - cantidad, 0)
	emit_signal("vida_cambiada", vida)
	_activar_invulnerabilidad()
	_aplicar_retroceso(signf(global_position.x - origen_x))
	emit_signal("dano_recibido", cantidad, signf(global_position.x - origen_x))
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
	return not is_zero_approx(direccion) and sistema_estamina.actual > 0.0 and _controles_habilitados


func consumir_estamina_sprint(delta: float) -> bool:
	var costo: float = costo_sprint_por_segundo * delta
	return sistema_estamina.consumir(costo)


func regenerar_estamina(delta: float) -> void:
	sistema_estamina.regenerar(regeneracion_estamina_por_segundo * delta)


func obtener_estamina_actual() -> float:
	return sistema_estamina.actual


func obtener_estamina_maxima() -> float:
	return sistema_estamina.maxima


func obtener_velocidad_base_para_enemigos() -> float:
	return velocidad_base


func obtener_vida_inicial() -> int:
	return _vida_inicial


func esta_haciendo_sprint() -> bool:
	return _sprint_activo


func restaurar_para_respawn(posicion: Vector2) -> void:
	global_position = posicion
	velocity = Vector2.ZERO
	_tiempo_invulnerable_restante = 0.0
	_tiempo_aturdimiento_restante = 0.0
	visual.modulate = _modulate_visual_original
	vida = _vida_inicial
	sistema_estamina.reiniciar()
	establecer_sprint_activo(false)
	cambiar_a_estado(&"normal")
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


func _crear_estados() -> void:
	_estados = {
		&"normal": EstadoNormalClass.new(self),
		&"sprint": EstadoSprintClass.new(self),
		&"bloqueado": EstadoBloqueadoClass.new(self),
		&"aturdido": EstadoAturdidoClass.new(self),
	}


func _activar_invulnerabilidad() -> void:
	_tiempo_invulnerable_restante = max(tiempo_invulnerabilidad, 0.0)
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
