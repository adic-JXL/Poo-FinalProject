extends "res://Scripts/estado_jugador_base.gd"
class_name EstadoJugadorSprint


func obtener_nombre() -> StringName:
	return &"sprint"


func entrar() -> void:
	jugador.establecer_sprint_activo(true)


func salir() -> void:
	jugador.establecer_sprint_activo(false)


func procesar(delta: float, direccion: float, quiere_sprint: bool, quiere_saltar: bool) -> void:
	if not jugador.puede_activar_sprint(direccion) or not quiere_sprint:
		jugador.cambiar_a_estado(&"normal")
		jugador.procesar_estado_actual(delta, direccion, false, quiere_saltar)
		return

	if not jugador.consumir_estamina_sprint(delta):
		jugador.cambiar_a_estado(&"normal")
		jugador.procesar_estado_actual(delta, direccion, false, quiere_saltar)
		return

	jugador.establecer_sprint_activo(true)
	jugador.mover_con_multiplicador(direccion, delta, jugador.multiplicador_sprint)

	if quiere_saltar:
		jugador.saltar()
