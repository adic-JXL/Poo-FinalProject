extends Area2D
class_name CheckpointActivador

signal checkpoint_alcanzado(posicion: Vector2, mensaje: String)

@export var mensaje_activacion: String = "Checkpoint activado."
@export var activar_una_sola_vez: bool = true
@export var color_inactivo: Color = Color(0.22, 0.95, 0.54, 0.95)
@export var color_activo: Color = Color(0.99, 0.92, 0.38, 1.0)

var _activado: bool = false

@onready var punto_visible: Polygon2D = $"../PuntoVisible"


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_actualizar_visual()


func esta_activado() -> bool:
	return _activado


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("jugador"):
		return

	if _activado and activar_una_sola_vez:
		return

	_activado = true
	_actualizar_visual()
	emit_signal("checkpoint_alcanzado", get_parent().global_position, mensaje_activacion)


func _actualizar_visual() -> void:
	if punto_visible == null:
		return

	punto_visible.color = color_activo if _activado else color_inactivo
