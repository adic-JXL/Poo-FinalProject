extends "res://Scripts/interactivo_base.gd"
class_name LlaveInteractiva

var _reclamada: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	super()


func puede_interactuar() -> bool:
	return not _reclamada


func otorgar_llave() -> void:
	_reclamada = true
	collision_shape.set_deferred("disabled", true)
	desactivar_interaccion()
	hide()
