extends Node2D
class_name MainGame

const MENU_SCENE := "res://Escenas/Menu.tscn"

@export var limite_caida_y: float = 700.0

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var camara: Camera2D = $Camera2D
@onready var puerta: StaticBody2D = $Puerta
@onready var jugador: Jugador = $Jugador

var _posicion_inicial_jugador: Vector2


func _ready() -> void:
	_posicion_inicial_jugador = jugador.global_position
	_configurar_camara()


func _physics_process(_delta: float) -> void:
	if jugador.global_position.y > limite_caida_y:
		reiniciar_nivel()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reiniciar"):
		reiniciar_nivel()


func reiniciar_nivel() -> void:
	get_tree().reload_current_scene()


func volver_al_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


func obtener_jugador() -> Jugador:
	return jugador


func obtener_spawn_jugador() -> Vector2:
	return _posicion_inicial_jugador


func _configurar_camara() -> void:
	if camara.has_method("seguir_a"):
		camara.seguir_a(jugador)
