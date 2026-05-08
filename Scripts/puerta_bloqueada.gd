extends StaticBody2D
class_name PuertaBloqueada

signal interaccion_solicitada
signal rango_interaccion_cambiado(activo: bool, mensaje: String)

@export var mensaje_interaccion: String = "Presiona E para usar la puerta."
@export var color_bloqueada: Color = Color(1, 1, 1, 1)
@export var color_abierta: Color = Color(0.67, 1, 0.78, 1)

var _jugador_en_rango: bool = false
var _abierta: bool = false

@onready var sprite: Sprite2D = $Puerta
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area_interaccion: Area2D = $AreaInteraccion
@onready var area_interaccion_shape: CollisionShape2D = $AreaInteraccion/CollisionShape2D


func _ready() -> void:
	area_interaccion.body_entered.connect(_on_body_entered)
	area_interaccion.body_exited.connect(_on_body_exited)
	_actualizar_visual()


func esta_en_rango() -> bool:
	return _jugador_en_rango and not _abierta


func interactuar() -> void:
	if esta_en_rango():
		emit_signal("interaccion_solicitada")


func abrir() -> void:
	if _abierta:
		return

	_abierta = true
	_jugador_en_rango = false
	collision_shape.set_deferred("disabled", true)
	area_interaccion_shape.set_deferred("disabled", true)
	_actualizar_visual()
	emit_signal("rango_interaccion_cambiado", false, mensaje_interaccion)


func esta_abierta() -> bool:
	return _abierta


func _actualizar_visual() -> void:
	sprite.modulate = color_abierta if _abierta else color_bloqueada


func _on_body_entered(body: Node) -> void:
	if _abierta:
		return

	if body.is_in_group("jugador"):
		_jugador_en_rango = true
		emit_signal("rango_interaccion_cambiado", true, mensaje_interaccion)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("jugador"):
		_jugador_en_rango = false
		emit_signal("rango_interaccion_cambiado", false, mensaje_interaccion)
