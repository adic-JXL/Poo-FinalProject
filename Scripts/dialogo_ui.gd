extends CanvasLayer
class_name DialogoUI

signal linea_cambiada(indice: int, total: int)
signal dialogo_cerrado

@onready var panel_raiz: Control = $Control
@onready var retrato_root: Node2D = $Control/PanelContainer/MarginContainer/HBoxContainer/RetratoPanel/SubViewportContainer/SubViewport/RetratoRoot
@onready var nombre_label: Label = $Control/PanelContainer/MarginContainer/HBoxContainer/TextoContainer/NombreLabel
@onready var texto_label: Label = $Control/PanelContainer/MarginContainer/HBoxContainer/TextoContainer/TextoLabel
@onready var progreso_label: Label = $Control/PanelContainer/MarginContainer/HBoxContainer/TextoContainer/ProgresoLabel
@onready var siguiente_boton: Button = $Control/PanelContainer/MarginContainer/HBoxContainer/TextoContainer/Botones/SiguienteBoton
@onready var cerrar_boton: Button = $Control/PanelContainer/MarginContainer/HBoxContainer/TextoContainer/Botones/CerrarBoton

var _nombre_actual: String = ""
var _lineas: PackedStringArray = []
var _indice_actual: int = 0
var _activo: bool = false
var _acepta_input: bool = false
var _retrato_actual: Node = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel_raiz.hide()
	siguiente_boton.pressed.connect(avanzar)
	cerrar_boton.pressed.connect(cerrar)


func iniciar(
	nombre: String,
	lineas: PackedStringArray,
	retrato_origen: Node = null,
	retrato_escala: float = 2.4,
	retrato_posicion: Vector2 = Vector2(90, 118)
) -> void:
	_nombre_actual = nombre
	_lineas = lineas
	if _lineas.is_empty():
		_lineas = PackedStringArray(["..."])

	_indice_actual = 0
	_activo = true
	_acepta_input = false
	_configurar_retrato(retrato_origen, retrato_escala, retrato_posicion)
	panel_raiz.show()
	_actualizar_texto()
	call_deferred("_habilitar_input")


func esta_activo() -> bool:
	return _activo


func avanzar() -> void:
	if not _activo:
		return

	if _indice_actual >= _lineas.size() - 1:
		cerrar()
		return

	_indice_actual += 1
	_actualizar_texto()


func cerrar() -> void:
	if not _activo:
		return

	_activo = false
	_acepta_input = false
	_limpiar_retrato()
	panel_raiz.hide()
	emit_signal("dialogo_cerrado")


func _unhandled_input(event: InputEvent) -> void:
	if not _activo or not _acepta_input:
		return

	if event.is_action_pressed("interactuar") or event.is_action_pressed("ui_accept"):
		avanzar()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pausa"):
		cerrar()
		get_viewport().set_input_as_handled()


func _actualizar_texto() -> void:
	nombre_label.text = _nombre_actual
	texto_label.text = _lineas[_indice_actual]
	progreso_label.text = "%d / %d" % [_indice_actual + 1, _lineas.size()]
	siguiente_boton.text = "Cerrar" if _indice_actual >= _lineas.size() - 1 else "Siguiente"
	emit_signal("linea_cambiada", _indice_actual, _lineas.size())


func _configurar_retrato(retrato_origen: Node, escala: float, posicion: Vector2) -> void:
	_limpiar_retrato()

	if retrato_origen == null:
		return

	_retrato_actual = retrato_origen.duplicate()
	retrato_root.add_child(_retrato_actual)

	if _retrato_actual is CanvasItem:
		_retrato_actual.show()

	if _retrato_actual is Node2D:
		_retrato_actual.position = posicion
		_retrato_actual.rotation = 0.0
		_retrato_actual.scale = Vector2.ONE * escala


func _limpiar_retrato() -> void:
	if _retrato_actual == null:
		return

	_retrato_actual.queue_free()
	_retrato_actual = null


func _habilitar_input() -> void:
	_acepta_input = true
