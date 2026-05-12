extends "res://Scripts/enemigo_base.gd"
class_name EnemigoPerseguidor

@export_group("Vision")
@export var rango_deteccion: float = 220.0
@export var angulo_vision_grados: float = 70.0
@export var fraccion_velocidad_jugador: float = 0.5
@export var tiempo_memoria_objetivo: float = 0.75
@export var direccion_inicial: int = -1

var _jugador_objetivo: Node2D = null
var _direccion_mirada: float = -1.0
var _escala_original_x: float = 1.0
var _tiempo_memoria_restante: float = 0.0
var _persiguiendo: bool = false

@onready var vision: Polygon2D = $Vision


func _inicializar_enemigo() -> void:
	_escala_original_x = absf(visual.scale.x)
	_direccion_mirada = -1.0 if direccion_inicial < 0 else 1.0
	_actualizar_visual()


func _procesar_comportamiento(delta: float) -> void:
	if _jugador_objetivo == null or not is_instance_valid(_jugador_objetivo):
		_jugador_objetivo = get_tree().get_first_node_in_group("jugador")

	if _jugador_objetivo == null:
		_persiguiendo = false
		detener(delta)
		_actualizar_visual()
		return

	if _puede_ver_objetivo(_jugador_objetivo):
		_tiempo_memoria_restante = tiempo_memoria_objetivo
		_persiguiendo = true
	else:
		_tiempo_memoria_restante = max(_tiempo_memoria_restante - delta, 0.0)
		_persiguiendo = _tiempo_memoria_restante > 0.0

	if _persiguiendo:
		var direccion := signf(_jugador_objetivo.global_position.x - global_position.x)
		if not is_zero_approx(direccion):
			_direccion_mirada = direccion

		var velocidad_persecucion := _obtener_velocidad_persecucion()
		mover_hacia_velocidad_objetivo(_direccion_mirada * velocidad_persecucion, delta)
	else:
		detener(delta)

	_actualizar_visual()


func esta_persiguiendo() -> bool:
	return _persiguiendo


func obtener_direccion_mirada() -> float:
	return _direccion_mirada


func obtener_velocidad_persecucion_actual() -> float:
	return _obtener_velocidad_persecucion()


func _obtener_velocidad_persecucion() -> float:
	if _jugador_objetivo != null and _jugador_objetivo.has_method("obtener_velocidad_base_para_enemigos"):
		return _jugador_objetivo.obtener_velocidad_base_para_enemigos() * fraccion_velocidad_jugador

	return velocidad * fraccion_velocidad_jugador


func _puede_ver_objetivo(objetivo: Node2D) -> bool:
	var desplazamiento := objetivo.global_position - global_position
	var distancia := desplazamiento.length()

	if distancia > rango_deteccion:
		return false

	if is_zero_approx(distancia):
		return true

	var hacia_objetivo := desplazamiento / distancia
	var frente := Vector2(_direccion_mirada, 0.0)
	var apertura := cos(deg_to_rad(angulo_vision_grados * 0.5))
	return frente.dot(hacia_objetivo) >= apertura


func _actualizar_visual() -> void:
	visual.scale.x = _direccion_mirada * _escala_original_x
	vision.scale.x = _direccion_mirada
	vision.color = Color(1.0, 0.45, 0.25, 0.22) if _persiguiendo else Color(1.0, 0.9, 0.2, 0.14)

	var semi_altura := tan(deg_to_rad(angulo_vision_grados * 0.5)) * rango_deteccion
	vision.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(rango_deteccion, -semi_altura),
		Vector2(rango_deteccion, semi_altura),
	])
