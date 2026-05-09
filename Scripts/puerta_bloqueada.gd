extends "res://Scripts/interactivo_base.gd"
class_name PuertaBloqueada

@export var color_bloqueada: Color = Color(1, 1, 1, 1)
@export var color_abierta: Color = Color(0.67, 1, 0.78, 1)

var _abierta: bool = false

@onready var sprite: Sprite2D = $Puerta
@onready var collision_shape: CollisionShape2D = $CuerpoSolido/CollisionShape2D
@onready var area_interaccion_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	super()
	_actualizar_visual()


func puede_interactuar() -> bool:
	return not _abierta


func abrir() -> void:
	if _abierta:
		return

	_abierta = true
	collision_shape.set_deferred("disabled", true)
	area_interaccion_shape.set_deferred("disabled", true)
	desactivar_interaccion()
	_actualizar_visual()


func esta_abierta() -> bool:
	return _abierta


func _actualizar_visual() -> void:
	sprite.modulate = color_abierta if _abierta else color_bloqueada
