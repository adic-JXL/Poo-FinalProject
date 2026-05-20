extends "res://Scripts/puzzle_base.gd"
class_name PuzzleMatematicas

@export var cantidad_preguntas: int = 4
@export var minimo_sumando: int = 12
@export var maximo_sumando: int = 48

var _rng := RandomNumberGenerator.new()
var _pregunta_actual: int = 0
var _respuesta_correcta: int = 0
var _aceptando_entrada: bool = false
var _botones: Array[Button] = []
var _respuestas_por_boton: Dictionary = {}

@onready var overlay: ColorRect = $Control/Overlay
@onready var panel_container: PanelContainer = $Control/CenterContainer/PanelContainer
@onready var titulo_label: Label = $Control/CenterContainer/PanelContainer/VBoxContainer/TituloLabel
@onready var instruccion_label: Label = $Control/CenterContainer/PanelContainer/VBoxContainer/InstruccionLabel
@onready var pregunta_label: Label = $Control/CenterContainer/PanelContainer/VBoxContainer/SecuenciaLabel
@onready var feedback_label: Label = $Control/CenterContainer/PanelContainer/VBoxContainer/FeedbackLabel
@onready var boton_a: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/GridContainer/BotonSol
@onready var boton_b: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/GridContainer/BotonLuna
@onready var boton_c: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/GridContainer/BotonOjo
@onready var boton_d: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/GridContainer/BotonEco
@onready var cancelar_button: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/BotonesAccion/BotonCancelar


func _ready() -> void:
	super()
	_rng.randomize()

	_botones = [boton_a, boton_b, boton_c, boton_d]
	for indice in range(_botones.size()):
		_botones[indice].pressed.connect(_on_boton_respuesta_presionado.bind(indice))

	cancelar_button.pressed.connect(_on_boton_cancelar_pressed)
	_establecer_botones_habilitados(false)
	titulo_label.text = "Quiz del Salon"
	aplicar_tema_puzzle(
		overlay,
		panel_container,
		titulo_label,
		[instruccion_label, pregunta_label, feedback_label],
		_botones,
		cancelar_button,
		Color(0.82, 0.75, 0.36, 1.0)
	)
	pregunta_label.add_theme_color_override("font_color", Color(0.72, 0.92, 0.78, 1.0))


func iniciar_puzzle() -> void:
	super()
	_pregunta_actual = 0
	_preparar_pregunta()


func cerrar() -> void:
	_aceptando_entrada = false
	_establecer_botones_habilitados(false)
	super()


func resolver_automaticamente_para_prueba() -> void:
	if not esta_visible():
		iniciar_puzzle()

	while _aceptando_entrada:
		_procesar_respuesta(_respuesta_correcta)


func _preparar_pregunta(mensaje: String = "", avanzar: bool = true) -> void:
	_aceptando_entrada = true
	if avanzar:
		_pregunta_actual += 1

	var a := _rng.randi_range(minimo_sumando, maximo_sumando)
	var b := _rng.randi_range(minimo_sumando, maximo_sumando)
	_respuesta_correcta = a + b

	instruccion_label.text = "Resuelve la suma para calmar el cubo del salon."
	pregunta_label.text = "%d + %d = ?" % [a, b]
	feedback_label.text = mensaje if not mensaje.is_empty() else "Pregunta %d / %d" % [_pregunta_actual, max(cantidad_preguntas, 1)]
	_colocar_opciones()
	_establecer_botones_habilitados(true)
	if _botones.size() > 0:
		_botones[0].grab_focus()


func _colocar_opciones() -> void:
	_respuestas_por_boton.clear()
	var opciones: Array[int] = [_respuesta_correcta]
	var offsets: Array[int] = [-10, -5, -3, 4, 6, 9, 12]
	_barajar_enteros(offsets)

	for offset in offsets:
		if opciones.size() >= _botones.size():
			break

		var opcion := _respuesta_correcta + offset
		if opcion > 0 and not opciones.has(opcion):
			opciones.append(opcion)

	_barajar_enteros(opciones)
	for indice in range(_botones.size()):
		_botones[indice].text = str(opciones[indice])
		_respuestas_por_boton[indice] = opciones[indice]


func _procesar_respuesta(respuesta: int) -> void:
	if not _aceptando_entrada:
		return

	if respuesta != _respuesta_correcta:
		_preparar_pregunta("Casi. El cubo cambia la suma para que lo intentes otra vez.", false)
		return

	if _pregunta_actual >= max(cantidad_preguntas, 1):
		_aceptando_entrada = false
		_establecer_botones_habilitados(false)
		feedback_label.text = "Las cuentas encajan. El salon vuelve a abrirse."
		_emitir_completado()
		return

	_preparar_pregunta("Bien. Sigue con la siguiente suma.")


func _establecer_botones_habilitados(activos: bool) -> void:
	for boton in _botones:
		boton.disabled = not activos


func _barajar_enteros(valores: Array[int]) -> void:
	for indice in range(valores.size() - 1, 0, -1):
		var indice_intercambio := _rng.randi_range(0, indice)
		var temporal := valores[indice]
		valores[indice] = valores[indice_intercambio]
		valores[indice_intercambio] = temporal


func _on_boton_respuesta_presionado(indice: int) -> void:
	_procesar_respuesta(int(_respuestas_por_boton.get(indice, -1)))


func _on_boton_cancelar_pressed() -> void:
	cerrar()
	_emitir_cancelado()
