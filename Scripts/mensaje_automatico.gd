extends Area2D
class_name MensajeAutomatico

@export_multiline var mensaje: String = "Mensaje de historia."
@export var mostrar_una_sola_vez: bool = true
@export var ocultar_al_salir: bool = false
@export var mensaje_al_salir: String = ""
@export var hud_path: NodePath

var _ya_mostrado: bool = false
var _hud: Node = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_hud = _obtener_hud()


func mostrar() -> void:
	if mostrar_una_sola_vez and _ya_mostrado:
		return

	_ya_mostrado = true
	_mostrar_mensaje(mensaje)


func reiniciar_mensaje() -> void:
	_ya_mostrado = false


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("jugador"):
		return

	mostrar()


func _on_body_exited(body: Node) -> void:
	if not ocultar_al_salir or not body.is_in_group("jugador"):
		return

	_mostrar_mensaje(mensaje_al_salir)


func _mostrar_mensaje(texto: String) -> void:
	if texto.is_empty():
		return

	if _hud == null or not is_instance_valid(_hud):
		_hud = _obtener_hud()

	if _hud != null and _hud.has_method("mostrar_mensaje"):
		_hud.mostrar_mensaje(texto)


func _obtener_hud() -> Node:
	if not hud_path.is_empty():
		var hud_configurado := get_node_or_null(hud_path)
		if hud_configurado != null:
			return hud_configurado

	var escena_actual := get_tree().current_scene
	if escena_actual != null:
		var hud_en_escena := escena_actual.get_node_or_null("Canvas/HUD")
		if hud_en_escena != null:
			return hud_en_escena

	return get_tree().get_first_node_in_group("hud")
