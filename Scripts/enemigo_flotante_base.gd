extends "res://Scripts/enemigo_base.gd"
class_name EnemigoFlotanteBase

@export var distancia_flotacion: float = 70.0
@export var direccion_inicial: int = 1

var _origen: Vector2 = Vector2.ZERO
var _direccion_actual: float = 1.0


func _inicializar_enemigo() -> void:
	usa_gravedad = false
	_origen = global_position
	_direccion_actual = 1.0 if direccion_inicial >= 0 else -1.0


func _procesar_comportamiento(delta: float) -> void:
	var eje := obtener_eje_flotacion()
	var offset_actual := (global_position - _origen).dot(eje)

	if offset_actual >= distancia_flotacion:
		_direccion_actual = -1.0
	elif offset_actual <= -distancia_flotacion:
		_direccion_actual = 1.0

	velocity = eje * _direccion_actual * velocidad * obtener_multiplicador_velocidad()
	_actualizar_visual(eje)


func obtener_eje_flotacion() -> Vector2:
	return Vector2.RIGHT


func _actualizar_visual(eje: Vector2) -> void:
	if absf(eje.x) > 0.0:
		visual.scale.x = _direccion_actual * absf(visual.scale.x)
