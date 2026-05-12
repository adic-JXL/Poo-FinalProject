extends "res://Scripts/estado_jugador_base.gd"
class_name EstadoJugadorAturdido


func obtener_nombre() -> StringName:
	return &"aturdido"


func entrar() -> void:
	jugador.establecer_sprint_activo(false)


func procesar(delta: float, _direccion: float, _quiere_sprint: bool, _quiere_saltar: bool) -> void:
	jugador.procesar_retroceso(delta)
