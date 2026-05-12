extends CanvasLayer
class_name HUD

var _gafas_duracion_max: float = 10.0
var _gafas_cooldown_max: float = 10.0

@onready var mensaje_label: Label = $Control/MensajePanel/MarginContainer/VBoxContainer/MensajeLabel
@onready var estado_label: Label = $Control/MensajePanel/MarginContainer/VBoxContainer/EstadoLabel
@onready var llave_label: Label = $Control/MensajePanel/MarginContainer/VBoxContainer/LlaveLabel
@onready var checkpoint_label: Label = $Control/MensajePanel/MarginContainer/VBoxContainer/CheckpointLabel
@onready var estamina_barra: ProgressBar = $Control/StaminaPanel/MarginContainer/VBoxContainer/EstaminaBarra
@onready var estamina_label: Label = $Control/StaminaPanel/MarginContainer/VBoxContainer/EstaminaLabel
@onready var sprint_label: Label = $Control/StaminaPanel/MarginContainer/VBoxContainer/SprintLabel
@onready var vida_label: Label = $Control/VidaPanel/MarginContainer/VBoxContainer/VidaLabel
@onready var gafas_estado_label: Label = $Control/GafasPanel/MarginContainer/VBoxContainer/GafasEstadoLabel
@onready var gafas_barra: ProgressBar = $Control/GafasPanel/MarginContainer/VBoxContainer/GafasBarra
@onready var gafas_cooldown_label: Label = $Control/GafasPanel/MarginContainer/VBoxContainer/GafasCooldownLabel


func configurar_jugador(jugador) -> void:
	_gafas_duracion_max = jugador.gafas_duracion
	_gafas_cooldown_max = jugador.gafas_cooldown_maximo

	jugador.vida_cambiada.connect(actualizar_vida)
	jugador.estado_cambiado.connect(actualizar_estado)
	jugador.estamina_cambiada.connect(actualizar_estamina)
	jugador.sprint_cambiado.connect(actualizar_sprint)
	jugador.gafas_actualizadas.connect(actualizar_gafas)

	actualizar_vida(jugador.vida)
	actualizar_estado(jugador.estado_actual)
	actualizar_estamina(jugador.obtener_estamina_actual(), jugador.obtener_estamina_maxima())
	actualizar_sprint(jugador.esta_haciendo_sprint())
	actualizar_gafas(jugador.gafas_activas(), jugador.obtener_duracion_gafas_restante(), jugador.obtener_cooldown_gafas_restante(), jugador.obtener_cooldown_actual_gafas(), jugador.obtener_siguiente_cooldown_gafas())


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


func actualizar_llave(tiene_llave: bool) -> void:
	llave_label.text = "Llave: %s" % ("obtenida" if tiene_llave else "pendiente")


func actualizar_checkpoint(activo: bool) -> void:
	checkpoint_label.text = "Checkpoint: %s" % ("activo" if activo else "pendiente")


func actualizar_gafas(activa: bool, duracion_restante: float, cooldown_restante: float, cooldown_actual: float, siguiente_cooldown: float) -> void:
	if activa:
		gafas_estado_label.text = "Gafas: activas"
		gafas_barra.max_value = _gafas_duracion_max
		gafas_barra.value = duracion_restante
		gafas_cooldown_label.text = "Vision clara: %.1fs" % duracion_restante
		return

	if cooldown_restante > 0.0:
		gafas_estado_label.text = "Gafas: enfriando"
		gafas_barra.max_value = max(cooldown_actual, 0.1)
		gafas_barra.value = cooldown_restante
		gafas_cooldown_label.text = "Cooldown: %.1fs" % cooldown_restante
		return

	gafas_estado_label.text = "Gafas: listas"
	gafas_barra.max_value = _gafas_cooldown_max
	gafas_barra.value = _gafas_cooldown_max
	gafas_cooldown_label.text = "Q para activar (sig.: %.1fs)" % siguiente_cooldown
