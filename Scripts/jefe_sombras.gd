extends "res://Scripts/enemigo_base.gd"
class_name JefeSombras

signal jefe_derrotado
signal fase_cambiada(fase_actual: int, sellos_activados: int)

@export var sellos_necesarios: int = 3
@export var color_base: Color = Color(0.7, 0.24, 0.2, 0.95)
@export var color_debilitado: Color = Color(0.96, 0.88, 0.35, 0.95)
@export var color_carga: Color = Color(1.0, 0.34, 0.18, 1.0)
@export var arena_min: Vector2 = Vector2(9655, -2)
@export var arena_max: Vector2 = Vector2(10470, 126)
@export var multiplicador_velocidad_por_fase: float = 0.16
@export var enfriamiento_embestida_base: float = 3.2
@export var duracion_carga_base: float = 0.85
@export var duracion_embestida: float = 0.24
@export var multiplicador_embestida: float = 2.35
@export var duracion_aturdimiento_sello: float = 0.95

enum EstadoJefe {
	ACECHO,
	CARGA,
	EMBESTIDA,
	ATURDIDO,
	DERROTADO,
}

var _jugador_objetivo: Node2D = null
var _escala_visual_original: Vector2 = Vector2.ONE
var _sellos_activados: int = 0
var _derrotado: bool = false
var _fase_actual: int = 1
var _estado_jefe: EstadoJefe = EstadoJefe.ACECHO
var _temporizador_estado: float = 0.0
var _enfriamiento_embestida: float = 0.0
var _direccion_embestida: Vector2 = Vector2.RIGHT
var _radio_ataque_base: float = 34.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var collision_ataque: CollisionShape2D = $AreaAtaque/CollisionShape2D
@onready var linea_carga: Line2D = $LineaCarga


func _inicializar_enemigo() -> void:
	usa_gravedad = false
	_sellos_activados = 0
	_derrotado = false
	_fase_actual = 1
	_estado_jefe = EstadoJefe.ACECHO
	_temporizador_estado = 0.0
	_enfriamiento_embestida = enfriamiento_embestida_base
	_escala_visual_original = visual.scale
	area_ataque.monitoring = true
	collision_shape.disabled = false
	_preparar_shape_ataque()
	visual.modulate = color_base
	visual.scale = _escala_visual_original
	_actualizar_linea_carga(false)


func _procesar_comportamiento(delta: float) -> void:
	if _derrotado:
		velocity = Vector2.ZERO
		return

	if _jugador_objetivo == null or not is_instance_valid(_jugador_objetivo):
		_jugador_objetivo = get_tree().get_first_node_in_group("jugador")

	if _jugador_objetivo == null:
		velocity = Vector2.ZERO
		return

	match _estado_jefe:
		EstadoJefe.ATURDIDO:
			_procesar_aturdimiento(delta)
			return
		EstadoJefe.CARGA:
			_procesar_carga(delta)
			return
		EstadoJefe.EMBESTIDA:
			_procesar_embestida(delta)
			return

	_procesar_acecho(delta)


func _post_procesar_movimiento() -> void:
	if _derrotado:
		return

	_limitar_a_arena()


func activar_sello() -> void:
	if _derrotado:
		return

	_sellos_activados += 1
	var progreso := clampf(float(_sellos_activados) / float(max(sellos_necesarios, 1)), 0.0, 1.0)
	visual.modulate = color_base.lerp(color_debilitado, progreso)

	if _sellos_activados >= sellos_necesarios:
		_derrotar()
		return

	_fase_actual = _sellos_activados + 1
	_estado_jefe = EstadoJefe.ATURDIDO
	_temporizador_estado = duracion_aturdimiento_sello
	_enfriamiento_embestida = max(1.1, enfriamiento_embestida_base - (_fase_actual * 0.25))
	_actualizar_radio_ataque()
	emit_signal("fase_cambiada", _fase_actual, _sellos_activados)


func esta_derrotado() -> bool:
	return _derrotado


func obtener_sellos_activados() -> int:
	return _sellos_activados


func obtener_fase_actual() -> int:
	return _fase_actual


func obtener_estado_jefe() -> StringName:
	match _estado_jefe:
		EstadoJefe.CARGA:
			return &"carga"
		EstadoJefe.EMBESTIDA:
			return &"embestida"
		EstadoJefe.ATURDIDO:
			return &"aturdido"
		EstadoJefe.DERROTADO:
			return &"derrotado"
		_:
			return &"acecho"


func _procesar_acecho(delta: float) -> void:
	var direccion := _jugador_objetivo.global_position - global_position
	if direccion.length() <= 2.0:
		velocity = Vector2.ZERO
		return

	velocity = direccion.normalized() * _obtener_velocidad_fase() * obtener_multiplicador_velocidad()
	visual.scale.x = signf(velocity.x) * absf(_escala_visual_original.x) if not is_zero_approx(velocity.x) else visual.scale.x
	_limitar_a_arena()

	if _fase_actual < 2:
		return

	_enfriamiento_embestida = max(_enfriamiento_embestida - delta, 0.0)
	if _enfriamiento_embestida > 0.0:
		return

	_empezar_carga()


func _procesar_carga(delta: float) -> void:
	velocity = Vector2.ZERO
	_temporizador_estado = max(_temporizador_estado - delta, 0.0)
	var pulso := 1.0 + (sin(Time.get_ticks_msec() * 0.02) * 0.08)
	visual.scale = Vector2(signf(visual.scale.x) * absf(_escala_visual_original.x) * pulso, _escala_visual_original.y * pulso)
	visual.modulate = color_carga
	_actualizar_linea_carga(true)

	if _temporizador_estado == 0.0:
		_estado_jefe = EstadoJefe.EMBESTIDA
		_temporizador_estado = duracion_embestida
		_actualizar_linea_carga(false)


func _procesar_embestida(delta: float) -> void:
	_temporizador_estado = max(_temporizador_estado - delta, 0.0)
	velocity = _direccion_embestida * _obtener_velocidad_fase() * multiplicador_embestida * obtener_multiplicador_velocidad()
	_limitar_a_arena()

	if _temporizador_estado == 0.0:
		_estado_jefe = EstadoJefe.ACECHO
		visual.scale = _escala_visual_original
		visual.modulate = color_base.lerp(color_debilitado, clampf(float(_sellos_activados) / float(max(sellos_necesarios, 1)), 0.0, 1.0))
		_enfriamiento_embestida = max(0.95, enfriamiento_embestida_base - (_fase_actual * 0.32))
		_actualizar_linea_carga(false)


func _procesar_aturdimiento(delta: float) -> void:
	_temporizador_estado = max(_temporizador_estado - delta, 0.0)
	velocity = Vector2.ZERO
	visual.scale = _escala_visual_original * 0.86
	_actualizar_linea_carga(false)

	if _temporizador_estado == 0.0:
		_estado_jefe = EstadoJefe.ACECHO
		visual.scale = _escala_visual_original


func _derrotar() -> void:
	_derrotado = true
	_estado_jefe = EstadoJefe.DERROTADO
	velocity = Vector2.ZERO
	area_ataque.monitoring = false
	collision_shape.disabled = true
	_actualizar_linea_carga(false)
	visual.modulate = Color(color_debilitado.r, color_debilitado.g, color_debilitado.b, 0.25)
	visual.scale = _escala_visual_original * 0.65
	emit_signal("jefe_derrotado")


func _empezar_carga() -> void:
	var direccion := _jugador_objetivo.global_position - global_position
	_direccion_embestida = direccion.normalized() if direccion.length() > 0.1 else Vector2.RIGHT
	_estado_jefe = EstadoJefe.CARGA
	_temporizador_estado = max(0.40, duracion_carga_base - (_fase_actual * 0.08))
	_actualizar_linea_carga(true)


func _obtener_velocidad_fase() -> float:
	return velocidad * (1.0 + ((_fase_actual - 1) * multiplicador_velocidad_por_fase))


func _preparar_shape_ataque() -> void:
	if collision_ataque == null or collision_ataque.shape == null:
		return

	collision_ataque.shape = collision_ataque.shape.duplicate()
	if collision_ataque.shape is CircleShape2D:
		_radio_ataque_base = (collision_ataque.shape as CircleShape2D).radius
	_actualizar_radio_ataque()


func _actualizar_radio_ataque() -> void:
	if collision_ataque == null or not (collision_ataque.shape is CircleShape2D):
		return

	(collision_ataque.shape as CircleShape2D).radius = _radio_ataque_base + ((_fase_actual - 1) * 5.0)


func _actualizar_linea_carga(visible: bool) -> void:
	if linea_carga == null:
		return

	linea_carga.visible = visible
	if not visible:
		return

	var alpha := 0.30 + (sin(Time.get_ticks_msec() * 0.026) * 0.12)
	linea_carga.default_color = Color(color_carga.r, color_carga.g, color_carga.b, alpha)
	linea_carga.points = PackedVector2Array([Vector2.ZERO, _direccion_embestida * 148.0])


func _limitar_a_arena() -> void:
	var posicion_anterior := global_position
	global_position.x = clampf(global_position.x, arena_min.x, arena_max.x)
	global_position.y = clampf(global_position.y, arena_min.y, arena_max.y)

	if not is_equal_approx(posicion_anterior.x, global_position.x):
		velocity.x = 0.0

	if not is_equal_approx(posicion_anterior.y, global_position.y):
		velocity.y = 0.0
