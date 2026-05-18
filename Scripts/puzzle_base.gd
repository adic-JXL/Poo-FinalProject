extends CanvasLayer
class_name PuzzleBase

const FUENTE_PIXEL := preload("res://Fuentes/joystix monospace.otf")

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


func aplicar_tema_puzzle(
	overlay: ColorRect,
	panel: PanelContainer,
	titulo: Label,
	labels_secundarios: Array,
	botones_principales: Array,
	boton_secundario: Button,
	color_acento: Color
) -> void:
	if overlay != null:
		overlay.color = Color(0.01, 0.04, 0.05, 0.84)

	if panel != null:
		panel.custom_minimum_size = Vector2(maxf(panel.custom_minimum_size.x, 560.0), maxf(panel.custom_minimum_size.y, 0.0))
		panel.add_theme_stylebox_override("panel", _crear_panel_principal(color_acento))

	if titulo != null:
		titulo.add_theme_font_override("font", FUENTE_PIXEL)
		titulo.add_theme_font_size_override("font_size", 24)
		titulo.add_theme_color_override("font_color", color_acento.lightened(0.18))

	for label in labels_secundarios:
		if label is Label:
			var label_nodo := label as Label
			label_nodo.add_theme_font_override("font", FUENTE_PIXEL)
			label_nodo.add_theme_font_size_override("font_size", 12 if label_nodo != titulo else 24)
			label_nodo.add_theme_color_override("font_color", Color(0.92, 0.91, 0.78, 1.0))

	for boton in botones_principales:
		if boton is Button:
			_estilizar_boton_pixel(boton as Button, color_acento, false)

	if boton_secundario != null:
		_estilizar_boton_pixel(boton_secundario, color_acento.darkened(0.18), true)


func _crear_panel_principal(color_acento: Color) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.10, 0.12, 0.10, 0.97)
	estilo.border_color = color_acento.darkened(0.2)
	estilo.set_border_width_all(4)
	estilo.shadow_color = Color(0, 0, 0, 0.35)
	estilo.shadow_size = 10
	estilo.content_margin_left = 22
	estilo.content_margin_right = 22
	estilo.content_margin_top = 20
	estilo.content_margin_bottom = 18
	return estilo


func _estilizar_boton_pixel(boton: Button, color_acento: Color, secundario: bool) -> void:
	boton.add_theme_font_override("font", FUENTE_PIXEL)
	boton.add_theme_font_size_override("font_size", 12)
	boton.add_theme_color_override("font_color", Color(0.98, 0.95, 0.82, 1.0))
	boton.add_theme_stylebox_override("normal", _crear_estilo_boton(Color(0.16, 0.14, 0.16, 0.98), color_acento))
	boton.add_theme_stylebox_override("hover", _crear_estilo_boton(Color(0.20, 0.18, 0.20, 1.0), color_acento.lightened(0.1)))
	boton.add_theme_stylebox_override("pressed", _crear_estilo_boton(color_acento.darkened(0.42), color_acento.lightened(0.08)))
	boton.add_theme_stylebox_override("disabled", _crear_estilo_boton(Color(0.11, 0.11, 0.11, 0.86), Color(0.28, 0.30, 0.28, 0.9)))
	boton.add_theme_constant_override("h_separation", 6 if secundario else 10)


func _crear_estilo_boton(color_fondo: Color, color_borde: Color) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = color_fondo
	estilo.border_color = color_borde
	estilo.set_border_width_all(3)
	estilo.content_margin_left = 10
	estilo.content_margin_right = 10
	estilo.content_margin_top = 9
	estilo.content_margin_bottom = 9
	return estilo
