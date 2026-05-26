extends RefCounted
class_name EstadoJugadorBase

var jugador


func _init(jugador_referencia) -> void:
	jugador = jugador_referencia


func obtener_nombre() -> StringName:
	return &"base"


func entrar() -> void:
	pass


func salir() -> void:
	pass


func procesar(delta: float, direccion: float, quiere_sprint: bool, quiere_saltar: bool) -> void:
	jugador.mover_con_multiplicador(direccion, delta, 1.0)

	if quiere_saltar:
		jugador.saltar()
