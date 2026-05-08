extends Area2D
class_name InteractivoBase

signal interaccion_solicitada
signal rango_interaccion_cambiado(activo: bool, mensaje: String)

@export var mensaje_interaccion: String = "Presiona E para interactuar."

var _jugador_en_rango: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered_base)
	body_exited.connect(_on_body_exited_base)


func esta_en_rango() -> bool:
	return _jugador_en_rango and puede_interactuar()


func interactuar() -> void:
	if esta_en_rango():
		emit_signal("interaccion_solicitada")


func puede_interactuar() -> bool:
	return true


func desactivar_interaccion() -> void:
	monitoring = false
	monitorable = false
	_cambiar_rango_interaccion(false)


func _cambiar_rango_interaccion(activo: bool) -> void:
	if _jugador_en_rango == activo:
		return

	_jugador_en_rango = activo
	emit_signal("rango_interaccion_cambiado", _jugador_en_rango, mensaje_interaccion)


func _on_body_entered_base(body: Node) -> void:
	if body.is_in_group("jugador") and puede_interactuar():
		_cambiar_rango_interaccion(true)


func _on_body_exited_base(body: Node) -> void:
	if body.is_in_group("jugador"):
		_cambiar_rango_interaccion(false)
