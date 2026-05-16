extends Control
class_name MenuPausa

signal continuar_solicitado
signal reiniciar_solicitado
signal volver_menu_solicitado

@onready var panel_container: PanelContainer = $CenterContainer/PanelContainer
@onready var contexto_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/EstadoPanel/EstadoMargin/EstadoVBox/ContextoLabel
@onready var estado_partida_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/EstadoPanel/EstadoMargin/EstadoVBox/EstadoPartidaLabel
@onready var continuar_boton: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Botones/ContinuarBoton

var _tween_apertura: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	continuar_boton.pressed.connect(_on_continuar_boton_pressed)
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Botones/ReiniciarBoton.pressed.connect(_on_reiniciar_boton_pressed)
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Botones/MenuBoton.pressed.connect(_on_menu_boton_pressed)


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
