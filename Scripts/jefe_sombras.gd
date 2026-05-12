extends "res://Scripts/enemigo_base.gd"
class_name JefeSombras

signal jefe_derrotado

@export var sellos_necesarios: int = 3
@export var color_base: Color = Color(0.7, 0.24, 0.2, 0.95)
@export var color_debilitado: Color = Color(0.96, 0.88, 0.35, 0.95)

var _jugador_objetivo: Node2D = null
var _escala_visual_original: Vector2 = Vector2.ONE
var _sellos_activados: int = 0
var _derrotado: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _inicializar_enemigo() -> void:
	usa_gravedad = false
	_sellos_activados = 0
	_derrotado = false
	_escala_visual_original = visual.scale
	area_ataque.monitoring = true
	collision_shape.disabled = false
	visual.modulate = color_base


func _procesar_comportamiento(_delta: float) -> void:
	if _derrotado:
		velocity = Vector2.ZERO
		return

	if _jugador_objetivo == null or not is_instance_valid(_jugador_objetivo):
		_jugador_objetivo = get_tree().get_first_node_in_group("jugador")

	if _jugador_objetivo == null:
		velocity = Vector2.ZERO
		return

	var direccion := _jugador_objetivo.global_position - global_position
	if direccion.length() <= 2.0:
		velocity = Vector2.ZERO
		return

	velocity = direccion.normalized() * velocidad * obtener_multiplicador_velocidad()
	visual.scale.x = signf(velocity.x) * absf(_escala_visual_original.x) if not is_zero_approx(velocity.x) else visual.scale.x


func activar_sello() -> void:
	if _derrotado:
		return

	_sellos_activados += 1
	var progreso := clampf(float(_sellos_activados) / float(max(sellos_necesarios, 1)), 0.0, 1.0)
	visual.modulate = color_base.lerp(color_debilitado, progreso)

	if _sellos_activados >= sellos_necesarios:
		_derrotar()


func esta_derrotado() -> bool:
	return _derrotado


func obtener_sellos_activados() -> int:
	return _sellos_activados


func _derrotar() -> void:
	_derrotado = true
	velocity = Vector2.ZERO
	area_ataque.monitoring = false
	collision_shape.disabled = true
	visual.modulate = Color(color_debilitado.r, color_debilitado.g, color_debilitado.b, 0.25)
	emit_signal("jefe_derrotado")
