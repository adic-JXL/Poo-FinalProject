extends "res://Scripts/enemigo_base.gd"
class_name EnemigoPatrulla

@export var distancia_patruya: float = 120.0
@export var direccion_inicial: int = 1

var _origen_x: float = 0.0
var _direccion_actual: float = 1.0
var _escala_original_x: float = 1.0


func _inicializar_enemigo() -> void:
	_origen_x = global_position.x
	_direccion_actual = 1.0 if direccion_inicial >= 0 else -1.0
	_escala_original_x = absf(visual.scale.x)
	_actualizar_orientacion()


func _procesar_comportamiento(delta: float) -> void:
	var desplazamiento := global_position.x - _origen_x

	if desplazamiento >= distancia_patruya:
		_direccion_actual = -1.0
	elif desplazamiento <= -distancia_patruya:
		_direccion_actual = 1.0

	mover_horizontal(_direccion_actual, delta)
	_actualizar_orientacion()


func _actualizar_orientacion() -> void:
	visual.scale.x = _direccion_actual * _escala_original_x
