extends Control
class_name MenuPausa

signal continuar_solicitado
signal reiniciar_solicitado
signal volver_menu_solicitado

@onready var contexto_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContextoLabel
@onready var continuar_boton: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Botones/ContinuarBoton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	continuar_boton.pressed.connect(_on_continuar_boton_pressed)
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Botones/ReiniciarBoton.pressed.connect(_on_reiniciar_boton_pressed)
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Botones/MenuBoton.pressed.connect(_on_menu_boton_pressed)


func abrir(tiene_checkpoint: bool, descripcion_checkpoint: String) -> void:
	actualizar_contexto(tiene_checkpoint, descripcion_checkpoint)
	visible = true
	continuar_boton.grab_focus()


func cerrar() -> void:
	visible = false


func actualizar_contexto(tiene_checkpoint: bool, descripcion_checkpoint: String) -> void:
	if tiene_checkpoint:
		contexto_label.text = "Checkpoint activo: %s" % descripcion_checkpoint
		return

	contexto_label.text = "Checkpoint activo: no. Si caes, volveras al inicio actual."


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
