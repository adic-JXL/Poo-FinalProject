extends "res://Scripts/estado_jugador_base.gd"
class_name EstadoJugadorNormal


func obtener_nombre() -> StringName:
	return &"normal"


func entrar() -> void:
	jugador.establecer_sprint_activo(false)


func procesar(delta: float, direccion: float, quiere_sprint: bool, quiere_saltar: bool) -> void:
	if quiere_sprint and jugador.puede_activar_sprint(direccion):
		jugador.cambiar_a_estado(&"sprint")
		jugador.procesar_estado_actual(delta, direccion, quiere_sprint, quiere_saltar)
		return

	jugador.regenerar_estamina(delta)
	jugador.establecer_sprint_activo(false)
	jugador.mover_con_multiplicador(direccion, delta, 1.0)

	if quiere_saltar:
		jugador.saltar()
