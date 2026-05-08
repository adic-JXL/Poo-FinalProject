extends "res://Scripts/estado_jugador_base.gd"
class_name EstadoJugadorBloqueado


func obtener_nombre() -> StringName:
	return &"bloqueado"


func entrar() -> void:
	jugador.establecer_sprint_activo(false)
	jugador.velocity = Vector2.ZERO


func procesar(_delta: float, _direccion: float, _quiere_sprint: bool, _quiere_saltar: bool) -> void:
	jugador.velocity = Vector2.ZERO
