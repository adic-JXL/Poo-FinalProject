extends CharacterBody2D
class_name Jugador

const SistemaEstaminaClass = preload("res://Scripts/sistema_estamina.gd")
const EstadoNormalClass = preload("res://Scripts/estado_jugador_normal.gd")
const EstadoSprintClass = preload("res://Scripts/estado_jugador_sprint.gd")
const EstadoBloqueadoClass = preload("res://Scripts/estado_jugador_bloqueado.gd")

signal estado_cambiado(nuevo_estado: StringName)
signal vida_cambiada(vida_actual: int)
signal estamina_cambiada(actual: float, maxima: float)
signal sprint_cambiado(activo: bool)

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

var estado_actual: StringName = &"sin_estado"
var sistema_estamina

var _gravedad: float = 0.0
var _direccion_actual: float = 1.0
var _escala_original_x: float = 1.0
var _sprint_activo: bool = false
var _controles_habilitados: bool = true
var _estado_instancia_actual
var _estados: Dictionary = {}

@onready var visual: Node2D = $Visual


func _ready() -> void:
	add_to_group("jugador")
	_gravedad = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
	_escala_original_x = visual.scale.x

	sistema_estamina = SistemaEstaminaClass.new(estamina_maxima)
	sistema_estamina.valor_cambiado.connect(_on_estamina_valor_cambiado)
	_crear_estados()
	cambiar_a_estado(&"normal")

	emit_signal("vida_cambiada", vida)
	emit_signal("estamina_cambiada", sistema_estamina.actual, sistema_estamina.maxima)
	emit_signal("sprint_cambiado", _sprint_activo)


func _physics_process(delta: float) -> void:
	if _controles_habilitados and not is_on_floor():
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


func recibir_danio(cantidad: int) -> void:
	vida = max(vida - cantidad, 0)
	emit_signal("vida_cambiada", vida)


func cambiar_estado(nuevo_estado: StringName) -> void:
	cambiar_a_estado(nuevo_estado)


func cambiar_a_estado(nuevo_estado: StringName) -> void:
	if (estado_actual == nuevo_estado and _estado_instancia_actual != null) or not _estados.has(nuevo_estado):
		return

	if _estado_instancia_actual != null:
		_estado_instancia_actual.salir()

	estado_actual = nuevo_estado
	_controles_habilitados = estado_actual != &"bloqueado"
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


func esta_haciendo_sprint() -> bool:
	return _sprint_activo


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
	}
