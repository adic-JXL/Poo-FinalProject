extends CanvasLayer
class_name HUD

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
const COLOR_PENSAMIENTO_FONDO := Color(0.025, 0.028, 0.035, 0.82)
const COLOR_PENSAMIENTO_BORDE := Color(0.52, 0.56, 0.48, 0.58)
const COLOR_PENSAMIENTO_POSITIVO := Color(0.86, 1.0, 0.62, 1.0)
const COLOR_HUD_LISTO := Color(1.0, 1.0, 1.0, 1.0)
const COLOR_HUD_ACTIVO := Color(1.0, 0.96, 0.66, 1.0)
const COLOR_HUD_ENFRIANDO := Color(0.62, 0.64, 0.74, 0.95)

var _gafas_duracion_max: float = 10.0
var _gafas_cooldown_max: float = 10.0
var _vida_maxima: int = 3

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
var _stamina_fill_rect: TextureRect
var _stamina_fill_ancho_max: float = 0.0
var _item_box_frame: TextureRect
var _gafas_icono: TextureRect
var _item_box_label: Label
var _llave_icono: TextureRect
var _frames_gafas: Array[Texture2D] = []
var _indice_frame_gafas: int = 0
var _tiempo_animacion_gafas: float = 0.0
var _pensamiento_panel: PanelContainer
var _pensamiento_label: Label
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
	if _gafas_icono == null or _frames_gafas.is_empty():
		return

	_tiempo_animacion_gafas += delta
	if _tiempo_animacion_gafas < 0.16:
		return

	_tiempo_animacion_gafas = 0.0
	_indice_frame_gafas = (_indice_frame_gafas + 1) % _frames_gafas.size()
	_gafas_icono.texture = _frames_gafas[_indice_frame_gafas]


func configurar_jugador(jugador) -> void:
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
	_pensamiento_label.add_theme_color_override("font_color", COLOR_PENSAMIENTO_POSITIVO if positivo else COLOR_TEXTO_CLARO)
	_pensamiento_panel.modulate = Color(1, 1, 1, 0)
	_pensamiento_panel.show()

	_tween_pensamiento = create_tween()
	_tween_pensamiento.set_ignore_time_scale(true)
	_tween_pensamiento.set_trans(Tween.TRANS_SINE)
	_tween_pensamiento.set_ease(Tween.EASE_OUT)
	_tween_pensamiento.tween_property(_pensamiento_panel, "modulate:a", 1.0, 0.28)
	_tween_pensamiento.tween_interval(4.9)
	_tween_pensamiento.set_ease(Tween.EASE_IN)
	_tween_pensamiento.tween_property(_pensamiento_panel, "modulate:a", 0.0, 0.45)
	_tween_pensamiento.tween_callback(_pensamiento_panel.hide)


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
	mensaje_panel.offset_right = 322.0
	mensaje_panel.offset_bottom = 178.0


func _configurar_pensamiento_visual() -> void:
	if _pensamiento_panel != null:
		return

	_pensamiento_panel = PanelContainer.new()
	_pensamiento_panel.name = "PensamientoPanel"
	_pensamiento_panel.anchor_left = 0.5
	_pensamiento_panel.anchor_top = 1.0
	_pensamiento_panel.anchor_right = 0.5
	_pensamiento_panel.anchor_bottom = 1.0
	_pensamiento_panel.offset_left = -340.0
	_pensamiento_panel.offset_top = -96.0
	_pensamiento_panel.offset_right = 340.0
	_pensamiento_panel.offset_bottom = -28.0
	_pensamiento_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_aplicar_estilo_pensamiento(false)
	$Control.add_child(_pensamiento_panel)

	var margen := MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 20)
	margen.add_theme_constant_override("margin_top", 12)
	margen.add_theme_constant_override("margin_right", 20)
	margen.add_theme_constant_override("margin_bottom", 12)
	_pensamiento_panel.add_child(margen)

	_pensamiento_label = Label.new()
	_pensamiento_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pensamiento_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_pensamiento_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_pensamiento_label.add_theme_color_override("font_color", COLOR_TEXTO_CLARO)
	_pensamiento_label.add_theme_font_size_override("font_size", 16)
	margen.add_child(_pensamiento_label)

	_pensamiento_panel.hide()


func _aplicar_estilo_pensamiento(positivo: bool) -> void:
	if _pensamiento_panel == null:
		return

	var fondo := StyleBoxFlat.new()
	fondo.bg_color = COLOR_PENSAMIENTO_FONDO if not positivo else Color(0.055, 0.075, 0.045, 0.86)
	fondo.corner_radius_top_left = 8
	fondo.corner_radius_top_right = 8
	fondo.corner_radius_bottom_right = 8
	fondo.corner_radius_bottom_left = 8
	fondo.border_width_left = 1
	fondo.border_width_top = 1
	fondo.border_width_right = 1
	fondo.border_width_bottom = 1
	fondo.border_color = COLOR_PENSAMIENTO_BORDE if not positivo else Color(0.64, 0.82, 0.38, 0.72)
	_pensamiento_panel.add_theme_stylebox_override("panel", fondo)


func _configurar_fuentes_colores() -> void:
	mensaje_label.add_theme_color_override("font_color", COLOR_TEXTO_CLARO)
	mensaje_label.add_theme_font_size_override("font_size", 14)
	estado_label.add_theme_color_override("font_color", COLOR_TEXTO_CLARO)
	estado_label.add_theme_font_size_override("font_size", 12)
	llave_label.add_theme_color_override("font_color", COLOR_TEXTO_CLARO)
	llave_label.add_theme_font_size_override("font_size", 12)
	checkpoint_label.add_theme_color_override("font_color", COLOR_TEXTO_SUAVE)
	checkpoint_label.add_theme_font_size_override("font_size", 12)
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
	stamina_panel.offset_left = -185.0
	stamina_panel.offset_right = 185.0
	stamina_panel.offset_top = 10.0
	stamina_panel.offset_bottom = 88.0
	stamina_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	stamina_vbox.add_theme_constant_override("separation", 3)
	stamina_titulo_label.hide()
	estamina_barra.hide()

	var titulo := _crear_texture_rect(_textura_stamina, Vector2(170, 26), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	stamina_vbox.add_child(titulo)
	stamina_vbox.move_child(titulo, 0)

	var holder := Control.new()
	holder.custom_minimum_size = Vector2(250, 38)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stamina_vbox.add_child(holder)
	stamina_vbox.move_child(holder, 1)

	var marco := _crear_texture_rect(_textura_marco_stamina, holder.custom_minimum_size, TextureRect.STRETCH_SCALE)
	marco.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.add_child(marco)

	_stamina_fill_rect = _crear_texture_rect(_textura_relleno_stamina, Vector2(164, 14), TextureRect.STRETCH_SCALE)
	_stamina_fill_rect.position = Vector2(20, 7)
	_stamina_fill_rect.size = Vector2(164, 14)
	holder.add_child(_stamina_fill_rect)
	holder.move_child(_stamina_fill_rect, 0)
	_stamina_fill_ancho_max = 164.0


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
	_textura_marco_stamina = _cargar_textura_desde_archivo(RUTA_TEXTURA_MARCO_STAMINA)
	_textura_relleno_stamina = _cargar_textura_desde_archivo(RUTA_TEXTURA_RELLENO_STAMINA)
	_textura_caja_item = _cargar_textura_desde_archivo(RUTA_TEXTURA_CAJA_ITEM)
	_textura_llave = _cargar_textura_desde_archivo(RUTA_TEXTURA_LLAVE)
	_frames_gafas = _cargar_secuencia_desde_archivo(RUTAS_TEXTURAS_GAFAS)


func _cargar_textura_desde_archivo(ruta: String) -> Texture2D:
	var imagen := Image.load_from_file(ProjectSettings.globalize_path(ruta))
	if imagen == null or imagen.is_empty():
		return null
	return ImageTexture.create_from_image(imagen)


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
