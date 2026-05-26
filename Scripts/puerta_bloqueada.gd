extends "res://Scripts/puerta_teletransporte.gd"
class_name PuertaBloqueada

var _abierta: bool = false


func _ready() -> void:
	transporte_habilitado = false
	super()


func puede_interactuar() -> bool:
	return not _abierta or permite_interaccion


func abrir(silencioso: bool = false) -> void:
	if _abierta:
		return

	_abierta = true
	establecer_transporte_habilitado(true)
	if silencioso:
		_actualizar_visual()
	else:
		reproducir_animacion_apertura()
	_cambiar_rango_interaccion(false)
	mensaje_interaccion = "Presiona E para cruzar la puerta." if permite_interaccion else "La puerta ya esta abierta."
	if permite_interaccion and monitoring:
		for body in get_overlapping_bodies():
			if body != null and body.is_in_group("jugador"):
				_cambiar_rango_interaccion(true)
				break


func esta_abierta() -> bool:
	return _abierta
