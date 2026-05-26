extends RefCounted
class_name SistemaEstamina

signal valor_cambiado(actual: float, maxima: float)

var maxima: float = 100.0
var actual: float = 100.0


func _init(valor_maximo: float = 100.0) -> void:
	maxima = max(valor_maximo, 1.0)
	actual = maxima


func consumir(cantidad: float) -> bool:
	if actual <= 0.0:
		return false

	actual = max(actual - max(cantidad, 0.0), 0.0)
	emit_signal("valor_cambiado", actual, maxima)
	return actual > 0.0


func regenerar(cantidad: float) -> void:
	if actual >= maxima:
		return

	actual = min(actual + max(cantidad, 0.0), maxima)
	emit_signal("valor_cambiado", actual, maxima)


func reiniciar() -> void:
	actual = maxima
	emit_signal("valor_cambiado", actual, maxima)


func porcentaje() -> float:
	return actual / maxima
