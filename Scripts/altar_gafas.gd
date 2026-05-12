extends "res://Scripts/interactivo_base.gd"
class_name AltarGafas

@export var color_inactivo: Color = Color(0.278431, 0.686275, 0.909804, 0.85)
@export var color_activo: Color = Color(0.988235, 0.866667, 0.364706, 0.98)

var _resuelto: bool = false

@onready var base_visual: Polygon2D = $BaseVisual
@onready var simbolo_visual: Polygon2D = $SimboloVisual


func _ready() -> void:
	super()
	mensaje_interaccion = "Presiona E para enfocar los simbolos del altar."
	_actualizar_visual()


func puede_interactuar() -> bool:
	return not _resuelto


func marcar_resuelto() -> void:
	_resuelto = true
	_actualizar_visual()
	desactivar_interaccion()


func esta_resuelto() -> bool:
	return _resuelto


func _actualizar_visual() -> void:
	var color_objetivo := color_activo if _resuelto else color_inactivo
	if base_visual != null:
		base_visual.color = color_objetivo

	if simbolo_visual != null:
		simbolo_visual.color = color_objetivo.lightened(0.12)
