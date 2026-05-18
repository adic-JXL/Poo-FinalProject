extends Node2D

@export var altura_caida_respawn: float = 760.0
@export var offset_camara: Vector2 = Vector2(0, -44)

@onready var jugador = $Player/Jugador
@onready var camara: Camera2D = $Player/Camara
@onready var hud = $Canvas/HUD
@onready var punto_respawn: Marker2D = $SpawnJugador


func _ready() -> void:
	if hud != null and hud.has_method("configurar_jugador"):
		hud.configurar_jugador(jugador)
		hud.mostrar_mensaje("Has cruzado al mundo 2. Esta base ya quedo separada para seguir construyendo.")

	if camara != null:
		camara.make_current()
		camara.enabled = true


func _process(_delta: float) -> void:
	if jugador == null:
		return

	if camara != null:
		camara.global_position = jugador.global_position + offset_camara

	if jugador.global_position.y > altura_caida_respawn and punto_respawn != null and jugador.has_method("restaurar_para_respawn"):
		jugador.restaurar_para_respawn(punto_respawn.global_position)
		if hud != null and hud.has_method("mostrar_mensaje"):
			hud.mostrar_mensaje("Respawn en el inicio del mundo 2.")
