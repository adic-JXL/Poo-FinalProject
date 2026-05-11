extends "res://Scripts/interactivo_base.gd"
class_name PuertaBloqueada
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# En el inspector, arrastra la otra puerta a esta variable
@export var puerta_destino: Area2D

@export var color_bloqueada: Color = Color(1, 1, 1, 1)
@export var color_abierta: Color = Color(0.67, 1, 0.78, 1)

var _abierta: bool = false

@onready var sprite: Sprite2D = $Puerta






func _ready() -> void:
	super()
	


func puede_interactuar() -> bool:
	return not _abierta

func _on_body_entered(body: Node2D) -> void:
	
	if body.name == "Jugador": 
		if _abierta:
			call_deferred("teletransportar", body)

func teletransportar(jugador: Node2D):
	if puerta_destino:
		# Obtenemos la posición del Marker2D de la otra puerta
		var punto_salida = puerta_destino.get_node("Marker2D").global_position
		jugador.global_position = punto_salida

func abrir() -> void:
	if _abierta == true:
		return
	_abierta = true
	
	
	
	_actualizar_visual()
	


func esta_abierta() -> bool:
	return _abierta


func _actualizar_visual() -> void:
	animation_player.play("Abrir_Puerta")
