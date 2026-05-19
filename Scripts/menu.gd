extends Control

const MAIN_GAME_SCENE := "res://Escenas/MainGame.tscn"
const SistemaGuardadoClass = preload("res://Scripts/sistema_guardado.gd")
const FUENTE_PIXEL := preload("res://Fuentes/joystix monospace.otf")

@onready var boton_jugar: Button = $VBoxContainer/Jugar

var _overlay_slots: ColorRect = null
var _panel_slots: PanelContainer = null
var _filas_slots: Array[Dictionary] = []
var _boton_cancelar_slots: Button = null


func _ready() -> void:
	_crear_selector_slots()
	_actualizar_texto_boton_principal()
	if boton_jugar != null:
		boton_jugar.grab_focus()


func _on_salir_pressed() -> void:
	get_tree().quit()


func _on_jugar_pressed() -> void:
	_abrir_selector_slots()


func _on_opciones_pressed() -> void:
	MenuOpciones.aparecer()


func _unhandled_input(event: InputEvent) -> void:
	if _overlay_slots == null or not _overlay_slots.visible:
		return

	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pausa"):
		_cerrar_selector_slots()
		get_viewport().set_input_as_handled()


func _crear_selector_slots() -> void:
	if _overlay_slots != null:
		return

	_overlay_slots = ColorRect.new()
	_overlay_slots.name = "OverlaySlots"
	_overlay_slots.anchor_left = 0.0
	_overlay_slots.anchor_top = 0.0
	_overlay_slots.anchor_right = 1.0
	_overlay_slots.anchor_bottom = 1.0
	_overlay_slots.offset_left = 0.0
	_overlay_slots.offset_top = 0.0
	_overlay_slots.offset_right = 0.0
	_overlay_slots.offset_bottom = 0.0
	_overlay_slots.color = Color(0.02, 0.05, 0.08, 0.84)
	_overlay_slots.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay_slots.visible = false
	add_child(_overlay_slots)

	var center := CenterContainer.new()
	center.anchor_left = 0.0
	center.anchor_top = 0.0
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	center.offset_left = 0.0
	center.offset_top = 0.0
	center.offset_right = 0.0
	center.offset_bottom = 0.0
	_overlay_slots.add_child(center)

	_panel_slots = PanelContainer.new()
	_panel_slots.custom_minimum_size = Vector2(620, 0)
	_panel_slots.add_theme_stylebox_override("panel", _crear_stylebox_panel())
	center.add_child(_panel_slots)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	_panel_slots.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var titulo := Label.new()
	titulo.text = "PARTIDAS"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_override("font", FUENTE_PIXEL)
	titulo.add_theme_font_size_override("font_size", 18)
	titulo.add_theme_color_override("font_color", Color(0.94, 0.96, 0.8, 1.0))
	vbox.add_child(titulo)

	var subtitulo := Label.new()
	subtitulo.text = "Elige un espacio para empezar de cero o cargar tu avance."
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitulo.add_theme_font_override("font", FUENTE_PIXEL)
	subtitulo.add_theme_font_size_override("font_size", 10)
	subtitulo.add_theme_color_override("font_color", Color(0.78, 0.84, 0.78, 1.0))
	vbox.add_child(subtitulo)

	for slot in range(1, SistemaGuardadoClass.TOTAL_SLOTS + 1):
		var fila := _crear_fila_slot(slot)
		vbox.add_child(fila["contenedor"])
		_filas_slots.append(fila)

	_boton_cancelar_slots = Button.new()
	_boton_cancelar_slots.text = "Cerrar"
	_boton_cancelar_slots.custom_minimum_size = Vector2(0, 42)
	_estilizar_boton_selector(_boton_cancelar_slots, Color(0.3, 0.36, 0.28, 1.0))
	_boton_cancelar_slots.pressed.connect(_cerrar_selector_slots)
	vbox.add_child(_boton_cancelar_slots)


func _crear_fila_slot(slot: int) -> Dictionary:
	var contenedor := PanelContainer.new()
	contenedor.add_theme_stylebox_override("panel", _crear_stylebox_slot())

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	contenedor.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)

	var info := Label.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_font_override("font", FUENTE_PIXEL)
	info.add_theme_font_size_override("font_size", 10)
	info.add_theme_color_override("font_color", Color(0.92, 0.94, 0.88, 1.0))
	hbox.add_child(info)

	var boton_nueva := Button.new()
	boton_nueva.text = "Nueva"
	boton_nueva.custom_minimum_size = Vector2(118, 40)
	_estilizar_boton_selector(boton_nueva, Color(0.54, 0.66, 0.34, 1.0))
	boton_nueva.pressed.connect(_on_nueva_partida_slot_pressed.bind(slot))
	hbox.add_child(boton_nueva)

	var boton_cargar := Button.new()
	boton_cargar.text = "Cargar"
	boton_cargar.custom_minimum_size = Vector2(118, 40)
	_estilizar_boton_selector(boton_cargar, Color(0.32, 0.48, 0.62, 1.0))
	boton_cargar.pressed.connect(_on_cargar_partida_slot_pressed.bind(slot))
	hbox.add_child(boton_cargar)

	return {
		"slot": slot,
		"contenedor": contenedor,
		"info": info,
		"nueva": boton_nueva,
		"cargar": boton_cargar,
	}


func _abrir_selector_slots() -> void:
	_actualizar_selector_slots()
	_overlay_slots.visible = true
	if not _filas_slots.is_empty():
		var primer_boton: Button = _filas_slots[0]["nueva"] as Button
		if primer_boton != null:
			primer_boton.grab_focus()


func _cerrar_selector_slots() -> void:
	if _overlay_slots == null:
		return

	_overlay_slots.visible = false
	if boton_jugar != null:
		boton_jugar.grab_focus()


func _actualizar_selector_slots() -> void:
	for fila in _filas_slots:
		var slot := int(fila["slot"])
		var info := fila["info"] as Label
		var boton_cargar := fila["cargar"] as Button
		var resumen := SistemaGuardadoClass.obtener_resumen_slot(slot)
		var escena := String(resumen.get("escena_actual", MAIN_GAME_SCENE))
		if not bool(resumen.get("existe", false)):
			info.text = "Slot %d  |  Vacio. Ideal para una partida nueva." % slot
			boton_cargar.disabled = true
			continue

		var nombre_escena := "Mundo 2" if escena == "res://Escenas/Mundo2.tscn" else "Mundo 1"
		info.text = "Slot %d  |  Guardado disponible en %s." % [slot, nombre_escena]
		boton_cargar.disabled = false


func _on_nueva_partida_slot_pressed(slot: int) -> void:
	SistemaGuardadoClass.establecer_slot_activo(slot)
	SistemaGuardadoClass.borrar_guardado_slot(slot)
	SistemaGuardadoClass.limpiar_transicion_pendiente()
	SistemaGuardadoClass.marcar_intro_nueva_partida(true)
	get_tree().change_scene_to_file(MAIN_GAME_SCENE)


func _on_cargar_partida_slot_pressed(slot: int) -> void:
	if not SistemaGuardadoClass.existe_guardado(slot):
		return

	SistemaGuardadoClass.establecer_slot_activo(slot)
	SistemaGuardadoClass.limpiar_transicion_pendiente()
	get_tree().change_scene_to_file(SistemaGuardadoClass.obtener_escena_inicio(slot))


func _actualizar_texto_boton_principal() -> void:
	if boton_jugar != null:
		boton_jugar.text = "Partidas"


func _crear_stylebox_panel() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.12, 0.14, 0.96)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.48, 0.62, 0.38, 1.0)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	return style


func _crear_stylebox_slot() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.17, 0.19, 0.95)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.28, 0.36, 0.28, 1.0)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	return style


func _estilizar_boton_selector(boton: Button, color_borde: Color) -> void:
	boton.add_theme_font_override("font", FUENTE_PIXEL)
	boton.add_theme_font_size_override("font_size", 10)
	boton.add_theme_color_override("font_color", Color(0.96, 0.97, 0.92, 1.0))

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.18, 0.22, 0.2, 1.0)
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	normal.border_color = color_borde
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_right = 8
	normal.corner_radius_bottom_left = 8

	var hover := normal.duplicate()
	hover.bg_color = Color(0.24, 0.3, 0.26, 1.0)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.1, 0.14, 0.12, 1.0)

	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	disabled.border_color = Color(0.22, 0.24, 0.22, 0.9)

	boton.add_theme_stylebox_override("normal", normal)
	boton.add_theme_stylebox_override("hover", hover)
	boton.add_theme_stylebox_override("pressed", pressed)
	boton.add_theme_stylebox_override("focus", hover)
	boton.add_theme_stylebox_override("disabled", disabled)
