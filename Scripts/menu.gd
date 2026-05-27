extends Control

const MAIN_GAME_SCENE := "res://Escenas/MainGame.tscn"
const SistemaGuardadoClass = preload("res://Scripts/sistema_guardado.gd")
const CUTSCENE_BASE_SCRIPT := preload("res://Scripts/cutscene_base.gd")
const FUENTE_PIXEL := preload("res://Fuentes/joystix monospace.otf")
const SKINS := {
	"girl": {
		"titulo": "GIRL",
		"preview": "res://Imagenes/Personaje_Girl/sin_gafas/idle/idle_00.png",
		"borde": Color(0.98, 0.63, 0.76, 1.0),
	},
	"boy": {
		"titulo": "BOY",
		"preview": "res://Imagenes/Personaje_Boy/sin_gafas/idle/idle_00.png",
		"borde": Color(0.55, 0.82, 0.98, 1.0),
	},
}


@onready var boton_jugar: Button = $VBoxContainer/Jugar

var _overlay_slots: ColorRect = null
var _panel_slots: PanelContainer = null
var _scroll_slots: ScrollContainer = null
var _filas_slots: Array[Dictionary] = []
var _boton_cancelar_slots: Button = null
var _creditos_en_reproduccion: bool = false
var _controles_en_reproduccion: bool = false
var _seleccion_skin_por_slot: Dictionary = {}


func _ready() -> void:
	_crear_selector_slots()
	_actualizar_texto_boton_principal()
	_actualizar_layout_selector_slots()
	if boton_jugar != null:
		boton_jugar.grab_focus()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_actualizar_layout_selector_slots()


func _on_salir_pressed() -> void:
	get_tree().quit()


func _on_jugar_pressed() -> void:
	_abrir_selector_slots()


func _on_opciones_pressed() -> void:
	var menu_opciones := get_node_or_null("/root/MenuOpciones")
	if menu_opciones != null and menu_opciones.has_method("aparecer"):
		menu_opciones.call("aparecer")


func _on_creditos_pressed() -> void:
	if _creditos_en_reproduccion:
		return

	if _overlay_slots != null and _overlay_slots.visible:
		_cerrar_selector_slots()

	_creditos_en_reproduccion = true
	var cutscene := CUTSCENE_BASE_SCRIPT.new()
	add_child(cutscene)
	await cutscene.reproducir_creditos_menu()
	cutscene.queue_free()
	_creditos_en_reproduccion = false
	if boton_jugar != null:
		boton_jugar.grab_focus()


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
	_panel_slots.custom_minimum_size = Vector2(760, 610)
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
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(vbox)

	var titulo := Label.new()
	titulo.text = "PARTIDAS"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_override("font", FUENTE_PIXEL)
	titulo.add_theme_font_size_override("font_size", 18)
	titulo.add_theme_color_override("font_color", Color(0.94, 0.96, 0.8, 1.0))
	vbox.add_child(titulo)

	var subtitulo := Label.new()
	subtitulo.text = "Elige un espacio, mira la preview y decide si quieres entrar con GIRL o BOY."
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitulo.add_theme_font_override("font", FUENTE_PIXEL)
	subtitulo.add_theme_font_size_override("font_size", 10)
	subtitulo.add_theme_color_override("font_color", Color(0.78, 0.84, 0.78, 1.0))
	vbox.add_child(subtitulo)

	_scroll_slots = ScrollContainer.new()
	_scroll_slots.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll_slots.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll_slots.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_scroll_slots.follow_focus = true
	vbox.add_child(_scroll_slots)

	var slots_vbox := VBoxContainer.new()
	slots_vbox.add_theme_constant_override("separation", 10)
	slots_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll_slots.add_child(slots_vbox)

	for slot in range(1, SistemaGuardadoClass.TOTAL_SLOTS + 1):
		var fila := _crear_fila_slot(slot)
		slots_vbox.add_child(fila["contenedor"])
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

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var info := Label.new()
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_font_override("font", FUENTE_PIXEL)
	info.add_theme_font_size_override("font_size", 10)
	info.add_theme_color_override("font_color", Color(0.92, 0.94, 0.88, 1.0))
	vbox.add_child(info)

	var skins_hbox := HBoxContainer.new()
	skins_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	skins_hbox.add_theme_constant_override("separation", 14)
	vbox.add_child(skins_hbox)

	var boton_skin_girl := _crear_boton_skin(slot, "girl")
	var boton_skin_boy := _crear_boton_skin(slot, "boy")
	skins_hbox.add_child(boton_skin_girl)
	skins_hbox.add_child(boton_skin_boy)

	var botones_hbox := HBoxContainer.new()
	botones_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	botones_hbox.add_theme_constant_override("separation", 12)
	vbox.add_child(botones_hbox)

	var boton_nueva := Button.new()
	boton_nueva.text = "Nueva"
	boton_nueva.custom_minimum_size = Vector2(118, 40)
	_estilizar_boton_selector(boton_nueva, Color(0.54, 0.66, 0.34, 1.0))
	boton_nueva.pressed.connect(_on_nueva_partida_slot_pressed.bind(slot))
	botones_hbox.add_child(boton_nueva)

	var boton_cargar := Button.new()
	boton_cargar.text = "Cargar"
	boton_cargar.custom_minimum_size = Vector2(96, 40)
	_estilizar_boton_selector(boton_cargar, Color(0.32, 0.48, 0.62, 1.0))
	boton_cargar.pressed.connect(_on_cargar_partida_slot_pressed.bind(slot))
	botones_hbox.add_child(boton_cargar)

	var boton_eliminar := Button.new()
	boton_eliminar.text = "Eliminar"
	boton_eliminar.custom_minimum_size = Vector2(96, 40)
	_estilizar_boton_selector(boton_eliminar, Color(0.62, 0.34, 0.32, 1.0))
	boton_eliminar.pressed.connect(_on_eliminar_partida_slot_pressed.bind(slot))
	botones_hbox.add_child(boton_eliminar)

	_seleccion_skin_por_slot[slot] = "girl"

	return {
		"slot": slot,
		"contenedor": contenedor,
		"info": info,
		"skin_girl": boton_skin_girl,
		"skin_boy": boton_skin_boy,
		"nueva": boton_nueva,
		"cargar": boton_cargar,
		"eliminar": boton_eliminar,
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


func _actualizar_layout_selector_slots() -> void:
	if _panel_slots == null:
		return

	var viewport_size := get_viewport_rect().size
	var ancho_panel := clampf(viewport_size.x - 120.0, 520.0, 760.0)
	var alto_panel := clampf(viewport_size.y - 72.0, 360.0, 610.0)
	_panel_slots.custom_minimum_size = Vector2(ancho_panel, alto_panel)
	if _scroll_slots != null:
		_scroll_slots.custom_minimum_size = Vector2(maxf(ancho_panel - 36.0, 320.0), maxf(alto_panel - 154.0, 170.0))


func recalibrar_tras_cambio_resolucion() -> void:
	_actualizar_layout_selector_slots()


func _actualizar_selector_slots() -> void:
	for fila in _filas_slots:
		var slot := int(fila["slot"])
		var resumen := SistemaGuardadoClass.obtener_resumen_slot(slot)
		var escena := String(resumen.get("escena_actual", MAIN_GAME_SCENE))
		var skin_guardada := SistemaGuardadoClass.obtener_skin_guardada_slot(slot) if bool(resumen.get("existe", false)) else String(_seleccion_skin_por_slot.get(slot, "girl"))
		_seleccion_skin_por_slot[slot] = skin_guardada
		_actualizar_estilos_skin_slot(fila)
		_actualizar_info_fila_slot(fila, bool(resumen.get("existe", false)), escena)


func _on_nueva_partida_slot_pressed(slot: int) -> void:
	SistemaGuardadoClass.establecer_slot_activo(slot)
	SistemaGuardadoClass.borrar_guardado_slot(slot)
	SistemaGuardadoClass.limpiar_transicion_pendiente()
	SistemaGuardadoClass.marcar_intro_nueva_partida(true)
	SistemaGuardadoClass.establecer_skin_jugador(_obtener_skin_slot(slot))
	get_tree().change_scene_to_file(MAIN_GAME_SCENE)


func _on_cargar_partida_slot_pressed(slot: int) -> void:
	if not SistemaGuardadoClass.existe_guardado(slot):
		return

	SistemaGuardadoClass.establecer_slot_activo(slot)
	SistemaGuardadoClass.limpiar_transicion_pendiente()
	var skin_seleccionada := _obtener_skin_slot(slot)
	SistemaGuardadoClass.guardar_skin_guardada_slot(slot, skin_seleccionada)
	SistemaGuardadoClass.establecer_skin_jugador(skin_seleccionada)
	get_tree().change_scene_to_file(SistemaGuardadoClass.obtener_escena_inicio(slot))


func _on_eliminar_partida_slot_pressed(slot: int) -> void:
	if not SistemaGuardadoClass.existe_guardado(slot):
		return

	SistemaGuardadoClass.borrar_guardado_slot(slot)
	_seleccion_skin_por_slot[slot] = "girl"
	_actualizar_selector_slots()


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


func _crear_boton_skin(slot: int, skin_id: String) -> Button:
	var boton := Button.new()
	boton.text = ""
	boton.custom_minimum_size = Vector2(150, 118)
	boton.clip_contents = true
	boton.focus_mode = Control.FOCUS_NONE
	boton.pressed.connect(_on_skin_slot_pressed.bind(slot, skin_id))

	var contenido := VBoxContainer.new()
	contenido.anchor_right = 1.0
	contenido.anchor_bottom = 1.0
	contenido.offset_left = 10.0
	contenido.offset_top = 8.0
	contenido.offset_right = -10.0
	contenido.offset_bottom = -8.0
	contenido.alignment = BoxContainer.ALIGNMENT_CENTER
	contenido.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contenido.add_theme_constant_override("separation", 6)
	boton.add_child(contenido)

	var preview := TextureRect.new()
	preview.name = "Preview"
	preview.custom_minimum_size = Vector2(58, 58)
	preview.texture = load(String(SKINS[skin_id]["preview"])) as Texture2D
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contenido.add_child(preview)

	var titulo := Label.new()
	titulo.text = String(SKINS[skin_id]["titulo"])
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_override("font", FUENTE_PIXEL)
	titulo.add_theme_font_size_override("font_size", 11)
	titulo.add_theme_color_override("font_color", Color(0.95, 0.96, 0.9, 1.0))
	titulo.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.86))
	titulo.add_theme_constant_override("outline_size", 1)
	titulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contenido.add_child(titulo)

	var subtitulo := Label.new()
	subtitulo.text = "Skin %s" % skin_id
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.add_theme_font_override("font", FUENTE_PIXEL)
	subtitulo.add_theme_font_size_override("font_size", 8)
	subtitulo.add_theme_color_override("font_color", Color(0.76, 0.84, 0.79, 1.0))
	subtitulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contenido.add_child(subtitulo)

	return boton


func _on_skin_slot_pressed(slot: int, skin_id: String) -> void:
	_seleccion_skin_por_slot[slot] = skin_id
	for fila in _filas_slots:
		if int(fila["slot"]) == slot:
			_actualizar_estilos_skin_slot(fila)
			var resumen := SistemaGuardadoClass.obtener_resumen_slot(slot)
			_actualizar_info_fila_slot(fila, bool(resumen.get("existe", false)), String(resumen.get("escena_actual", MAIN_GAME_SCENE)))
			break


func _obtener_skin_slot(slot: int) -> String:
	return String(_seleccion_skin_por_slot.get(slot, "girl"))


func _actualizar_estilos_skin_slot(fila: Dictionary) -> void:
	var slot := int(fila["slot"])
	var skin_actual := _obtener_skin_slot(slot)
	_aplicar_estilo_skin_card(fila["skin_girl"] as Button, "girl", skin_actual == "girl")
	_aplicar_estilo_skin_card(fila["skin_boy"] as Button, "boy", skin_actual == "boy")


func _aplicar_estilo_skin_card(boton: Button, skin_id: String, seleccionado: bool) -> void:
	if boton == null:
		return

	var borde: Color = SKINS[skin_id]["borde"]
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.11, 0.14, 0.15, 0.96)
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	normal.border_color = borde if seleccionado else Color(0.25, 0.3, 0.28, 1.0)
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_right = 8
	normal.corner_radius_bottom_left = 8

	var hover := normal.duplicate()
	hover.bg_color = Color(0.18, 0.22, 0.22, 1.0)
	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.08, 0.1, 0.11, 1.0)

	if seleccionado:
		normal.bg_color = Color(0.18, 0.21, 0.16, 1.0)
		hover.bg_color = Color(0.22, 0.26, 0.18, 1.0)
		pressed.bg_color = Color(0.12, 0.15, 0.1, 1.0)

	boton.add_theme_stylebox_override("normal", normal)
	boton.add_theme_stylebox_override("hover", hover)
	boton.add_theme_stylebox_override("pressed", pressed)
	boton.add_theme_stylebox_override("focus", hover)


func _actualizar_info_fila_slot(fila: Dictionary, existe: bool, escena: String) -> void:
	var info := fila["info"] as Label
	var boton_cargar := fila["cargar"] as Button
	var boton_eliminar := fila["eliminar"] as Button
	var slot := int(fila["slot"])
	var skin_actual := _obtener_skin_slot(slot)
	if not existe:
		info.text = "Slot %d  |  Vacio. Elige skin: %s." % [slot, skin_actual.to_upper()]
		boton_cargar.disabled = true
		boton_eliminar.disabled = true
		return

	var nombre_escena := "Mundo 2" if escena == "res://Escenas/Mundo2.tscn" else "Mundo 1"
	info.text = "Slot %d  |  Guardado disponible en %s  |  Skin: %s." % [slot, nombre_escena, skin_actual.to_upper()]
	boton_cargar.disabled = false
	boton_eliminar.disabled = false


func _on_controles_pressed() -> void:
	if _controles_en_reproduccion:
		return

	if _overlay_slots != null and _overlay_slots.visible:
		_cerrar_selector_slots()

	_controles_en_reproduccion = true
	var cutscene := CUTSCENE_BASE_SCRIPT.new()
	add_child(cutscene)
	await cutscene.reproducir_controles()
	cutscene.queue_free()
	_controles_en_reproduccion = false
	if boton_jugar != null:
		boton_jugar.grab_focus()
