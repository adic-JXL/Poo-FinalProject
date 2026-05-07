extends CharacterBody2D
class_name Jugador

signal estado_cambiado(nuevo_estado: StringName)
signal vida_cambiada(vida_actual: int)

@export var nombre: String = "Protagonista"
@export var vida: int = 3
@export var velocidad_base: float = 260.0
@export var fuerza_salto: float = 420.0
@export var aceleracion: float = 1600.0
@export var desaceleracion: float = 1800.0

var estado_actual: StringName = &"normal"
var _gravedad: float = 0.0
var _direccion_actual: float = 1.0

@onready var visual: Node2D = $Visual


func _ready() -> void:
	_gravedad = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
	emit_signal("vida_cambiada", vida)
	emit_signal("estado_cambiado", estado_actual)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += _gravedad * delta

	var direccion := obtener_input()
	mover(direccion, delta)

	if Input.is_action_just_pressed("saltar"):
		saltar()

	move_and_slide()
	_actualizar_orientacion(direccion)


func obtener_input() -> float:
	return Input.get_axis("mover_izquierda", "mover_derecha")


func mover(direccion: float, delta: float) -> void:
	var velocidad_objetivo := direccion * velocidad_base
	var ajuste := aceleracion if not is_zero_approx(direccion) else desaceleracion
	velocity.x = move_toward(velocity.x, velocidad_objetivo, ajuste * delta)


func saltar() -> void:
	if is_on_floor():
		velocity.y = -fuerza_salto


func recibir_danio(cantidad: int) -> void:
	vida = max(vida - cantidad, 0)
	emit_signal("vida_cambiada", vida)


func cambiar_estado(nuevo_estado: StringName) -> void:
	if estado_actual == nuevo_estado:
		return

	estado_actual = nuevo_estado
	emit_signal("estado_cambiado", estado_actual)


func _actualizar_orientacion(direccion: float) -> void:
	if is_zero_approx(direccion):
		return

	_direccion_actual = signf(direccion)
	visual.scale.x = _direccion_actual
