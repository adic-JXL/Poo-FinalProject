extends "res://Scripts/puerta_teletransporte.gd"
class_name PuertaBloqueada

var _abierta: bool = false


func _ready() -> void:
	transporte_habilitado = false
	super()


func puede_interactuar() -> bool:
	return not _abierta


func abrir() -> void:
	if _abierta:
		return

	_abierta = true
	establecer_transporte_habilitado(true)
	_cambiar_rango_interaccion(false)
	mensaje_interaccion = "La puerta ya esta abierta."


func esta_abierta() -> bool:
	return _abierta
