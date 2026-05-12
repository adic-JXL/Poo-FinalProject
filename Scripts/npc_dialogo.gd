extends "res://Scripts/interactivo_base.gd"
class_name NPCDialogo

signal dialogo_iniciado(nombre: String)
signal dialogo_finalizado(nombre: String)

@export var nombre_npc: String = "Guia"
@export_multiline var descripcion: String = "Un personaje que puede hablar con el jugador."
@export var lineas_dialogo: PackedStringArray = [
	"Hola. Este lugar cambia cuando aprendes a mirar.",
	"Busca la llave, resuelve su secuencia y vuelve a la puerta.",
	"Si ves algo imposible, tal vez las gafas tengan la respuesta."
]
@export_group("Retrato de dialogo")
@export var retrato_escala: float = 2.4
@export var retrato_posicion: Vector2 = Vector2(90, 118)

@onready var dialogo_ui: DialogoUI = $DialogoUI
@onready var nombre_label: Label = $NombreLabel
@onready var visual: Node2D = $Visual

var _jugador_dialogando: Node = null


func _ready() -> void:
	super()
	add_to_group("npc")
	mensaje_interaccion = "Presiona E para hablar con %s." % nombre_npc
	nombre_label.text = nombre_npc
	dialogo_ui.dialogo_cerrado.connect(_on_dialogo_cerrado)


func interactuar() -> void:
	if not esta_en_rango() or dialogo_ui.esta_activo():
		return

	_jugador_dialogando = get_tree().get_first_node_in_group("jugador")
	if _jugador_dialogando != null and _jugador_dialogando.has_method("establecer_control_habilitado"):
		_jugador_dialogando.establecer_control_habilitado(false)

	dialogo_ui.iniciar(nombre_npc, lineas_dialogo, visual, retrato_escala, retrato_posicion)
	emit_signal("dialogo_iniciado", nombre_npc)


func esta_dialogando() -> bool:
	return dialogo_ui.esta_activo()


func _on_dialogo_cerrado() -> void:
	if _jugador_dialogando != null and _jugador_dialogando.has_method("establecer_control_habilitado"):
		_jugador_dialogando.establecer_control_habilitado(true)

	_jugador_dialogando = null
	emit_signal("dialogo_finalizado", nombre_npc)
