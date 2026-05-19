extends CanvasLayer
class_name CutsceneBase

const FUENTE_PIXEL := preload("res://Fuentes/joystix monospace.otf")

var _root: Control
var _overlay: ColorRect
var _panel: PanelContainer
var _titulo: Label
var _cuerpo: Label
var _nota: Label
var _linea: ColorRect
var _comic_grid: HBoxContainer


func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	_construir_ui()


func reproducir_intro_inicio() -> void:
	await _mostrar_comic(
		"DEEP SHADOW",
		[
			{"tipo": "escuela", "caption": "En la escuela, las miradas pesan mas que la mochila."},
			{"tipo": "burla", "caption": "Las risas convierten unas gafas en una marca."},
			{"tipo": "claridad", "caption": "Pero ver distinto tambien puede abrir un camino."},
		],
		"Nuevo comienzo",
		5.4,
		Color(0.78, 0.92, 0.42, 1.0)
	)


func reproducir_transicion_mundo_2() -> void:
	await _mostrar_comic(
		"ENTRE MUNDOS",
		[
			{"tipo": "camino", "caption": "Despues de la primera sombra, el pasillo sigue."},
			{"tipo": "puerta", "caption": "La puerta respira como si guardara algo detras."},
			{"tipo": "persecucion", "caption": "Al cruzar, las voces avanzan como un muro."},
		],
		"Persecucion",
		5.2,
		Color(0.88, 0.42, 0.38, 1.0)
	)


func reproducir_final_provisional() -> void:
	await _mostrar_comic(
		"REGRESO",
		[
			{"tipo": "noche", "caption": "La salida no borra el miedo, pero baja el ruido."},
			{"tipo": "casa", "caption": "Una luz espera al final del camino."},
			{"tipo": "ventana", "caption": "Hoy llego a casa siendo un poco mas mio."},
		],
		"Cierre provisional",
		5.6,
		Color(0.76, 0.91, 0.56, 1.0)
	)


func _construir_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	_overlay = ColorRect.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(_overlay)

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(centro)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(740, 315)
	_panel.modulate.a = 0.0
	_panel.scale = Vector2(0.97, 0.97)
	_panel.add_theme_stylebox_override("panel", _crear_estilo_panel())
	centro.add_child(_panel)

	var margen := MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 28)
	margen.add_theme_constant_override("margin_right", 28)
	margen.add_theme_constant_override("margin_top", 24)
	margen.add_theme_constant_override("margin_bottom", 22)
	_panel.add_child(margen)

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 12)
	margen.add_child(caja)

	_titulo = Label.new()
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_titulo.add_theme_font_override("font", FUENTE_PIXEL)
	_titulo.add_theme_font_size_override("font_size", 20)
	_titulo.add_theme_color_override("font_color", Color(0.88, 0.95, 0.50, 1.0))
	caja.add_child(_titulo)

	_linea = ColorRect.new()
	_linea.custom_minimum_size = Vector2(0, 3)
	_linea.color = Color(0.78, 0.92, 0.42, 1.0)
	caja.add_child(_linea)

	_comic_grid = HBoxContainer.new()
	_comic_grid.add_theme_constant_override("separation", 12)
	caja.add_child(_comic_grid)

	_cuerpo = Label.new()
	_cuerpo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cuerpo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_cuerpo.add_theme_font_override("font", FUENTE_PIXEL)
	_cuerpo.add_theme_font_size_override("font_size", 11)
	_cuerpo.add_theme_color_override("font_color", Color(0.92, 0.95, 0.84, 1.0))
	caja.add_child(_cuerpo)

	_nota = Label.new()
	_nota.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_nota.add_theme_font_override("font", FUENTE_PIXEL)
	_nota.add_theme_font_size_override("font_size", 10)
	_nota.add_theme_color_override("font_color", Color(0.58, 0.80, 0.82, 1.0))
	caja.add_child(_nota)


func _crear_estilo_panel() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.055, 0.045, 0.075, 0.96)
	estilo.border_width_left = 2
	estilo.border_width_top = 2
	estilo.border_width_right = 2
	estilo.border_width_bottom = 2
	estilo.border_color = Color(0.70, 0.84, 0.38, 0.95)
	estilo.corner_radius_top_left = 10
	estilo.corner_radius_top_right = 10
	estilo.corner_radius_bottom_left = 10
	estilo.corner_radius_bottom_right = 10
	estilo.shadow_color = Color(0, 0, 0, 0.48)
	estilo.shadow_size = 18
	return estilo


func _mostrar_tarjeta(titulo: String, cuerpo: String, nota: String, duracion: float, acento: Color) -> void:
	_panel.custom_minimum_size = Vector2(640, 210)
	_comic_grid.hide()
	_cuerpo.show()
	_titulo.text = titulo
	_cuerpo.text = cuerpo
	_nota.text = nota
	_linea.color = acento
	await _animar_contenido(duracion)


func _mostrar_comic(titulo: String, paneles: Array, nota: String, duracion: float, acento: Color) -> void:
	_panel.custom_minimum_size = Vector2(740, 315)
	_comic_grid.show()
	_cuerpo.hide()
	_titulo.text = titulo
	_cuerpo.text = ""
	_nota.text = nota
	_linea.color = acento
	_limpiar_hijos(_comic_grid)

	for datos in paneles:
		_comic_grid.add_child(_crear_panel_comic(Dictionary(datos)))

	await _animar_contenido(duracion)


func _animar_contenido(duracion: float) -> void:
	_linea.scale.x = 0.0
	_panel.modulate.a = 0.0
	_panel.scale = Vector2(0.97, 0.97)
	var color_overlay := _overlay.color
	color_overlay.a = 0.0
	_overlay.color = color_overlay

	await get_tree().process_frame
	_panel.pivot_offset = _panel.size * 0.5

	var entrada := create_tween()
	entrada.set_ignore_time_scale(true)
	entrada.set_parallel(true)
	entrada.set_trans(Tween.TRANS_SINE)
	entrada.set_ease(Tween.EASE_OUT)
	entrada.tween_property(_overlay, "color:a", 0.88, 0.2)
	entrada.tween_property(_panel, "modulate:a", 1.0, 0.22)
	entrada.tween_property(_panel, "scale", Vector2.ONE, 0.24)
	entrada.tween_property(_linea, "scale:x", 1.0, 0.42)
	await entrada.finished

	await get_tree().create_timer(duracion, true, false, true).timeout

	var salida := create_tween()
	salida.set_ignore_time_scale(true)
	salida.set_parallel(true)
	salida.set_trans(Tween.TRANS_SINE)
	salida.set_ease(Tween.EASE_IN)
	salida.tween_property(_panel, "modulate:a", 0.0, 0.2)
	salida.tween_property(_panel, "scale", Vector2(1.02, 1.02), 0.2)
	salida.tween_property(_overlay, "color:a", 0.0, 0.25)
	await salida.finished


func _crear_panel_comic(datos: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(218, 190)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _crear_estilo_panel_comic())

	var margen := MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 8)
	margen.add_theme_constant_override("margin_top", 8)
	margen.add_theme_constant_override("margin_right", 8)
	margen.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margen)

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 7)
	margen.add_child(caja)

	var escena := Control.new()
	escena.custom_minimum_size = Vector2(190, 112)
	caja.add_child(escena)
	_pintar_escena_comic(escena, String(datos.get("tipo", "")))

	var caption := Label.new()
	caption.text = String(datos.get("caption", ""))
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_font_override("font", FUENTE_PIXEL)
	caption.add_theme_font_size_override("font_size", 8)
	caption.add_theme_color_override("font_color", Color(0.91, 0.94, 0.80, 1.0))
	caja.add_child(caption)
	return panel


func _crear_estilo_panel_comic() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.095, 0.095, 0.12, 1.0)
	estilo.border_width_left = 2
	estilo.border_width_top = 2
	estilo.border_width_right = 2
	estilo.border_width_bottom = 2
	estilo.border_color = Color(0.58, 0.72, 0.44, 0.92)
	estilo.corner_radius_top_left = 5
	estilo.corner_radius_top_right = 5
	estilo.corner_radius_bottom_left = 5
	estilo.corner_radius_bottom_right = 5
	return estilo


func _pintar_escena_comic(escena: Control, tipo: String) -> void:
	_agregar_rect(escena, Vector2.ZERO, Vector2(190, 112), Color(0.08, 0.12, 0.16, 1.0), "Fondo")
	match tipo:
		"escuela":
			_pintar_escuela(escena)
		"burla":
			_pintar_burla(escena)
		"claridad":
			_pintar_claridad(escena)
		"camino":
			_pintar_camino(escena)
		"puerta":
			_pintar_puerta_comic(escena)
		"persecucion":
			_pintar_persecucion(escena)
		"noche":
			_pintar_noche(escena)
		"casa":
			_pintar_casa(escena)
		"ventana":
			_pintar_ventana(escena)
		_:
			_pintar_claridad(escena)


func _pintar_escuela(escena: Control) -> void:
	_agregar_rect(escena, Vector2(0, 76), Vector2(190, 36), Color(0.18, 0.18, 0.20, 1.0), "Piso")
	for i in range(4):
		_agregar_rect(escena, Vector2(18 + i * 35, 18), Vector2(26, 54), Color(0.18, 0.26, 0.34, 1.0), "Locker")
		_agregar_rect(escena, Vector2(22 + i * 35, 27), Vector2(18, 4), Color(0.34, 0.48, 0.58, 1.0), "Rejilla")
	_dibujar_personaje(escena, Vector2(78, 68), 1.0)
	_dibujar_sombra(escena, Vector2(132, 66), 0.86)


func _pintar_burla(escena: Control) -> void:
	_agregar_rect(escena, Vector2(0, 74), Vector2(190, 38), Color(0.15, 0.13, 0.16, 1.0), "Piso")
	_dibujar_personaje(escena, Vector2(84, 68), 1.0)
	for i in range(3):
		_dibujar_sombra(escena, Vector2(28 + i * 58, 60), 0.72)
		_agregar_burbuja(escena, Vector2(18 + i * 58, 20), "...", 0.7)


func _pintar_claridad(escena: Control) -> void:
	_agregar_rect(escena, Vector2(0, 75), Vector2(190, 37), Color(0.14, 0.18, 0.18, 1.0), "Piso")
	_agregar_rect(escena, Vector2(132, 22), Vector2(34, 58), Color(0.17, 0.22, 0.30, 1.0), "Puerta")
	_agregar_rect(escena, Vector2(137, 27), Vector2(24, 46), Color(0.72, 0.86, 0.42, 0.55), "Luz")
	_dibujar_personaje(escena, Vector2(70, 68), 1.0)
	_agregar_rect(escena, Vector2(82, 48), Vector2(26, 3), Color(0.78, 0.92, 0.42, 1.0), "BrilloGafas")


func _pintar_camino(escena: Control) -> void:
	_agregar_rect(escena, Vector2(0, 0), Vector2(190, 112), Color(0.07, 0.15, 0.18, 1.0), "Bosque")
	for i in range(5):
		_agregar_rect(escena, Vector2(i * 42, 0), Vector2(18, 92), Color(0.05, 0.10, 0.12, 0.85), "Arbol")
	_agregar_rect(escena, Vector2(0, 78), Vector2(190, 34), Color(0.19, 0.18, 0.16, 1.0), "Camino")
	_dibujar_personaje(escena, Vector2(76, 70), 1.0)
	_agregar_rect(escena, Vector2(112, 86), Vector2(34, 4), Color(0.52, 0.64, 0.38, 1.0), "Paso")


func _pintar_puerta_comic(escena: Control) -> void:
	_agregar_rect(escena, Vector2(0, 0), Vector2(190, 112), Color(0.08, 0.09, 0.13, 1.0), "Fondo")
	_agregar_rect(escena, Vector2(58, 16), Vector2(72, 82), Color(0.28, 0.30, 0.42, 1.0), "Marco")
	_agregar_rect(escena, Vector2(70, 30), Vector2(48, 68), Color(0.04, 0.05, 0.07, 1.0), "Umbral")
	_agregar_rect(escena, Vector2(83, 12), Vector2(22, 8), Color(0.78, 0.92, 0.42, 1.0), "Luz")
	_dibujar_personaje(escena, Vector2(36, 72), 0.86)


func _pintar_persecucion(escena: Control) -> void:
	_agregar_rect(escena, Vector2(0, 0), Vector2(190, 112), Color(0.10, 0.13, 0.16, 1.0), "Fondo")
	_agregar_rect(escena, Vector2(0, 0), Vector2(52, 112), Color(0.16, 0.31, 0.17, 1.0), "Muro")
	_agregar_rect(escena, Vector2(45, 18), Vector2(22, 28), Color(0.82, 0.72, 0.70, 1.0), "Ojo")
	_agregar_rect(escena, Vector2(0, 82), Vector2(190, 30), Color(0.17, 0.17, 0.17, 1.0), "Piso")
	_dibujar_personaje(escena, Vector2(122, 72), 0.92)
	for i in range(3):
		_agregar_rect(escena, Vector2(76 + i * 22, 92 - i * 3), Vector2(12, 3), Color(0.72, 0.84, 0.36, 0.8), "Velocidad")


func _pintar_noche(escena: Control) -> void:
	_agregar_rect(escena, Vector2.ZERO, Vector2(190, 112), Color(0.04, 0.07, 0.12, 1.0), "Noche")
	_agregar_rect(escena, Vector2(0, 78), Vector2(190, 34), Color(0.13, 0.14, 0.16, 1.0), "Calle")
	_agregar_rect(escena, Vector2(148, 14), Vector2(18, 18), Color(0.82, 0.88, 0.67, 1.0), "Luna")
	_dibujar_personaje(escena, Vector2(72, 70), 1.0)


func _pintar_casa(escena: Control) -> void:
	_agregar_rect(escena, Vector2.ZERO, Vector2(190, 112), Color(0.05, 0.08, 0.13, 1.0), "Noche")
	_agregar_rect(escena, Vector2(0, 82), Vector2(190, 30), Color(0.16, 0.15, 0.13, 1.0), "Suelo")
	_agregar_rect(escena, Vector2(94, 48), Vector2(64, 42), Color(0.33, 0.24, 0.20, 1.0), "Casa")
	_agregar_rect(escena, Vector2(88, 38), Vector2(76, 16), Color(0.18, 0.09, 0.08, 1.0), "Techo")
	_agregar_rect(escena, Vector2(118, 62), Vector2(16, 18), Color(0.92, 0.78, 0.42, 1.0), "Ventana")
	_dibujar_personaje(escena, Vector2(54, 72), 0.92)


func _pintar_ventana(escena: Control) -> void:
	_agregar_rect(escena, Vector2.ZERO, Vector2(190, 112), Color(0.07, 0.06, 0.09, 1.0), "Interior")
	_agregar_rect(escena, Vector2(20, 22), Vector2(70, 58), Color(0.90, 0.74, 0.38, 1.0), "VentanaLuz")
	_agregar_rect(escena, Vector2(25, 27), Vector2(60, 48), Color(0.16, 0.20, 0.24, 1.0), "Ventana")
	_agregar_rect(escena, Vector2(0, 82), Vector2(190, 30), Color(0.19, 0.14, 0.12, 1.0), "Piso")
	_dibujar_personaje(escena, Vector2(122, 70), 1.0)
	_agregar_burbuja(escena, Vector2(96, 22), "Estoy aqui", 0.72)


func _dibujar_personaje(padre: Control, posicion: Vector2, escala: float) -> void:
	_agregar_rect(padre, posicion + Vector2(5, -23) * escala, Vector2(16, 16) * escala, Color(0.98, 0.72, 0.58, 1.0), "Cabeza")
	_agregar_rect(padre, posicion + Vector2(2, -6) * escala, Vector2(22, 25) * escala, Color(0.22, 0.30, 0.36, 1.0), "Cuerpo")
	_agregar_rect(padre, posicion + Vector2(7, 19) * escala, Vector2(5, 16) * escala, Color(0.08, 0.08, 0.09, 1.0), "Pierna1")
	_agregar_rect(padre, posicion + Vector2(16, 19) * escala, Vector2(5, 16) * escala, Color(0.08, 0.08, 0.09, 1.0), "Pierna2")
	_agregar_rect(padre, posicion + Vector2(7, -15) * escala, Vector2(13, 3) * escala, Color(0.05, 0.05, 0.06, 1.0), "Gafas")


func _dibujar_sombra(padre: Control, posicion: Vector2, escala: float) -> void:
	_agregar_rect(padre, posicion + Vector2(4, -18) * escala, Vector2(18, 18) * escala, Color(0.04, 0.04, 0.055, 1.0), "SombraCabeza")
	_agregar_rect(padre, posicion + Vector2(0, 0) * escala, Vector2(28, 34) * escala, Color(0.025, 0.025, 0.035, 1.0), "SombraCuerpo")


func _agregar_burbuja(padre: Control, posicion: Vector2, texto: String, escala: float) -> void:
	_agregar_rect(padre, posicion, Vector2(54, 20) * escala, Color(0.90, 0.96, 0.84, 1.0), "Burbuja")
	var label := Label.new()
	label.text = texto
	label.position = posicion + Vector2(5, 2) * escala
	label.size = Vector2(44, 16) * escala
	label.add_theme_font_override("font", FUENTE_PIXEL)
	label.add_theme_font_size_override("font_size", int(7 * escala))
	label.add_theme_color_override("font_color", Color(0.08, 0.08, 0.09, 1.0))
	padre.add_child(label)


func _agregar_rect(padre: Control, posicion: Vector2, tamano: Vector2, color: Color, nombre: String) -> ColorRect:
	var rect := ColorRect.new()
	rect.name = nombre
	rect.position = posicion
	rect.size = tamano
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	padre.add_child(rect)
	return rect


func _limpiar_hijos(nodo: Node) -> void:
	for child in nodo.get_children():
		nodo.remove_child(child)
		child.queue_free()
