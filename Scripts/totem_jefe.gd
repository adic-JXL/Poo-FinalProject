extends "res://Scripts/interactivo_base.gd"
class_name TotemJefe

signal totem_activado(totem: TotemJefe)

@export var color_inactivo: Color = Color(0.22, 0.72, 0.95, 0.9)
@export var color_activo: Color = Color(0.98, 0.9, 0.35, 1.0)

var _activado: bool = false

@onready var base_visual: Polygon2D = $BaseVisual
@onready var nucleo_visual: Polygon2D = $NucleoVisual


func _ready() -> void:
	super()
	add_to_group("totem_jefe")
	mensaje_interaccion = "Presiona E para enfocar el sello con las gafas."
	_actualizar_visual()


func puede_interactuar() -> bool:
	return not _activado


func activar() -> bool:
	if _activado:
		return false

	_activado = true
	_actualizar_visual()
	desactivar_interaccion()
	emit_signal("totem_activado", self)
	return true


func reiniciar_totem() -> void:
	_activado = false
	monitoring = true
	monitorable = true
	_actualizar_visual()


func esta_activado() -> bool:
	return _activado


func _actualizar_visual() -> void:
	if base_visual != null:
		base_visual.color = color_activo if _activado else color_inactivo

	if nucleo_visual != null:
		nucleo_visual.color = color_activo.lightened(0.1) if _activado else color_inactivo.lightened(0.12)
