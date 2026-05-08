extends Node2D
class_name GameController

const MENU_SCENE := "res://Escenas/Menu.tscn"
const PLAYER_SCENE := preload("res://Personaje.tscn")

var jugador: CharacterBody2D

@onready var nivel: Node2D = $Nivel
@onready var punto_spawn_jugador: Marker2D = $Nivel/PuntoSpawnJugador
@onready var estado_label: Label = $CanvasLayer/MarginContainer/PanelContainer/VBoxContainer/EstadoLabel
@onready var vida_label: Label = $CanvasLayer/MarginContainer/PanelContainer/VBoxContainer/VidaLabel
@onready var estado_jugador_label: Label = $CanvasLayer/MarginContainer/PanelContainer/VBoxContainer/EstadoJugadorLabel
@onready var posicion_label: Label = $CanvasLayer/MarginContainer/PanelContainer/VBoxContainer/PosicionLabel
@onready var velocidad_label: Label = $CanvasLayer/MarginContainer/PanelContainer/VBoxContainer/VelocidadLabel
@onready var suelo_label: Label = $CanvasLayer/MarginContainer/PanelContainer/VBoxContainer/SueloLabel


func _ready() -> void:
	iniciar_juego()


func _process(_delta: float) -> void:
	_actualizar_debug_hud()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reiniciar"):
		reiniciar_nivel()


func iniciar_juego() -> void:
	_instanciar_jugador()
	estado_label.text = "Zona de pruebas activa. Muevete, salta y usa R si quieres reiniciar."


func cargar_nivel(_id: int = 0) -> void:
	estado_label.text = "Escena principal preparada para integrar Jugador, Nivel y HUD."


func reiniciar_nivel() -> void:
	get_tree().reload_current_scene()


func finalizar_nivel() -> void:
	estado_label.text = "Nivel finalizado."


func _on_volver_menu_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


func _on_reiniciar_pressed() -> void:
	reiniciar_nivel()


func _instanciar_jugador() -> void:
	if is_instance_valid(jugador):
		jugador.queue_free()

	jugador = PLAYER_SCENE.instantiate() as CharacterBody2D
	jugador.position = punto_spawn_jugador.position
	jugador.estado_cambiado.connect(_on_jugador_estado_cambiado)
	jugador.vida_cambiada.connect(_on_jugador_vida_cambiada)
	nivel.add_child(jugador)


func _on_jugador_estado_cambiado(nuevo_estado: StringName) -> void:
	estado_jugador_label.text = "Estado: %s" % nuevo_estado


func _on_jugador_vida_cambiada(vida_actual: int) -> void:
	if not is_instance_valid(jugador):
		return

	vida_label.text = "Vida: %d" % vida_actual


func _actualizar_debug_hud() -> void:
	if not is_instance_valid(jugador):
		posicion_label.text = "Posicion: --"
		velocidad_label.text = "Velocidad: --"
		suelo_label.text = "En suelo: --"
		return

	posicion_label.text = "Posicion: (%.1f, %.1f)" % [jugador.global_position.x, jugador.global_position.y]
	velocidad_label.text = "Velocidad: (%.1f, %.1f)" % [jugador.velocity.x, jugador.velocity.y]
	suelo_label.text = "En suelo: %s" % ("si" if jugador.is_on_floor() else "no")
