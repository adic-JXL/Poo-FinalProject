extends CanvasLayer

const SETTINGS_PATH := "user://deep_shadow_settings.cfg"
const SHADER_ACCESIBILIDAD := preload("res://Shaders/filtro_accesibilidad.gdshader")
const FUENTE_PIXEL := preload("res://Fuentes/joystix monospace.otf")
const RESOLUCIONES_PREDETERMINADAS := [
	{"label": "960 x 540", "size": Vector2i(960, 540)},
	{"label": "1280 x 720", "size": Vector2i(1280, 720)},
	{"label": "1600 x 900", "size": Vector2i(1600, 900)},
	{"label": "1920 x 1080", "size": Vector2i(1920, 1080)},
]

enum ModoPantalla {
	VENTANA,
	MAXIMIZADA,
	PANTALLA_COMPLETA,
}

enum ModoDaltonismo {
	NORMAL,
	DEUTERANOPIA,
	PROTANOPIA,
	TRITANOPIA,
}

enum IntensidadSacudida {
	DESACTIVADA,
	SUAVE,
	NORMAL,
}

var _configuracion := {
	"master_volume_db": -6.0,
	"window_mode": ModoPantalla.VENTANA,
	"resolution_index": 1,
	"colorblind_mode": ModoDaltonismo.NORMAL,
	"screen_shake": IntensidadSacudida.NORMAL,
}
var _sincronizando_ui: bool = false
var _selector_modo_pantalla: OptionButton = null
var _selector_accesibilidad: OptionButton = null
var _selector_temblor: OptionButton = null
var _overlay_accesibilidad: ColorRect = null
var _material_accesibilidad: ShaderMaterial = null

@onready var bus_index: int = AudioServer.get_bus_index("Master")
@onready var panel_control: Control = $Control
@onready var secciones: VBoxContainer = $Control/CenterContainer/PanelContainer/Secciones
@onready var fila_volumen: HBoxContainer = $Control/CenterContainer/PanelContainer/Secciones/Volumen
@onready var slider_volumen: HSlider = $Control/CenterContainer/PanelContainer/Secciones/Volumen/HSlider
@onready var fila_probar_sonido: HBoxContainer = $Control/CenterContainer/PanelContainer/Secciones/ProbarSonido
@onready var boton_probar_sonido: Button = $Control/CenterContainer/PanelContainer/Secciones/ProbarSonido/Button
@onready var fila_modo_pantalla: HBoxContainer = $Control/CenterContainer/PanelContainer/Secciones/Dificultad
@onready var fila_resolucion: HBoxContainer = $Control/CenterContainer/PanelContainer/Secciones/Resolucion
@onready var opcion_resolucion: OptionButton = $Control/CenterContainer/PanelContainer/Secciones/Resolucion/OptionButton
@onready var boton_cerrar: Button = $Control/CenterContainer/PanelContainer/Secciones/ButtonCerrar
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	_asegurar_overlay_accesibilidad()
	_configurar_panel_opciones()
	_cargar_configuracion()
	_sincronizar_controles_desde_configuracion()
	_aplicar_configuracion(false)
	panel_control.hide()


func aparecer() -> void:
	panel_control.show()
	_sincronizar_controles_desde_configuracion()
	slider_volumen.grab_focus()


func cerrar() -> void:
	panel_control.hide()


func obtener_factor_temblor_camara() -> float:
	match int(_configuracion.get("screen_shake", IntensidadSacudida.NORMAL)):
		IntensidadSacudida.DESACTIVADA:
			return 0.0
		IntensidadSacudida.SUAVE:
			return 0.55
		_:
			return 1.0


func _unhandled_input(event: InputEvent) -> void:
	if not panel_control.visible:
		return

	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pausa"):
		cerrar()
		get_viewport().set_input_as_handled()


func _configurar_panel_opciones() -> void:
	_estilizar_label(fila_volumen.get_node("Label") as Label, "VOLUMEN")
	_estilizar_label(fila_probar_sonido.get_node("Label") as Label, "PROBAR SONIDO")
	_estilizar_label(fila_modo_pantalla.get_node("Label") as Label, "MODO DE PANTALLA")
	_estilizar_label(fila_resolucion.get_node("Label") as Label, "RESOLUCION")

	slider_volumen.min_value = -36.0
	slider_volumen.max_value = 6.0
	slider_volumen.step = 1.0

	boton_probar_sonido.text = "Probar"
	_estilizar_boton_pixel(boton_probar_sonido, 11)
	_estilizar_boton_pixel(boton_cerrar, 16)
	boton_cerrar.text = "Cerrar"

	_selector_modo_pantalla = _asegurar_selector_en_fila(
		fila_modo_pantalla,
		"SelectorModoPantalla",
		[
			"Ventana",
			"Maximizada",
			"Pantalla completa",
		]
	)
	if not _selector_modo_pantalla.item_selected.is_connected(_on_selector_modo_pantalla_item_selected):
		_selector_modo_pantalla.item_selected.connect(_on_selector_modo_pantalla_item_selected)

	_configurar_selector_existente(opcion_resolucion)
	opcion_resolucion.clear()
	for indice in range(RESOLUCIONES_PREDETERMINADAS.size()):
		opcion_resolucion.add_item(String(RESOLUCIONES_PREDETERMINADAS[indice]["label"]), indice)
	if not opcion_resolucion.item_selected.is_connected(_on_option_button_item_selected):
		opcion_resolucion.item_selected.connect(_on_option_button_item_selected)

	var fila_accesibilidad := _crear_fila_selector("Accesibilidad", "ACCESIBILIDAD")
	_selector_accesibilidad = fila_accesibilidad["selector"] as OptionButton
	_selector_accesibilidad.add_item("Normal", ModoDaltonismo.NORMAL)
	_selector_accesibilidad.add_item("Verde-rojo", ModoDaltonismo.DEUTERANOPIA)
	_selector_accesibilidad.add_item("Rojo-verde", ModoDaltonismo.PROTANOPIA)
	_selector_accesibilidad.add_item("Azul-amarillo", ModoDaltonismo.TRITANOPIA)
	if not _selector_accesibilidad.item_selected.is_connected(_on_selector_accesibilidad_item_selected):
		_selector_accesibilidad.item_selected.connect(_on_selector_accesibilidad_item_selected)

	var fila_temblor := _crear_fila_selector("Sacudida", "SACUDIDA CAMARA")
	_selector_temblor = fila_temblor["selector"] as OptionButton
	_selector_temblor.add_item("Desactivada", IntensidadSacudida.DESACTIVADA)
	_selector_temblor.add_item("Suave", IntensidadSacudida.SUAVE)
	_selector_temblor.add_item("Normal", IntensidadSacudida.NORMAL)
	if not _selector_temblor.item_selected.is_connected(_on_selector_temblor_item_selected):
		_selector_temblor.item_selected.connect(_on_selector_temblor_item_selected)


func _crear_fila_selector(nombre: String, texto_label: String) -> Dictionary:
	var fila := HBoxContainer.new()
	fila.name = nombre
	fila.add_theme_constant_override("separation", 24)

	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_estilizar_label(label, texto_label)
	fila.add_child(label)

	var selector := OptionButton.new()
	selector.custom_minimum_size = Vector2(260, 34)
	selector.size_flags_horizontal = Control.SIZE_SHRINK_END
	_configurar_selector_existente(selector)
	fila.add_child(selector)

	secciones.add_child(fila)
	secciones.move_child(fila, boton_cerrar.get_index())
	return {"fila": fila, "label": label, "selector": selector}


func _asegurar_selector_en_fila(fila: HBoxContainer, nombre_selector: String, items: Array[String]) -> OptionButton:
	var selector := fila.get_node_or_null(nombre_selector) as OptionButton
	if selector == null:
		selector = OptionButton.new()
		selector.name = nombre_selector
		selector.custom_minimum_size = Vector2(260, 34)
		selector.size_flags_horizontal = Control.SIZE_SHRINK_END
		fila.add_child(selector)
	_configurar_selector_existente(selector)
	selector.clear()
	for indice in range(items.size()):
		selector.add_item(items[indice], indice)
	return selector


func _configurar_selector_existente(selector: OptionButton) -> void:
	selector.add_theme_font_override("font", FUENTE_PIXEL)
	selector.add_theme_font_size_override("font_size", 10)
	selector.add_theme_color_override("font_color", Color(0.96, 0.97, 0.92, 1.0))

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.14, 0.16, 0.18, 0.98)
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	normal.border_color = Color(0.42, 0.54, 0.62, 1.0)
	normal.corner_radius_top_left = 6
	normal.corner_radius_top_right = 6
	normal.corner_radius_bottom_right = 6
	normal.corner_radius_bottom_left = 6

	var hover := normal.duplicate()
	hover.bg_color = Color(0.18, 0.21, 0.24, 1.0)
	hover.border_color = Color(0.58, 0.72, 0.82, 1.0)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.10, 0.12, 0.14, 1.0)

	selector.add_theme_stylebox_override("normal", normal)
	selector.add_theme_stylebox_override("hover", hover)
	selector.add_theme_stylebox_override("pressed", pressed)
	selector.add_theme_stylebox_override("focus", hover)

	var popup := selector.get_popup()
	popup.add_theme_font_override("font", FUENTE_PIXEL)
	popup.add_theme_font_size_override("font_size", 10)


func _estilizar_label(label: Label, texto: String) -> void:
	if label == null:
		return

	label.text = texto
	label.add_theme_font_override("font", FUENTE_PIXEL)
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.95, 0.96, 0.94, 1.0))


func _estilizar_boton_pixel(boton: Button, font_size: int) -> void:
	boton.add_theme_font_override("font", FUENTE_PIXEL)
	boton.add_theme_font_size_override("font_size", font_size)
	boton.add_theme_color_override("font_color", Color(0.95, 0.97, 0.94, 1.0))


func _asegurar_overlay_accesibilidad() -> void:
	_overlay_accesibilidad = get_node_or_null("FiltroAccesibilidad") as ColorRect
	if _overlay_accesibilidad == null:
		_overlay_accesibilidad = ColorRect.new()
		_overlay_accesibilidad.name = "FiltroAccesibilidad"
		_overlay_accesibilidad.anchor_left = 0.0
		_overlay_accesibilidad.anchor_top = 0.0
		_overlay_accesibilidad.anchor_right = 1.0
		_overlay_accesibilidad.anchor_bottom = 1.0
		_overlay_accesibilidad.offset_left = 0.0
		_overlay_accesibilidad.offset_top = 0.0
		_overlay_accesibilidad.offset_right = 0.0
		_overlay_accesibilidad.offset_bottom = 0.0
		_overlay_accesibilidad.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_overlay_accesibilidad.color = Color.WHITE
		var material := ShaderMaterial.new()
		material.shader = SHADER_ACCESIBILIDAD
		material.resource_local_to_scene = true
		_overlay_accesibilidad.material = material
		add_child(_overlay_accesibilidad)
		move_child(_overlay_accesibilidad, 0)
	_material_accesibilidad = _overlay_accesibilidad.material as ShaderMaterial


func _cargar_configuracion() -> void:
	var config := ConfigFile.new()
	var resultado := config.load(SETTINGS_PATH)
	if resultado != OK:
		return

	_configuracion["master_volume_db"] = float(config.get_value("audio", "master_volume_db", _configuracion["master_volume_db"]))
	_configuracion["window_mode"] = clampi(int(config.get_value("video", "window_mode", _configuracion["window_mode"])), ModoPantalla.VENTANA, ModoPantalla.PANTALLA_COMPLETA)
	_configuracion["resolution_index"] = clampi(int(config.get_value("video", "resolution_index", _configuracion["resolution_index"])), 0, RESOLUCIONES_PREDETERMINADAS.size() - 1)
	_configuracion["colorblind_mode"] = clampi(int(config.get_value("accessibility", "colorblind_mode", _configuracion["colorblind_mode"])), ModoDaltonismo.NORMAL, ModoDaltonismo.TRITANOPIA)
	_configuracion["screen_shake"] = clampi(int(config.get_value("accessibility", "screen_shake", _configuracion["screen_shake"])), IntensidadSacudida.DESACTIVADA, IntensidadSacudida.NORMAL)


func _guardar_configuracion() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume_db", _configuracion["master_volume_db"])
	config.set_value("video", "window_mode", _configuracion["window_mode"])
	config.set_value("video", "resolution_index", _configuracion["resolution_index"])
	config.set_value("accessibility", "colorblind_mode", _configuracion["colorblind_mode"])
	config.set_value("accessibility", "screen_shake", _configuracion["screen_shake"])
	config.save(SETTINGS_PATH)


func _sincronizar_controles_desde_configuracion() -> void:
	_sincronizando_ui = true
	slider_volumen.value = float(_configuracion["master_volume_db"])
	opcion_resolucion.select(int(_configuracion["resolution_index"]))
	_selector_modo_pantalla.select(int(_configuracion["window_mode"]))
	_selector_accesibilidad.select(int(_configuracion["colorblind_mode"]))
	_selector_temblor.select(int(_configuracion["screen_shake"]))
	_sincronizando_ui = false


func _aplicar_configuracion(guardar: bool = true) -> void:
	_aplicar_volumen()
	_aplicar_ventana_y_resolucion()
	_aplicar_filtro_accesibilidad()
	if guardar:
		_guardar_configuracion()


func _aplicar_volumen() -> void:
	if bus_index < 0:
		return

	var volumen := float(_configuracion["master_volume_db"])
	AudioServer.set_bus_volume_db(bus_index, volumen)
	AudioServer.set_bus_mute(bus_index, volumen <= -35.0)


func _aplicar_ventana_y_resolucion() -> void:
	var ventana := get_window()
	if ventana == null:
		return

	var resolucion := Vector2i(RESOLUCIONES_PREDETERMINADAS[int(_configuracion["resolution_index"])]["size"])
	ventana.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	ventana.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	ventana.content_scale_size = resolucion

	match int(_configuracion["window_mode"]):
		ModoPantalla.VENTANA:
			ventana.mode = Window.MODE_WINDOWED
			ventana.size = resolucion
		ModoPantalla.MAXIMIZADA:
			ventana.mode = Window.MODE_MAXIMIZED
		ModoPantalla.PANTALLA_COMPLETA:
			ventana.mode = Window.MODE_FULLSCREEN


func _aplicar_filtro_accesibilidad() -> void:
	if _overlay_accesibilidad == null or _material_accesibilidad == null:
		return

	var modo := int(_configuracion["colorblind_mode"])
	_overlay_accesibilidad.visible = modo != ModoDaltonismo.NORMAL
	_material_accesibilidad.set_shader_parameter("mode", modo)
	_material_accesibilidad.set_shader_parameter("intensity", 1.0)


func _on_h_slider_value_changed(value: float) -> void:
	if _sincronizando_ui:
		return

	_configuracion["master_volume_db"] = value
	_aplicar_configuracion()


func _on_button_pressed() -> void:
	if audio != null:
		audio.pitch_scale = randf_range(0.96, 1.04)
		audio.stop()
		audio.play()


func _on_button_cerrar_pressed() -> void:
	cerrar()


func _on_boton_cerrar_pressed() -> void:
	cerrar()


func _on_option_button_item_selected(index: int) -> void:
	if _sincronizando_ui:
		return

	_configuracion["resolution_index"] = index
	_aplicar_configuracion()


func _on_selector_modo_pantalla_item_selected(index: int) -> void:
	if _sincronizando_ui:
		return

	_configuracion["window_mode"] = index
	_aplicar_configuracion()


func _on_selector_accesibilidad_item_selected(index: int) -> void:
	if _sincronizando_ui:
		return

	_configuracion["colorblind_mode"] = index
	_aplicar_configuracion()


func _on_selector_temblor_item_selected(index: int) -> void:
	if _sincronizando_ui:
		return

	_configuracion["screen_shake"] = index
	_aplicar_configuracion()
