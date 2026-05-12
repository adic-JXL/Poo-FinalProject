extends "res://Scripts/enemigo_base.gd"
class_name EnemigoPatrulla

@export var distancia_patruya: float = 120.0
@export var direccion_inicial: int = 1
@export var distancia_revision_borde: float = 18.0
@export var profundidad_revision_borde: float = 48.0

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
	elif is_on_floor() and not _hay_suelo_adelante():
		_direccion_actual *= -1.0
	elif is_on_wall():
		_direccion_actual *= -1.0

	mover_horizontal(_direccion_actual, delta)
	_actualizar_orientacion()


func _actualizar_orientacion() -> void:
	visual.scale.x = _direccion_actual * _escala_original_x


func _hay_suelo_adelante() -> bool:
	var origen := global_position + Vector2(_direccion_actual * distancia_revision_borde, 6.0)
	var destino := origen + Vector2(0.0, profundidad_revision_borde)
	var parametros := PhysicsRayQueryParameters2D.create(origen, destino)
	parametros.exclude = [self]
	parametros.collision_mask = collision_mask
	return not get_world_2d().direct_space_state.intersect_ray(parametros).is_empty()
