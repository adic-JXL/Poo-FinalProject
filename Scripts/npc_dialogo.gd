extends "res://Scripts/interactivo_base.gd"
class_name NPCDialogo

const FUENTE_PIXEL := preload("res://Fuentes/joystix monospace.otf")

signal dialogo_iniciado(nombre: String)
signal dialogo_finalizado(nombre: String)

@export var nombre_npc: String = "Guia"
@export_multiline var descripcion: String = "Un personaje que puede hablar con el jugador."

# Dialogo automatico al entrar por primera vez
@export_group("Dialogo Automatico")
@export var activar_automaticamente: bool = false
@export var solo_una_vez: bool = true

@export var lineas_dialogo: PackedStringArray = [
	"Hola. Este lugar cambia cuando aprendes a mirar.",
	"Busca la llave, resuelve su secuencia y vuelve a la puerta.",
	"Si ves algo imposible, tal vez las gafas tengan la respuesta."
]

@export_group("Retrato de dialogo")
@export var retrato_escala: float = 2.4
@export var retrato_posicion: Vector2 = Vector2(90, 118)
@export_group("Visual")
@export var etiqueta_visible: bool = false
@export var texto_etiqueta: String = ""
@export var textura_npc: Texture2D
@export var frames_npc: Array[Texture2D] = []
@export var fps_animacion_npc: float = 5.0

@onready var dialogo_ui: DialogoUI = $DialogoUI
@onready var nombre_label: Label = $NombreLabel
@onready var visual: Node2D = $Visual
@onready var sprite_visual: Sprite2D = $Visual/Sprite2D

var _jugador_dialogando: Node = null
var _dialogo_automatico_usado := false
var _indice_frame_npc: int = 0
var _tiempo_animacion_npc: float = 0.0


func _ready() -> void:
	super()
	set_process(true)

	add_to_group("npc")

	mensaje_interaccion = "Presiona E para hablar con %s." % nombre_npc
	nombre_label.visible = false
	_preparar_visual_npc()

	dialogo_ui.dialogo_cerrado.connect(_on_dialogo_cerrado)

	# Detectar entrada del jugador
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not activar_automaticamente:
		return

	if solo_una_vez and _dialogo_automatico_usado:
		return

	if not body.is_in_group("jugador"):
		return

	_dialogo_automatico_usado = true

	# Ejecuta el dialogo automatico
	interactuar()


func _process(delta: float) -> void:
	if sprite_visual == null or frames_npc.size() <= 1:
		return

	_tiempo_animacion_npc += delta
	var intervalo := 1.0 / maxf(fps_animacion_npc, 0.1)
	if _tiempo_animacion_npc < intervalo:
		return

	_tiempo_animacion_npc = 0.0
	_indice_frame_npc = (_indice_frame_npc + 1) % frames_npc.size()
	sprite_visual.texture = frames_npc[_indice_frame_npc]


func interactuar() -> void:
	if not esta_en_rango() or dialogo_ui.esta_activo():
		return

	_jugador_dialogando = get_tree().get_first_node_in_group("jugador")

	if _jugador_dialogando != null and _jugador_dialogando.has_method("establecer_control_habilitado"):
		_jugador_dialogando.establecer_control_habilitado(false)

	dialogo_ui.iniciar(
		nombre_npc,
		lineas_dialogo,
		visual,
		retrato_escala,
		retrato_posicion
	)

	emit_signal("dialogo_iniciado", nombre_npc)


func esta_dialogando() -> bool:
	return dialogo_ui.esta_activo()


func _on_dialogo_cerrado() -> void:
	if _jugador_dialogando != null and _jugador_dialogando.has_method("establecer_control_habilitado"):
		_jugador_dialogando.establecer_control_habilitado(true)

	_jugador_dialogando = null

	emit_signal("dialogo_finalizado", nombre_npc)


func _preparar_visual_npc() -> void:
	if sprite_visual == null:
		return

	sprite_visual.texture = textura_npc if textura_npc != null else (frames_npc[0] if not frames_npc.is_empty() else null)
	sprite_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite_visual.centered = false
	sprite_visual.scale = Vector2(2.0, 2.0)
	sprite_visual.modulate = Color.WHITE
	z_as_relative = false
	z_index = 3
	sprite_visual.z_as_relative = false
	sprite_visual.z_index = 3
	visual.z_as_relative = false
	visual.z_index = 3
	if sprite_visual.texture != null:
		var tam := sprite_visual.texture.get_size() * sprite_visual.scale
		sprite_visual.position = Vector2(-tam.x * 0.5, -tam.y + 20.0)


func establecer_visual_npc(textura: Texture2D) -> void:
	textura_npc = textura
	_preparar_visual_npc()


func establecer_animacion_npc(frames: Array[Texture2D], fps: float = 5.0) -> void:
	frames_npc = frames.duplicate()
	fps_animacion_npc = fps
	_indice_frame_npc = 0
	_tiempo_animacion_npc = 0.0
	if not frames_npc.is_empty():
		textura_npc = frames_npc[0]
	_preparar_visual_npc()
