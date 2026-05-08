extends CanvasLayer
class_name HUD

@onready var mensaje_label: Label = $Control/MarginContainer/PanelContainer/VBoxContainer/MensajeLabel
@onready var vida_label: Label = $Control/MarginContainer/PanelContainer/VBoxContainer/VidaLabel
@onready var estado_label: Label = $Control/MarginContainer/PanelContainer/VBoxContainer/EstadoLabel
@onready var estamina_barra: ProgressBar = $Control/MarginContainer/PanelContainer/VBoxContainer/EstaminaBarra
@onready var estamina_label: Label = $Control/MarginContainer/PanelContainer/VBoxContainer/EstaminaLabel
@onready var sprint_label: Label = $Control/MarginContainer/PanelContainer/VBoxContainer/SprintLabel


func configurar_jugador(jugador) -> void:
	jugador.vida_cambiada.connect(actualizar_vida)
	jugador.estado_cambiado.connect(actualizar_estado)
	jugador.estamina_cambiada.connect(actualizar_estamina)
	jugador.sprint_cambiado.connect(actualizar_sprint)

	actualizar_vida(jugador.vida)
	actualizar_estado(jugador.estado_actual)
	actualizar_estamina(jugador.obtener_estamina_actual(), jugador.obtener_estamina_maxima())
	actualizar_sprint(jugador.esta_haciendo_sprint())


func mostrar_mensaje(texto: String) -> void:
	mensaje_label.text = texto


func actualizar_vida(vida_actual: int) -> void:
	vida_label.text = "Vida: %d" % vida_actual


func actualizar_estado(estado: StringName) -> void:
	estado_label.text = "Estado: %s" % estado


func actualizar_estamina(actual: float, maxima: float) -> void:
	estamina_barra.max_value = maxima
	estamina_barra.value = actual
	estamina_label.text = "Estamina: %.0f / %.0f" % [actual, maxima]


func actualizar_sprint(activo: bool) -> void:
	sprint_label.text = "Sprint: %s" % ("activo" if activo else "inactivo")
