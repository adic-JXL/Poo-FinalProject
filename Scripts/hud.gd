extends CanvasLayer
class_name HUD

const FUENTE_PIXEL := preload("res://Fuentes/joystix monospace.otf")
const RUTA_TEXTURA_VIDAS := "res://Imagenes/HUD/lives_text.png"
const RUTA_TEXTURA_CORAZON_LLENO := "res://Imagenes/HUD/heart_full.png"
const RUTA_TEXTURA_CORAZON_VACIO := "res://Imagenes/HUD/heart_empty.png"
const RUTA_TEXTURA_STAMINA := "res://Imagenes/HUD/stamina_text.png"
const RUTA_TEXTURA_MARCO_STAMINA := "res://Imagenes/HUD/stamina_frame.png"
const RUTA_TEXTURA_RELLENO_STAMINA := "res://Imagenes/HUD/stamina_fill.png"
const RUTA_TEXTURA_CAJA_ITEM := "res://Imagenes/HUD/item_box_frame.png"
const RUTA_TEXTURA_LLAVE := "res://Imagenes/Objetos/llave_animada/llave_00.png"
const RUTAS_TEXTURAS_GAFAS := [
	"res://Imagenes/Objetos/gafas_00.png",
	"res://Imagenes/Objetos/gafas_01.png",
	"res://Imagenes/Objetos/gafas_02.png",
]

const COLOR_TEXTO_CLARO := Color(0.95, 0.93, 0.72, 1.0)
const COLOR_TEXTO_SUAVE := Color(0.79, 0.84, 0.68, 1.0)
const COLOR_MENSAJE_FONDO := Color(0.10, 0.10, 0.11, 0.76)
const COLOR_MENSAJE_BORDE := Color(0.34, 0.34, 0.29, 0.85)
const COLOR_PENSAMIENTO_FONDO := Color(0.92, 0.94, 0.89, 0.94)
const COLOR_PENSAMIENTO_BORDE := Color(0.18, 0.21, 0.18, 0.82)
const COLOR_PENSAMIENTO_POSITIVO := Color(0.86, 1.0, 0.62, 1.0)
const COLOR_HUD_LISTO := Color(1.0, 1.0, 1.0, 1.0)
const COLOR_HUD_ACTIVO := Color(1.0, 0.96, 0.66, 1.0)
const COLOR_HUD_ENFRIANDO := Color(0.62, 0.64, 0.74, 0.95)
const OFFSET_PENSAMIENTO_PERSONAJE := Vector2(0.0, -14.0)
const DESPLAZAMIENTO_PANEL_PENSAMIENTO := Vector2(0.0, -10.0)
const MARGEN_HORIZONTAL_PENSAMIENTO := 20.0
const MARGEN_SUPERIOR_PENSAMIENTO := 34.0

var _gafas_duracion_max: float = 10.0
var _gafas_cooldown_max: float = 10.0
var _vida_maxima: int = 3
var _jugador_objetivo: Node2D
var _pensamiento_ancho_actual: float = 320.0
var _pensamiento_altura_actual: float = 48.0

var _textura_vidas: Texture2D
var _textura_corazon_lleno: Texture2D
var _textura_corazon_vacio: Texture2D
var _textura_stamina: Texture2D
var _textura_marco_stamina: Texture2D
var _textura_relleno_stamina: Texture2D
var _textura_caja_item: Texture2D
var _textura_llave: Texture2D

var _corazones: Array[TextureRect] = []
var _corazones_container: HBoxContainer
var _stamina_fill_rect: Control
var _stamina_fill_ancho_max: float = 0.0
var _item_box_frame: TextureRect
var _gafas_icono: TextureRect
var _item_box_label: Label
var _llave_icono: TextureRect
var _frames_gafas: Array[Texture2D] = []
var _indice_frame_gafas: int = 0
var _tiempo_animacion_gafas: float = 0.0
var _pensamiento_root: Control
var _pensamiento_panel: PanelContainer
var _pensamiento_label: Label
var _pensamiento_burbujas: Array[Panel] = []
var _tween_pensamiento: Tween

@onready var mensaje_panel: PanelContainer = $Control/MensajePanel
@onready var mensaje_vbox: VBoxContainer = $Control/MensajePanel/MarginContainer/VBoxContainer
@onready var mensaje_label: Label = $Control/MensajePanel/MarginContainer/VBoxContainer/MensajeLabel
@onready var estado_label: Label = $Control/MensajePanel/MarginContainer/VBoxContainer/EstadoLabel
@onready var llave_label: Label = $Control/MensajePanel/MarginContainer/VBoxContainer/LlaveLabel
@onready var checkpoint_label: Label = $Control/MensajePanel/MarginContainer/VBoxContainer/CheckpointLabel

@onready var stamina_panel: PanelContainer = $Control/StaminaPanel
@onready var stamina_vbox: VBoxContainer = $Control/StaminaPanel/MarginContainer/VBoxContainer
@onready var stamina_titulo_label: Label = $Control/StaminaPanel/MarginContainer/VBoxContainer/TituloLabel
@onready var estamina_barra: ProgressBar = $Control/StaminaPanel/MarginContainer/VBoxContainer/EstaminaBarra
@onready var estamina_label: Label = $Control/StaminaPanel/MarginContainer/VBoxContainer/EstaminaLabel
@onready var sprint_label: Label = $Control/StaminaPanel/MarginContainer/VBoxContainer/SprintLabel

@onready var vida_panel: PanelContainer = $Control/VidaPanel
@onready var vida_vbox: VBoxContainer = $Control/VidaPanel/MarginContainer/VBoxContainer
@onready var vida_label: Label = $Control/VidaPanel/MarginContainer/VBoxContainer/VidaLabel

@onready var gafas_panel: PanelContainer = $Control/GafasPanel
@onready var gafas_vbox: VBoxContainer = $Control/GafasPanel/MarginContainer/VBoxContainer
@onready var gafas_titulo_label: Label = $Control/GafasPanel/MarginContainer/VBoxContainer/TituloLabel
@onready var gafas_estado_label: Label = $Control/GafasPanel/MarginContainer/VBoxContainer/GafasEstadoLabel
@onready var gafas_barra: ProgressBar = $Control/GafasPanel/MarginContainer/VBoxContainer/GafasBarra
@onready var gafas_cooldown_label: Label = $Control/GafasPanel/MarginContainer/VBoxContainer/GafasCooldownLabel


func _ready() -> void:
	_cargar_texturas_hud()
	_configurar_layout_base()
	set_process(true)


func _process(delta: float) -> void:
	_actualizar_animacion_gafas(delta)
	_actualizar_posicion_pensamiento()


func configurar_jugador(jugador) -> void:
	_jugador_objetivo = jugador
	_gafas_duracion_max = jugador.gafas_duracion
	_gafas_cooldown_max = jugador.gafas_cooldown_maximo
	_vida_maxima = max(jugador.obtener_vida_inicial(), 1)
	_asegurar_corazones()

	jugador.vida_cambiada.connect(actualizar_vida)
	jugador.estado_cambiado.connect(actualizar_estado)
	jugador.estamina_cambiada.connect(actualizar_estamina)
	jugador.sprint_cambiado.connect(actualizar_sprint)
	jugador.gafas_actualizadas.connect(actualizar_gafas)

	actualizar_vida(jugador.vida)
	actualizar_estado(jugador.estado_actual)
	actualizar_estamina(jugador.obtener_estamina_actual(), jugador.obtener_estamina_maxima())
	actualizar_sprint(jugador.esta_haciendo_sprint())
	actualizar_gafas(
		jugador.gafas_activas(),
		jugador.obtener_duracion_gafas_restante(),
		jugador.obtener_cooldown_gafas_restante(),
		jugador.obtener_cooldown_actual_gafas(),
		jugador.obtener_siguiente_cooldown_gafas()
	)


func mostrar_mensaje(texto: String) -> void:
	mensaje_label.text = texto


func mostrar_pensamiento(texto: String, positivo: bool = false) -> void:
	if texto.strip_edges().is_empty():
		return

	_configurar_pensamiento_visual()
	if _tween_pensamiento != null and _tween_pensamiento.is_valid():
		_tween_pensamiento.kill()

	_aplicar_estilo_pensamiento(positivo)
	_pensamiento_label.text = texto
	_pensamiento_label.add_theme_color_override("font_color", Color(0.11, 0.13, 0.12, 1.0) if positivo else Color(0.12, 0.14, 0.16, 1.0))
	_ajustar_layout_pensamiento(texto)
	_actualizar_posicion_pensamiento()
	_pensamiento_root.modulate = Color(1, 1, 1, 0)
	_pensamiento_root.show()

	_tween_pensamiento = create_tween()
	_tween_pensamiento.set_ignore_time_scale(true)
	_tween_pensamiento.set_trans(Tween.TRANS_SINE)
	_tween_pensamiento.set_ease(Tween.EASE_OUT)
	_tween_pensamiento.tween_property(_pensamiento_root, "modulate:a", 1.0, 0.24)
	_tween_pensamiento.tween_interval(4.2)
	_tween_pensamiento.set_ease(Tween.EASE_IN)
	_tween_pensamiento.tween_property(_pensamiento_root, "modulate:a", 0.0, 0.35)
	_tween_pensamiento.tween_callback(_pensamiento_root.hide)


func actualizar_vida(vida_actual: int) -> void:
	vida_label.text = "Vida: %d" % vida_actual
	for indice in range(_corazones.size()):
		_corazones[indice].texture = _textura_corazon_lleno if indice < vida_actual else _textura_corazon_vacio


func actualizar_estado(estado: StringName) -> void:
	estado_label.text = "Estado: %s" % estado


func actualizar_estamina(actual: float, maxima: float) -> void:
	estamina_label.text = "Estamina: %.0f / %.0f" % [actual, maxima]
	_actualizar_relleno_stamina(actual, maxima)


func actualizar_sprint(activo: bool) -> void:
	sprint_label.text = "Sprint: %s" % ("activo" if activo else "inactivo")


func actualizar_llave(tiene_llave: bool) -> void:
	llave_label.text = "Llave: %s" % ("obtenida" if tiene_llave else "pendiente")
	if _llave_icono != null:
		_llave_icono.modulate = COLOR_HUD_ACTIVO if tiene_llave else COLOR_HUD_ENFRIANDO


func actualizar_checkpoint(activo: bool) -> void:
	checkpoint_label.text = "Checkpoint: %s" % ("activo" if activo else "pendiente")
	checkpoint_label.add_theme_color_override("font_color", COLOR_HUD_ACTIVO if activo else COLOR_TEXTO_SUAVE)


func actualizar_gafas(activa: bool, duracion_restante: float, cooldown_restante: float, cooldown_actual: float, siguiente_cooldown: float) -> void:
	if activa:
		gafas_estado_label.text = "Gafas activas"
		gafas_barra.max_value = _gafas_duracion_max
		gafas_barra.value = duracion_restante
		gafas_cooldown_label.text = "Vision clara: %.1fs" % duracion_restante
		_actualizar_item_box_visual(COLOR_HUD_ACTIVO, "")
		return

	if cooldown_restante > 0.0:
		gafas_estado_label.text = "Gafas enfriando"
		gafas_barra.max_value = max(cooldown_actual, 0.1)
		gafas_barra.value = cooldown_restante
		gafas_cooldown_label.text = "Cooldown: %.1fs" % cooldown_restante
		_actualizar_item_box_visual(COLOR_HUD_ENFRIANDO, "CD")
		return

	gafas_estado_label.text = "Gafas listas"
	gafas_barra.max_value = _gafas_cooldown_max
	gafas_barra.value = _gafas_cooldown_max
	gafas_cooldown_label.text = "Q para activar (sig.: %.1fs)" % siguiente_cooldown
	_actualizar_item_box_visual(COLOR_HUD_LISTO, "Q")


func _configurar_layout_base() -> void:
	_aplicar_estilo_mensaje()
	_aplicar_panel_transparente(stamina_panel)
	_aplicar_panel_transparente(vida_panel)
	_aplicar_panel_transparente(gafas_panel)
	_configurar_fuentes_colores()
	_configurar_vida_visual()
	_configurar_stamina_visual()
	stamina_panel.show()
	_configurar_gafas_visual()
	_configurar_llave_visual()
	_configurar_pensamiento_visual()


func _aplicar_estilo_mensaje() -> void:
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = COLOR_MENSAJE_FONDO
	fondo.corner_radius_top_left = 5
	fondo.corner_radius_top_right = 5
	fondo.corner_radius_bottom_right = 5
	fondo.corner_radius_bottom_left = 5
	fondo.border_width_left = 1
	fondo.border_width_top = 1
	fondo.border_width_right = 1
	fondo.border_width_bottom = 1
	fondo.border_color = COLOR_MENSAJE_BORDE
	mensaje_panel.add_theme_stylebox_override("panel", fondo)
	mensaje_panel.offset_right = 312.0
	mensaje_panel.offset_bottom = 170.0


func _configurar_pensamiento_visual() -> void:
	if _pensamiento_root != null:
		return

	_pensamiento_root = Control.new()
	_pensamiento_root.name = "PensamientoRoot"
	_pensamiento_root.anchor_left = 0.0
	_pensamiento_root.anchor_top = 0.0
	_pensamiento_root.anchor_right = 0.0
	_pensamiento_root.anchor_bottom = 0.0
	_pensamiento_root.offset_left = 0.0
	_pensamiento_root.offset_top = 0.0
	_pensamiento_root.offset_right = 0.0
	_pensamiento_root.offset_bottom = 0.0
	_pensamiento_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Control.add_child(_pensamiento_root)

	_pensamiento_panel = PanelContainer.new()
	_pensamiento_panel.name = "PensamientoPanel"
	_pensamiento_panel.offset_left = -160.0
	_pensamiento_panel.offset_top = -70.0
	_pensamiento_panel.offset_right = 160.0
	_pensamiento_panel.offset_bottom = -22.0
	_pensamiento_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_aplicar_estilo_pensamiento(false)
	_pensamiento_root.add_child(_pensamiento_panel)

	var margen := MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 18)
	margen.add_theme_constant_override("margin_top", 11)
	margen.add_theme_constant_override("margin_right", 18)
	margen.add_theme_constant_override("margin_bottom", 11)
	_pensamiento_panel.add_child(margen)

	_pensamiento_label = Label.new()
	_pensamiento_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pensamiento_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_pensamiento_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_pensamiento_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_pensamiento_label.add_theme_font_override("font", FUENTE_PIXEL)
	_pensamiento_label.add_theme_color_override("font_color", Color(0.12, 0.14, 0.16, 1.0))
	_pensamiento_label.add_theme_font_size_override("font_size", 12)
	_pensamiento_label.add_theme_color_override("font_outline_color", Color(1.0, 1.0, 1.0, 0.18))
	_pensamiento_label.add_theme_constant_override("outline_size", 1)
	margen.add_child(_pensamiento_label)

	_agregar_burbuja_pensamiento(Vector2(14.0, 14.0), Vector2(-12.0, -18.0))
	_agregar_burbuja_pensamiento(Vector2(10.0, 10.0), Vector2(-2.0, -8.0))
	_agregar_burbuja_pensamiento(Vector2(7.0, 7.0), Vector2(8.0, 0.0))

	_pensamiento_root.hide()


func _aplicar_estilo_pensamiento(positivo: bool) -> void:
	if _pensamiento_panel == null:
		return

	var fondo := StyleBoxFlat.new()
	fondo.bg_color = COLOR_PENSAMIENTO_FONDO if not positivo else Color(0.86, 0.92, 0.74, 0.96)
	fondo.corner_radius_top_left = 18
	fondo.corner_radius_top_right = 18
	fondo.corner_radius_bottom_right = 16
	fondo.corner_radius_bottom_left = 16
	fondo.border_width_left = 2
	fondo.border_width_top = 2
	fondo.border_width_right = 2
	fondo.border_width_bottom = 2
	fondo.border_color = COLOR_PENSAMIENTO_BORDE if not positivo else Color(0.28, 0.38, 0.20, 0.86)
	fondo.shadow_color = Color(0.0, 0.0, 0.0, 0.22)
	fondo.shadow_size = 2
	_pensamiento_panel.add_theme_stylebox_override("panel", fondo)
	for burbuja in _pensamiento_burbujas:
		var estilo_burbuja := StyleBoxFlat.new()
		estilo_burbuja.bg_color = fondo.bg_color
		estilo_burbuja.border_color = fondo.border_color
		estilo_burbuja.border_width_left = 2
		estilo_burbuja.border_width_top = 2
		estilo_burbuja.border_width_right = 2
		estilo_burbuja.border_width_bottom = 2
		estilo_burbuja.corner_radius_top_left = 32
		estilo_burbuja.corner_radius_top_right = 32
		estilo_burbuja.corner_radius_bottom_right = 32
		estilo_burbuja.corner_radius_bottom_left = 32
		burbuja.add_theme_stylebox_override("panel", estilo_burbuja)


func _agregar_burbuja_pensamiento(tamano: Vector2, offset: Vector2) -> void:
	var burbuja := Panel.new()
	burbuja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	burbuja.offset_left = offset.x
	burbuja.offset_top = offset.y
	burbuja.offset_right = offset.x + tamano.x
	burbuja.offset_bottom = offset.y + tamano.y
	_pensamiento_root.add_child(burbuja)
	_pensamiento_burbujas.append(burbuja)


func _actualizar_animacion_gafas(delta: float) -> void:
	if _gafas_icono == null or _frames_gafas.is_empty():
		return

	_tiempo_animacion_gafas += delta
	if _tiempo_animacion_gafas < 0.16:
		return

	_tiempo_animacion_gafas = 0.0
	_indice_frame_gafas = (_indice_frame_gafas + 1) % _frames_gafas.size()
	_gafas_icono.texture = _frames_gafas[_indice_frame_gafas]


func _ajustar_layout_pensamiento(texto: String) -> void:
	if _pensamiento_panel == null or _pensamiento_label == null:
		return

	var font_size := 12
	if texto.length() >= 58:
		font_size = 10
	elif texto.length() >= 40:
		font_size = 11

	_pensamiento_label.add_theme_font_size_override("font_size", font_size)

	var ancho_texto: float = FUENTE_PIXEL.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var ancho_panel := clampf(ancho_texto + 46.0, 230.0, 352.0)
	var ancho_interno := maxf(ancho_panel - 36.0, 1.0)
	var lineas_estimadas := maxi(1, int(ceili(ancho_texto / ancho_interno)))
	var altura_panel := clampf(34.0 + (lineas_estimadas * float(font_size + 7)), 42.0, 86.0)

	_pensamiento_ancho_actual = ancho_panel
	_pensamiento_altura_actual = altura_panel
	_pensamiento_panel.offset_left = -ancho_panel * 0.5
	_pensamiento_panel.offset_right = ancho_panel * 0.5
	_pensamiento_panel.offset_bottom = -22.0
	_pensamiento_panel.offset_top = _pensamiento_panel.offset_bottom - altura_panel


func _actualizar_posicion_pensamiento() -> void:
	if _pensamiento_root == null or not _pensamiento_root.visible:
		return

	if _jugador_objetivo == null or not is_instance_valid(_jugador_objetivo):
		return

	var transformacion_canvas := get_viewport().get_canvas_transform()
	var posicion_pantalla: Vector2 = transformacion_canvas * (_jugador_objetivo.global_position + OFFSET_PENSAMIENTO_PERSONAJE)
	var viewport_rect := get_viewport().get_visible_rect()
	var margen_horizontal_actual := maxf(MARGEN_HORIZONTAL_PENSAMIENTO, (_pensamiento_ancho_actual * 0.5) + 8.0)
	var margen_superior_actual := maxf(MARGEN_SUPERIOR_PENSAMIENTO, _pensamiento_altura_actual + 8.0)
	posicion_pantalla.x = clampf(posicion_pantalla.x, margen_horizontal_actual, viewport_rect.size.x - margen_horizontal_actual)
	posicion_pantalla.y = clampf(posicion_pantalla.y, margen_superior_actual, viewport_rect.size.y - 60.0)
	_pensamiento_root.position = posicion_pantalla + DESPLAZAMIENTO_PANEL_PENSAMIENTO


func _configurar_fuentes_colores() -> void:
	mensaje_label.add_theme_font_override("font", FUENTE_PIXEL)
	mensaje_label.add_theme_color_override("font_color", COLOR_TEXTO_CLARO)
	mensaje_label.add_theme_font_size_override("font_size", 11)
	estado_label.add_theme_font_override("font", FUENTE_PIXEL)
	estado_label.add_theme_color_override("font_color", COLOR_TEXTO_CLARO)
	estado_label.add_theme_font_size_override("font_size", 10)
	llave_label.add_theme_font_override("font", FUENTE_PIXEL)
	llave_label.add_theme_color_override("font_color", COLOR_TEXTO_CLARO)
	llave_label.add_theme_font_size_override("font_size", 10)
	checkpoint_label.add_theme_font_override("font", FUENTE_PIXEL)
	checkpoint_label.add_theme_color_override("font_color", COLOR_TEXTO_SUAVE)
	checkpoint_label.add_theme_font_size_override("font_size", 10)
	estamina_label.add_theme_color_override("font_color", COLOR_TEXTO_CLARO)
	estamina_label.add_theme_font_size_override("font_size", 11)
	sprint_label.add_theme_color_override("font_color", COLOR_TEXTO_CLARO)
	sprint_label.add_theme_font_size_override("font_size", 11)
	vida_label.add_theme_color_override("font_color", COLOR_TEXTO_CLARO)
	gafas_estado_label.add_theme_color_override("font_color", COLOR_TEXTO_CLARO)
	gafas_estado_label.add_theme_font_size_override("font_size", 12)
	gafas_cooldown_label.add_theme_color_override("font_color", COLOR_TEXTO_CLARO)
	gafas_cooldown_label.add_theme_font_size_override("font_size", 11)


func _configurar_vida_visual() -> void:
	vida_panel.offset_left = -210.0
	vida_panel.offset_right = -16.0
	vida_panel.offset_top = 14.0
	vida_panel.offset_bottom = 62.0
	vida_label.hide()

	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_END
	fila.add_theme_constant_override("separation", 6)
	vida_vbox.add_child(fila)
	vida_vbox.move_child(fila, 0)

	var titulo := _crear_texture_rect(_textura_vidas, Vector2(88, 26), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	fila.add_child(titulo)

	_corazones_container = HBoxContainer.new()
	_corazones_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_corazones_container.add_theme_constant_override("separation", 1)
	fila.add_child(_corazones_container)
	_asegurar_corazones()


func _configurar_stamina_visual() -> void:
	stamina_panel.offset_left = -172.0
	stamina_panel.offset_right = 172.0
	stamina_panel.offset_top = 8.0
	stamina_panel.offset_bottom = 66.0
	stamina_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	stamina_vbox.add_theme_constant_override("separation", 1)
	stamina_titulo_label.hide()
	estamina_barra.hide()
	estamina_label.hide()
	sprint_label.hide()

	var titulo := Label.new()
	titulo.text = "STAMINA"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_override("font", FUENTE_PIXEL)
	titulo.add_theme_font_size_override("font_size", 13)
	titulo.add_theme_color_override("font_color", Color(0.88, 0.94, 0.43, 1.0))
	titulo.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.03, 1.0))
	titulo.add_theme_constant_override("outline_size", 4)
	stamina_vbox.add_child(titulo)
	stamina_vbox.move_child(titulo, 0)

	var holder := Panel.new()
	holder.custom_minimum_size = Vector2(284, 30)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var marco_style := StyleBoxFlat.new()
	marco_style.bg_color = Color(0.055, 0.058, 0.065, 0.92)
	marco_style.border_width_left = 3
	marco_style.border_width_top = 3
	marco_style.border_width_right = 3
	marco_style.border_width_bottom = 3
	marco_style.border_color = Color(0.55, 0.66, 0.48, 1.0)
	holder.add_theme_stylebox_override("panel", marco_style)
	stamina_vbox.add_child(holder)
	stamina_vbox.move_child(holder, 1)

	var fondo_barra := ColorRect.new()
	fondo_barra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo_barra.position = Vector2(14, 9)
	fondo_barra.size = Vector2(256, 12)
	fondo_barra.color = Color(0.18, 0.13, 0.20, 0.96)
	holder.add_child(fondo_barra)

	var fill_holder := Control.new()
	fill_holder.position = fondo_barra.position
	fill_holder.custom_minimum_size = fondo_barra.size
	fill_holder.size = fondo_barra.size
	fill_holder.clip_contents = true
	fill_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(fill_holder)

	var stamina_fill := Control.new()
	stamina_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stamina_fill.position = Vector2.ZERO
	stamina_fill.size = fill_holder.size
	stamina_fill.clip_contents = true
	_stamina_fill_rect = stamina_fill
	fill_holder.add_child(_stamina_fill_rect)
	_stamina_fill_ancho_max = fill_holder.size.x

	var segmentos: int = 20
	var separacion: float = 2.0
	var ancho_segmento: float = floor((fill_holder.size.x - (float(segmentos - 1) * separacion)) / float(segmentos))
	for indice in range(segmentos):
		var bloque := ColorRect.new()
		bloque.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bloque.position = Vector2(float(indice) * (ancho_segmento + separacion), 0)
		bloque.size = Vector2(ancho_segmento, fill_holder.size.y)
		bloque.color = Color(0.86, 0.88, 0.10, 0.98)
		stamina_fill.add_child(bloque)

		var brillo := ColorRect.new()
		brillo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		brillo.position = bloque.position + Vector2(1, 1)
		brillo.size = Vector2(max(ancho_segmento - 2.0, 1.0), 3)
		brillo.color = Color(1.0, 0.98, 0.64, 0.30)
		stamina_fill.add_child(brillo)


func _configurar_gafas_visual() -> void:
	gafas_panel.offset_left = -196.0
	gafas_panel.offset_right = -18.0
	gafas_panel.offset_top = -112.0
	gafas_panel.offset_bottom = -18.0
	gafas_vbox.add_theme_constant_override("separation", 3)
	gafas_titulo_label.hide()

	var cabecera := HBoxContainer.new()
	cabecera.add_theme_constant_override("separation", 8)
	cabecera.alignment = BoxContainer.ALIGNMENT_BEGIN
	gafas_vbox.add_child(cabecera)
	gafas_vbox.move_child(cabecera, 0)

	var slot := Control.new()
	slot.custom_minimum_size = Vector2(54, 54)
	cabecera.add_child(slot)

	_item_box_frame = _crear_texture_rect(_textura_caja_item, slot.custom_minimum_size, TextureRect.STRETCH_SCALE)
	_item_box_frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	slot.add_child(_item_box_frame)

	_gafas_icono = _crear_texture_rect(_obtener_frame_gafas_actual(), Vector2(34, 34), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_gafas_icono.position = Vector2(10, 8)
	slot.add_child(_gafas_icono)

	_item_box_label = Label.new()
	_item_box_label.anchor_left = 0.0
	_item_box_label.anchor_top = 1.0
	_item_box_label.anchor_right = 1.0
	_item_box_label.anchor_bottom = 1.0
	_item_box_label.offset_top = -18.0
	_item_box_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_item_box_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_item_box_label.add_theme_font_size_override("font_size", 10)
	_item_box_label.add_theme_color_override("font_color", Color(0.12, 0.08, 0.16, 1.0))
	_item_box_label.text = "Q"
	slot.add_child(_item_box_label)

	gafas_vbox.remove_child(gafas_estado_label)
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 1)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cabecera.add_child(info)

	var titulo := Label.new()
	titulo.text = "Gafas"
	titulo.add_theme_color_override("font_color", COLOR_TEXTO_CLARO)
	titulo.add_theme_font_size_override("font_size", 13)
	info.add_child(titulo)
	info.add_child(gafas_estado_label)

	gafas_barra.custom_minimum_size = Vector2(128, 8)
	gafas_barra.size = Vector2(128, 8)
	gafas_barra.show_percentage = false
	_configurar_barra_plana(gafas_barra, Color(0.25, 0.22, 0.30, 0.88), Color(0.64, 0.90, 0.24, 1.0))
	_actualizar_item_box_visual(COLOR_HUD_LISTO, "Q")


func _configurar_llave_visual() -> void:
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 6)
	fila.alignment = BoxContainer.ALIGNMENT_BEGIN

	_llave_icono = _crear_texture_rect(_textura_llave, Vector2(14, 18), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_llave_icono.modulate = COLOR_HUD_ENFRIANDO
	fila.add_child(_llave_icono)

	mensaje_vbox.remove_child(llave_label)
	fila.add_child(llave_label)
	mensaje_vbox.add_child(fila)
	mensaje_vbox.move_child(fila, 2)


func _asegurar_corazones() -> void:
	if _corazones_container == null:
		return

	for child in _corazones_container.get_children():
		child.queue_free()

	_corazones.clear()
	for _indice in range(_vida_maxima):
		var corazon := _crear_texture_rect(_textura_corazon_vacio, Vector2(18, 18), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		_corazones_container.add_child(corazon)
		_corazones.append(corazon)


func _actualizar_relleno_stamina(actual: float, maxima: float) -> void:
	if _stamina_fill_rect == null:
		return

	var ratio := 0.0 if maxima <= 0.0 else clampf(actual / maxima, 0.0, 1.0)
	_stamina_fill_rect.size.x = _stamina_fill_ancho_max * ratio


func _actualizar_item_box_visual(color_objetivo: Color, texto: String) -> void:
	if _item_box_frame != null:
		_item_box_frame.modulate = color_objetivo
	if _gafas_icono != null:
		_gafas_icono.modulate = color_objetivo
	if _item_box_label != null:
		_item_box_label.text = texto


func _aplicar_panel_transparente(panel: PanelContainer) -> void:
	panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())


func _configurar_barra_plana(barra: ProgressBar, color_fondo: Color, color_lleno: Color) -> void:
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = color_fondo
	fondo.corner_radius_top_left = 2
	fondo.corner_radius_top_right = 2
	fondo.corner_radius_bottom_right = 2
	fondo.corner_radius_bottom_left = 2

	var lleno := StyleBoxFlat.new()
	lleno.bg_color = color_lleno
	lleno.corner_radius_top_left = 2
	lleno.corner_radius_top_right = 2
	lleno.corner_radius_bottom_right = 2
	lleno.corner_radius_bottom_left = 2

	barra.add_theme_stylebox_override("background", fondo)
	barra.add_theme_stylebox_override("fill", lleno)


func _cargar_texturas_hud() -> void:
	_textura_vidas = _cargar_textura_desde_archivo(RUTA_TEXTURA_VIDAS)
	_textura_corazon_lleno = _cargar_textura_desde_archivo(RUTA_TEXTURA_CORAZON_LLENO)
	_textura_corazon_vacio = _cargar_textura_desde_archivo(RUTA_TEXTURA_CORAZON_VACIO)
	_textura_stamina = _cargar_textura_desde_archivo(RUTA_TEXTURA_STAMINA)
	_textura_marco_stamina = _cargar_textura_recortada_desde_archivo(RUTA_TEXTURA_MARCO_STAMINA, Rect2i(0, 0, 388, 78))
	_textura_relleno_stamina = _cargar_textura_desde_archivo(RUTA_TEXTURA_RELLENO_STAMINA)
	_textura_caja_item = _cargar_textura_desde_archivo(RUTA_TEXTURA_CAJA_ITEM)
	_textura_llave = _cargar_textura_desde_archivo(RUTA_TEXTURA_LLAVE)
	_frames_gafas = _cargar_secuencia_desde_archivo(RUTAS_TEXTURAS_GAFAS)


func _cargar_textura_desde_archivo(ruta: String) -> Texture2D:
	var imagen := Image.load_from_file(ProjectSettings.globalize_path(ruta))
	if imagen == null or imagen.is_empty():
		return null
	return ImageTexture.create_from_image(imagen)


func _cargar_textura_recortada_desde_archivo(ruta: String, region: Rect2i) -> Texture2D:
	var imagen := Image.load_from_file(ProjectSettings.globalize_path(ruta))
	if imagen == null or imagen.is_empty():
		return null

	var region_ajustada := Rect2i(
		clampi(region.position.x, 0, imagen.get_width() - 1),
		clampi(region.position.y, 0, imagen.get_height() - 1),
		clampi(region.size.x, 1, imagen.get_width() - region.position.x),
		clampi(region.size.y, 1, imagen.get_height() - region.position.y)
	)
	var recorte := imagen.get_region(region_ajustada)
	return ImageTexture.create_from_image(recorte)


func _cargar_secuencia_desde_archivo(rutas: Array) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	for ruta in rutas:
		var textura := _cargar_textura_desde_archivo(ruta)
		if textura != null:
			frames.append(textura)

	return frames


func _obtener_frame_gafas_actual() -> Texture2D:
	if _frames_gafas.is_empty():
		return null

	return _frames_gafas[clampi(_indice_frame_gafas, 0, _frames_gafas.size() - 1)]


func _crear_texture_rect(textura: Texture2D, tamano: Vector2, stretch_mode: int) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = textura
	rect.custom_minimum_size = tamano
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = stretch_mode
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return rect
