extends "res://Scripts/puzzle_base.gd"
class_name PuzzleSecuencia

const SIMBOLOS := ["SOL", "LUNA", "OJO", "ECO"]

@export var longitud_secuencia: int = 4
@export var tiempo_memoria: float = 2.2

var _rng := RandomNumberGenerator.new()
var _secuencia_actual: Array[int] = []
var _respuesta_actual: Array[int] = []
var _aceptando_entrada: bool = false
var _botones: Array[Button] = []

@onready var instruccion_label: Label = $Control/CenterContainer/PanelContainer/VBoxContainer/InstruccionLabel
@onready var secuencia_label: Label = $Control/CenterContainer/PanelContainer/VBoxContainer/SecuenciaLabel
@onready var feedback_label: Label = $Control/CenterContainer/PanelContainer/VBoxContainer/FeedbackLabel
@onready var boton_sol: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/GridContainer/BotonSol
@onready var boton_luna: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/GridContainer/BotonLuna
@onready var boton_ojo: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/GridContainer/BotonOjo
@onready var boton_eco: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/GridContainer/BotonEco
@onready var cancelar_button: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/BotonesAccion/BotonCancelar
@onready var timer_memoria: Timer = $TimerMemoria


func _ready() -> void:
	super()
	_rng.randomize()

	_botones = [boton_sol, boton_luna, boton_ojo, boton_eco]
	for indice in range(_botones.size()):
		_botones[indice].text = SIMBOLOS[indice]
		_botones[indice].pressed.connect(_on_boton_simbolo_presionado.bind(indice))

	cancelar_button.pressed.connect(_on_boton_cancelar_pressed)
	timer_memoria.timeout.connect(_on_timer_memoria_timeout)
	_establecer_botones_habilitados(false)


func iniciar_puzzle() -> void:
	super()
	_preparar_nueva_ronda()


func cerrar() -> void:
	timer_memoria.stop()
	_aceptando_entrada = false
	_establecer_botones_habilitados(false)
	super()


func obtener_secuencia_actual() -> Array[int]:
	return _secuencia_actual.duplicate()


func resolver_automaticamente_para_prueba() -> void:
	if not esta_visible():
		iniciar_puzzle()

	timer_memoria.stop()
	_habilitar_entrada()

	for simbolo in _secuencia_actual:
		_procesar_simbolo(simbolo)


func _preparar_nueva_ronda(mensaje: String = "Memoriza la secuencia.") -> void:
	_secuencia_actual.clear()
	_respuesta_actual.clear()
	_aceptando_entrada = false

	for _indice in range(max(longitud_secuencia, 1)):
		_secuencia_actual.append(_rng.randi_range(0, SIMBOLOS.size() - 1))

	instruccion_label.text = "Memoriza la secuencia y espera a que se oculte."
	secuencia_label.text = "Secuencia: %s" % _texto_secuencia(_secuencia_actual)
	feedback_label.text = mensaje
	_establecer_botones_habilitados(false)
	timer_memoria.start(tiempo_memoria)


func _habilitar_entrada() -> void:
	_aceptando_entrada = true
	instruccion_label.text = "Repite la secuencia con los botones."
	secuencia_label.text = _texto_progreso()
	feedback_label.text = "Ingresa el primer simbolo."
	_establecer_botones_habilitados(true)


func _procesar_simbolo(indice: int) -> void:
	if not _aceptando_entrada:
		return

	_respuesta_actual.append(indice)
	var posicion_actual := _respuesta_actual.size() - 1

	if _secuencia_actual[posicion_actual] != indice:
		_preparar_nueva_ronda("Orden incorrecto. Memoriza una nueva secuencia.")
		return

	if _respuesta_actual.size() == _secuencia_actual.size():
		_aceptando_entrada = false
		_establecer_botones_habilitados(false)
		feedback_label.text = "Puzzle resuelto. La llave ya es tuya."
		_emitir_completado()
		return

	secuencia_label.text = _texto_progreso()
	feedback_label.text = "Bien. Sigue con el paso %d." % (_respuesta_actual.size() + 1)


func _texto_secuencia(secuencia: Array[int]) -> String:
	var nombres: PackedStringArray = []

	for indice in secuencia:
		nombres.append(SIMBOLOS[indice])

	return " - ".join(nombres)


func _texto_progreso() -> String:
	return "Progreso: %d / %d" % [_respuesta_actual.size(), _secuencia_actual.size()]


func _establecer_botones_habilitados(activos: bool) -> void:
	for boton in _botones:
		boton.disabled = not activos


func _on_boton_simbolo_presionado(indice: int) -> void:
	_procesar_simbolo(indice)


func _on_boton_cancelar_pressed() -> void:
	cerrar()
	_emitir_cancelado()


func _on_timer_memoria_timeout() -> void:
	_habilitar_entrada()
