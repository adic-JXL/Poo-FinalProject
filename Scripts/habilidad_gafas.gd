extends RefCounted
class_name HabilidadGafas

signal estado_actualizado(activa: bool, duracion_restante: float, cooldown_restante: float, cooldown_actual: float, siguiente_cooldown: float)

var duracion: float = 10.0
var cooldown_base: float = 2.0
var incremento_cooldown: float = 1.5
var cooldown_maximo: float = 10.0

var _activa: bool = false
var _duracion_restante: float = 0.0
var _cooldown_restante: float = 0.0
var _cooldown_actual: float = 2.0
var _cooldown_siguiente: float = 2.0


func _init(duracion_base: float = 10.0, cooldown_inicial: float = 2.0, incremento: float = 1.5, cooldown_max: float = 10.0) -> void:
	duracion = max(duracion_base, 0.1)
	cooldown_base = max(cooldown_inicial, 0.1)
	incremento_cooldown = max(incremento, 0.0)
	cooldown_maximo = max(cooldown_max, cooldown_base)
	_cooldown_actual = cooldown_base
	_cooldown_siguiente = cooldown_base
	_emitir_estado()


func intentar_activar() -> bool:
	if _activa or _cooldown_restante > 0.0:
		return false

	_activa = true
	_duracion_restante = duracion
	_emitir_estado()
	return true


func actualizar(delta: float) -> void:
	var cambio := false

	if _activa:
		_duracion_restante = max(_duracion_restante - delta, 0.0)
		cambio = true

		if _duracion_restante == 0.0:
			_activa = false
			_cooldown_actual = _cooldown_siguiente
			_cooldown_restante = _cooldown_actual
			_cooldown_siguiente = min(_cooldown_siguiente + incremento_cooldown, cooldown_maximo)

	elif _cooldown_restante > 0.0:
		_cooldown_restante = max(_cooldown_restante - delta, 0.0)
		cambio = true

	if cambio:
		_emitir_estado()


func reiniciar() -> void:
	_activa = false
	_duracion_restante = 0.0
	_cooldown_restante = 0.0
	_cooldown_actual = cooldown_base
	_cooldown_siguiente = cooldown_base
	_emitir_estado()


func esta_activa() -> bool:
	return _activa


func obtener_duracion_restante() -> float:
	return _duracion_restante


func obtener_cooldown_restante() -> float:
	return _cooldown_restante


func obtener_cooldown_siguiente() -> float:
	return _cooldown_siguiente


func obtener_cooldown_actual() -> float:
	return _cooldown_actual


func _emitir_estado() -> void:
	emit_signal("estado_actualizado", _activa, _duracion_restante, _cooldown_restante, _cooldown_actual, _cooldown_siguiente)
