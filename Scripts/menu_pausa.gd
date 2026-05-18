extends Control
class_name MenuPausa

const FUENTE_PIXEL := preload("res://Fuentes/joystix monospace.otf")

signal continuar_solicitado
signal reiniciar_solicitado
signal volver_menu_solicitado

@onready var panel_container: PanelContainer = $CenterContainer/PanelContainer
@onready var titulo_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TituloLabel
@onready var subtitulo_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SubtituloLabel
@onready var contexto_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/EstadoPanel/EstadoMargin/EstadoVBox/ContextoLabel
@onready var estado_partida_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/EstadoPanel/EstadoMargin/EstadoVBox/EstadoPartidaLabel
@onready var continuar_boton: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Botones/ContinuarBoton
@onready var reiniciar_boton: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Botones/ReiniciarBoton
@onready var menu_boton: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Botones/MenuBoton

var _tween_apertura: Tween
var _modo_carrera: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_aplicar_estetica_pixel()
	continuar_boton.pressed.connect(_on_continuar_boton_pressed)
	reiniciar_boton.pressed.connect(_on_reiniciar_boton_pressed)
	menu_boton.pressed.connect(_on_menu_boton_pressed)


func abrir(tiene_checkpoint: bool, descripcion_checkpoint: String) -> void:
	actualizar_contexto(tiene_checkpoint, descripcion_checkpoint)
	visible = true
	_animar_apertura()
	continuar_boton.grab_focus()


func cerrar() -> void:
	if _tween_apertura != null and _tween_apertura.is_valid():
		_tween_apertura.kill()

	visible = false


func actualizar_contexto(tiene_checkpoint: bool, descripcion_checkpoint: String) -> void:
	if _modo_carrera:
		contexto_label.text = "Persecucion activa. El muro avanza sin detenerse."
		estado_partida_label.text = "Si caes o el muro te toca, vuelves al inicio del mundo 2."
		reiniciar_boton.text = "Reiniciar carrera"
		return

	reiniciar_boton.text = "Reiniciar desde checkpoint"
	if tiene_checkpoint:
		contexto_label.text = "Checkpoint activo: %s" % descripcion_checkpoint
		estado_partida_label.text = "Progreso protegido. Puedes reiniciar sin volver al comienzo."
		return

	contexto_label.text = "Checkpoint activo: no. Si caes, volveras al inicio actual."
	estado_partida_label.text = "Avance sin fijar. Busca el siguiente punto verde para asegurar la ruta."


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("pausa"):
		emit_signal("continuar_solicitado")
		get_viewport().set_input_as_handled()


func _on_continuar_boton_pressed() -> void:
	emit_signal("continuar_solicitado")


func _on_reiniciar_boton_pressed() -> void:
	emit_signal("reiniciar_solicitado")


func _on_menu_boton_pressed() -> void:
	emit_signal("volver_menu_solicitado")


func _animar_apertura() -> void:
	if panel_container == null:
		return

	if _tween_apertura != null and _tween_apertura.is_valid():
		_tween_apertura.kill()

	panel_container.scale = Vector2(0.96, 0.96)
	panel_container.modulate.a = 0.0
	_tween_apertura = create_tween()
	_tween_apertura.set_parallel(true)
	_tween_apertura.set_ignore_time_scale(true)
	_tween_apertura.set_trans(Tween.TRANS_BACK)
	_tween_apertura.set_ease(Tween.EASE_OUT)
	_tween_apertura.tween_property(panel_container, "scale", Vector2.ONE, 0.18)
	_tween_apertura.tween_property(panel_container, "modulate:a", 1.0, 0.12)


func establecer_modo_carrera(activo: bool) -> void:
	_modo_carrera = activo
	if _modo_carrera:
		subtitulo_label.text = "PERSECUCION"
		return

	subtitulo_label.text = "PAUSA"


func _aplicar_estetica_pixel() -> void:
	for label in [titulo_label, subtitulo_label, contexto_label, estado_partida_label]:
		label.add_theme_font_override("font", FUENTE_PIXEL)

	titulo_label.add_theme_font_size_override("font_size", 19)
	subtitulo_label.add_theme_font_size_override("font_size", 12)
	contexto_label.add_theme_font_size_override("font_size", 11)
	estado_partida_label.add_theme_font_size_override("font_size", 11)

	for boton in [continuar_boton, reiniciar_boton, menu_boton]:
		boton.add_theme_font_override("font", FUENTE_PIXEL)
		boton.add_theme_font_size_override("font_size", 11)
