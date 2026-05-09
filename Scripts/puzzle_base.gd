extends CanvasLayer
class_name PuzzleBase

signal completado
signal cancelado

@onready var panel_raiz: Control = $Control

var _activo: bool = false


func _ready() -> void:
	if panel_raiz != null:
		panel_raiz.hide()


func iniciar_puzzle() -> void:
	_activo = true

	if panel_raiz != null:
		panel_raiz.show()


func cerrar() -> void:
	_activo = false

	if panel_raiz != null:
		panel_raiz.hide()


func esta_visible() -> bool:
	return _activo and panel_raiz != null and panel_raiz.visible


func _emitir_completado() -> void:
	_activo = false
	emit_signal("completado")


func _emitir_cancelado() -> void:
	_activo = false
	emit_signal("cancelado")
