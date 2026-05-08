extends Area2D
class_name LlaveInteractiva

signal interaccion_solicitada
signal rango_interaccion_cambiado(activo: bool, mensaje: String)

@export var mensaje_interaccion: String = "Presiona E para investigar la llave."

var _jugador_en_rango: bool = false
var _reclamada: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func esta_en_rango() -> bool:
	return _jugador_en_rango and not _reclamada


func interactuar() -> void:
	if esta_en_rango():
		emit_signal("interaccion_solicitada")


func otorgar_llave() -> void:
	_reclamada = true
	_jugador_en_rango = false
	monitoring = false
	monitorable = false
	collision_shape.set_deferred("disabled", true)
	hide()
	emit_signal("rango_interaccion_cambiado", false, mensaje_interaccion)


func _on_body_entered(body: Node) -> void:
	if _reclamada:
		return

	if body.is_in_group("jugador"):
		_jugador_en_rango = true
		emit_signal("rango_interaccion_cambiado", true, mensaje_interaccion)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("jugador"):
		_jugador_en_rango = false
		emit_signal("rango_interaccion_cambiado", false, mensaje_interaccion)
