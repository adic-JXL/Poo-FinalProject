extends "res://Scripts/interactivo_base.gd"
class_name PuertaTeletransporte

signal teletransporte_realizado(jugador: Node2D, destino: Node2D)

@export_node_path("Area2D") var puerta_destino: NodePath
@export var transporte_habilitado: bool = false
@export var teletransporta_al_tocar: bool = true
@export var permite_interaccion: bool = false
@export var color_inactiva: Color = Color(0.76, 0.82, 0.88, 1)
@export var color_activa: Color = Color(0.67, 1, 0.78, 1)

var _puerta_destino_ref: Node = null

@onready var sprite: Sprite2D = $Puerta
@onready var marker_salida: Marker2D = $Marker2D


func _ready() -> void:
	super()
	body_entered.connect(_on_body_entered_teletransporte)
	_actualizar_visual()


func obtener_puerta_destino() -> Node:
	if _puerta_destino_ref != null and is_instance_valid(_puerta_destino_ref):
		return _puerta_destino_ref

	if puerta_destino.is_empty():
		return null

	return get_node_or_null(puerta_destino)


func configurar_destino(destino: Node) -> void:
	_puerta_destino_ref = destino
	if destino != null and is_inside_tree():
		puerta_destino = get_path_to(destino)


func obtener_punto_salida() -> Vector2:
	return marker_salida.global_position


func establecer_transporte_habilitado(activo: bool) -> void:
	transporte_habilitado = activo
	_actualizar_visual()


func puede_interactuar() -> bool:
	return permite_interaccion and transporte_habilitado


func puede_teletransportar() -> bool:
	var destino := obtener_puerta_destino()
	return transporte_habilitado and teletransporta_al_tocar and destino != null and destino.has_method("obtener_punto_salida")


func _on_body_entered_teletransporte(body: Node) -> void:
	if not body.is_in_group("jugador"):
		return

	if body.has_meta("puerta_ignorada"):
		var puerta_ignorada := int(body.get_meta("puerta_ignorada"))
		if puerta_ignorada == get_instance_id():
			body.remove_meta("puerta_ignorada")
			return

	if not puede_teletransportar():
		return

	call_deferred("_teletransportar_jugador", body)


func _teletransportar_jugador(body: Node) -> void:
	var jugador := body as Node2D
	var destino := obtener_puerta_destino()
	if jugador == null or destino == null:
		return

	jugador.set_meta("puerta_ignorada", destino.get_instance_id())
	jugador.global_position = destino.obtener_punto_salida()
	if jugador is CharacterBody2D:
		(jugador as CharacterBody2D).velocity = Vector2.ZERO

	emit_signal("teletransporte_realizado", jugador, destino)


func teletransportar_jugador(jugador: Node2D) -> void:
	if not puede_teletransportar():
		return

	_teletransportar_jugador(jugador)


func _actualizar_visual() -> void:
	if sprite == null:
		return

	sprite.modulate = color_activa if transporte_habilitado else color_inactiva
