extends "res://Scripts/puzzle_base.gd"
class_name PuzzleGafas

const SIMBOLOS := ["[]", "/\\", "<>", "OO"]

@export var longitud_patron: int = 5
@export var tiempo_revelacion: float = 2.8

var _rng := RandomNumberGenerator.new()
var _patron_actual: Array[int] = []
var _respuesta_actual: Array[int] = []
var _aceptando_entrada: bool = false
var _botones: Array[Button] = []

@onready var instruccion_label: Label = $Control/CenterContainer/PanelContainer/VBoxContainer/InstruccionLabel
@onready var patron_label: Label = $Control/CenterContainer/PanelContainer/VBoxContainer/PatronLabel
@onready var feedback_label: Label = $Control/CenterContainer/PanelContainer/VBoxContainer/FeedbackLabel
@onready var boton_a: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/GridContainer/BotonA
@onready var boton_b: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/GridContainer/BotonB
@onready var boton_c: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/GridContainer/BotonC
@onready var boton_d: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/GridContainer/BotonD
@onready var cancelar_button: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/BotonesAccion/BotonCancelar
@onready var timer_revelacion: Timer = $TimerRevelacion


func _ready() -> void:
	super()
	_rng.randomize()

	_botones = [boton_a, boton_b, boton_c, boton_d]
	for indice in range(_botones.size()):
		_botones[indice].text = SIMBOLOS[indice]
		_botones[indice].pressed.connect(_on_boton_simbolo_presionado.bind(indice))

	cancelar_button.pressed.connect(_on_boton_cancelar_pressed)
	timer_revelacion.timeout.connect(_on_timer_revelacion_timeout)
	_establecer_botones_habilitados(false)


func iniciar_puzzle() -> void:
	super()
	_preparar_nuevo_patron()


func cerrar() -> void:
	timer_revelacion.stop()
	_aceptando_entrada = false
	_establecer_botones_habilitados(false)
	super()


func resolver_automaticamente_para_prueba() -> void:
	if not esta_visible():
		iniciar_puzzle()

	timer_revelacion.stop()
	_habilitar_entrada()

	for simbolo in _patron_actual:
		_procesar_simbolo(simbolo)


func _preparar_nuevo_patron(mensaje: String = "Las gafas revelan los glifos por unos instantes.") -> void:
	_patron_actual.clear()
	_respuesta_actual.clear()
	_aceptando_entrada = false

	for _indice in range(max(longitud_patron, 1)):
		_patron_actual.append(_rng.randi_range(0, SIMBOLOS.size() - 1))

	instruccion_label.text = "Observa los glifos mientras la vision esta clara."
	patron_label.text = "Glifos: %s" % _texto_patron(_patron_actual)
	feedback_label.text = mensaje
	_establecer_botones_habilitados(false)
	timer_revelacion.start(tiempo_revelacion)


func _habilitar_entrada() -> void:
	_aceptando_entrada = true
	instruccion_label.text = "La vision se disipa. Repite el patron en orden."
	patron_label.text = _texto_progreso()
	feedback_label.text = "Marca el primer glifo."
	_establecer_botones_habilitados(true)


func _procesar_simbolo(indice: int) -> void:
	if not _aceptando_entrada:
		return

	_respuesta_actual.append(indice)
	var posicion_actual := _respuesta_actual.size() - 1

	if _patron_actual[posicion_actual] != indice:
		_preparar_nuevo_patron("El patron se rompio. Las gafas revelan una nueva combinacion.")
		return

	if _respuesta_actual.size() == _patron_actual.size():
		_aceptando_entrada = false
		_establecer_botones_habilitados(false)
		feedback_label.text = "Los glifos responden. El altar queda estabilizado."
		_emitir_completado()
		return

	patron_label.text = _texto_progreso()
	feedback_label.text = "Correcto. Continua con el siguiente glifo."


func _texto_patron(patron: Array[int]) -> String:
	var piezas: PackedStringArray = []

	for indice in patron:
		piezas.append(SIMBOLOS[indice])

	return " ".join(piezas)


func _texto_progreso() -> String:
	return "Progreso: %d / %d" % [_respuesta_actual.size(), _patron_actual.size()]


func _establecer_botones_habilitados(activos: bool) -> void:
	for boton in _botones:
		boton.disabled = not activos


func _on_boton_simbolo_presionado(indice: int) -> void:
	_procesar_simbolo(indice)


func _on_boton_cancelar_pressed() -> void:
	cerrar()
	_emitir_cancelado()


func _on_timer_revelacion_timeout() -> void:
	_habilitar_entrada()
