extends SceneTree

var _errores: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_ejecutar_verificacion")


func _ejecutar_verificacion() -> void:
	var escena_principal: Node = load("res://Escenas/MainGame.tscn").instantiate()
	root.add_child(escena_principal)
	escena_principal.limite_caida_y = 5000.0

	await process_frame
	for _i in range(45):
		await physics_frame

	var jugador = escena_principal.get_node_or_null("Player/Jugador")
	if jugador == null:
		_registrar_error("No se pudo instanciar el jugador en MainGame.")
	else:
		jugador.mover(1.0, 0.1)
		if jugador.velocity.x <= 0.0:
			_registrar_error("El movimiento horizontal no genero velocidad positiva.")

		if not jugador.is_on_floor():
			_registrar_error("El jugador no llego al suelo en la escena de prueba.")
		else:
			jugador.saltar()
			if jugador.velocity.y >= 0.0:
				_registrar_error("El salto no aplico una velocidad vertical negativa.")

		var estamina_inicial: float = jugador.obtener_estamina_actual()
		jugador.actualizar_movimiento_horizontal(1.0, true, 0.2)
		if jugador.velocity.x <= jugador.velocidad_base:
			_registrar_error("El sprint no incremento la velocidad horizontal del jugador.")

		if jugador.estado_actual != &"sprint":
			_registrar_error("El jugador no entra al estado sprint cuando acelera.")

		var estamina_despues_sprint: float = jugador.obtener_estamina_actual()
		if estamina_despues_sprint >= estamina_inicial:
			_registrar_error("El sprint no consumio estamina.")

		jugador.actualizar_movimiento_horizontal(0.0, false, 0.5)
		if jugador.estado_actual != &"normal":
			_registrar_error("El jugador no vuelve al estado normal al dejar de correr.")

		if jugador.obtener_estamina_actual() <= estamina_despues_sprint:
			_registrar_error("La estamina no se regenera cuando el jugador deja de correr.")

		var enemigo = escena_principal.get_node_or_null("Enemigos/EnemigoPatrulla")
		var perseguidor = escena_principal.get_node_or_null("Enemigos/EnemigoPerseguidor")
		var flotante_horizontal = escena_principal.get_node_or_null("Enemigos/EnemigoFlotanteHorizontal")
		var flotante_vertical = escena_principal.get_node_or_null("Enemigos/EnemigoFlotanteVertical")
		var jefe_sombras = escena_principal.get_node_or_null("Enemigos/JefeSombras")
		var llave = escena_principal.get_node_or_null("Objetos/Llave")
		var puzzle = escena_principal.get_node_or_null("Canvas/PuzzleSecuencia")
		var puerta = escena_principal.get_node_or_null("Objetos/Puerta")
		var puerta_destino = escena_principal.get_node_or_null("Objetos/Puerta2")
		var camara_1 = escena_principal.get_node_or_null("Player/Camara1")
		var camara_2 = escena_principal.get_node_or_null("Player/Camara2")
		var plataforma_gafas = escena_principal.get_node_or_null("Plataformas/PlataformaGafas1")
		var altar_gafas = escena_principal.get_node_or_null("Objetos/AltarGafas")
		var checkpoint_puzzle_gafas = escena_principal.get_node_or_null("Objetos/CheckpointPuzzleGafas")
		var checkpoint_puerta_activador = escena_principal.get_node_or_null("Objetos/CheckpointPuerta/Activador")
		var checkpoint_puzzle_gafas_activador = escena_principal.get_node_or_null("Objetos/CheckpointPuzzleGafas/Activador")
		var totem_jefe_a = escena_principal.get_node_or_null("Objetos/TotemJefeA")
		var totem_jefe_b = escena_principal.get_node_or_null("Objetos/TotemJefeB")
		var totem_jefe_c = escena_principal.get_node_or_null("Objetos/TotemJefeC")
		var meta_plataforma_gafas = escena_principal.get_node_or_null("Plataformas/MetaPlataformaGafas")
		var puzzle_gafas = escena_principal.get_node_or_null("Canvas/PuzzleGafas")
		var muro_bloqueo_arena = escena_principal.get_node_or_null("Plataformas/ArenaJefeMuroIzquierdo")
		var muro_arena_superior = escena_principal.get_node_or_null("Plataformas/ArenaJefeMuroIzquierdoSuperior")
		var muro_arena_inferior = escena_principal.get_node_or_null("Plataformas/ArenaJefeMuroIzquierdoInferior")
		var piso_arena_jefe = escena_principal.get_node_or_null("Plataformas/ArenaJefePiso")
		var enemigo_ruta_media = escena_principal.get_node_or_null("Enemigos/EnemigoFlotanteHorizontalRutaMedia")
		var enemigo_parkour = escena_principal.get_node_or_null("Enemigos/EnemigoFlotanteHorizontalParkourA")

		if muro_bloqueo_arena != null:
			_registrar_error("La pared completa de entrada a la arena del jefe sigue bloqueando el acceso.")

		if muro_arena_superior == null or muro_arena_inferior == null:
			_registrar_error("La arena del jefe no tiene la entrada abierta con muros separados.")

		if piso_arena_jefe != null and piso_arena_jefe.scale.x < 9.0:
			_registrar_error("La arena del jefe no quedo lo bastante amplia.")

		if camara_2 != null and camara_2.limit_right < 10550:
			_registrar_error("La camara secundaria no alcanza a cubrir la arena ampliada del jefe.")

		if enemigo_ruta_media == null or enemigo_parkour == null:
			_registrar_error("No se instanciaron enemigos nuevos en el trayecto hacia el jefe.")

		if enemigo == null or perseguidor == null or flotante_horizontal == null or flotante_vertical == null or jefe_sombras == null or llave == null or puzzle == null or puerta == null or puerta_destino == null or camara_1 == null or camara_2 == null or plataforma_gafas == null or altar_gafas == null or checkpoint_puzzle_gafas == null or checkpoint_puerta_activador == null or checkpoint_puzzle_gafas_activador == null or totem_jefe_a == null or totem_jefe_b == null or totem_jefe_c == null or meta_plataforma_gafas == null or puzzle_gafas == null:
			_registrar_error("Faltan nodos del flujo principal en MainGame.")
		else:
			var posicion_inicial_enemigo_x: float = enemigo.global_position.x
			var posicion_inicial_flotante_horizontal: Vector2 = flotante_horizontal.global_position
			var posicion_inicial_flotante_vertical: Vector2 = flotante_vertical.global_position
			for _m in range(15):
				await physics_frame

			if absf(enemigo.global_position.x - posicion_inicial_enemigo_x) < 2.0:
				_registrar_error("El enemigo patrulla no se esta desplazando.")

			if absf(flotante_horizontal.global_position.x - posicion_inicial_flotante_horizontal.x) < 2.0:
				_registrar_error("El enemigo flotante horizontal no se mueve sobre el eje X.")

			if absf(flotante_horizontal.global_position.y - posicion_inicial_flotante_horizontal.y) > 2.0:
				_registrar_error("El enemigo flotante horizontal esta desviandose demasiado en Y.")

			if absf(flotante_vertical.global_position.y - posicion_inicial_flotante_vertical.y) < 2.0:
				_registrar_error("El enemigo flotante vertical no se mueve sobre el eje Y.")

			if absf(flotante_vertical.global_position.x - posicion_inicial_flotante_vertical.x) > 2.0:
				_registrar_error("El enemigo flotante vertical esta desviandose demasiado en X.")

			var vida_inicial: int = jugador.vida
			jugador.global_position = enemigo.global_position + Vector2(24, 0)
			jugador.velocity = Vector2.ZERO
			var golpe_registrado := false
			for _n in range(18):
				await physics_frame

				if jugador.vida < vida_inicial:
					golpe_registrado = true
					break

			if not golpe_registrado:
				_registrar_error("El enemigo no dano al jugador al entrar en contacto.")

			if not jugador.esta_invulnerable():
				_registrar_error("El jugador no entra en invulnerabilidad despues de recibir dano.")

			if jugador.estado_actual != &"aturdido":
				_registrar_error("El jugador no entra al estado aturdido despues del golpe.")

			if Engine.time_scale >= 1.0:
				_registrar_error("El golpe no reduce temporalmente la velocidad global del juego.")

			var vida_tras_golpe: int = jugador.vida
			if jugador.recibir_danio(1):
				_registrar_error("La invulnerabilidad no bloquea un segundo golpe inmediato.")

			if jugador.vida != vida_tras_golpe:
				_registrar_error("La vida del jugador cambio durante la invulnerabilidad.")

			jugador.global_position = Vector2(120, 291)
			jugador.velocity = Vector2.ZERO
			for _o in range(95):
				await physics_frame

			if jugador.esta_invulnerable():
				_registrar_error("La invulnerabilidad del jugador no termina despues del tiempo esperado.")

			if jugador.estado_actual != &"normal":
				_registrar_error("El jugador no vuelve al estado normal despues del aturdimiento.")

			if not is_equal_approx(Engine.time_scale, 1.0):
				_registrar_error("La velocidad global del juego no vuelve a la normalidad despues del golpe.")

			var desplazamiento_perseguidor_x_inicial: float = perseguidor.global_position.x
			var direccion_mirada: float = perseguidor.obtener_direccion_mirada()
			jugador.global_position = perseguidor.global_position - Vector2(direccion_mirada * 110.0, 0.0)
			jugador.velocity = Vector2.ZERO
			for _p in range(10):
				await physics_frame

			if perseguidor.esta_persiguiendo():
				_registrar_error("El perseguidor detecta al jugador aun cuando esta fuera del campo de vision.")

			if absf(perseguidor.global_position.x - desplazamiento_perseguidor_x_inicial) > 3.0:
				_registrar_error("El perseguidor se desplazo sin detectar al jugador.")

			var posicion_perseguidor_antes_persecucion: float = perseguidor.global_position.x
			jugador.global_position = perseguidor.global_position + Vector2(direccion_mirada * 150.0, 0.0)
			jugador.velocity = Vector2.ZERO
			for _q in range(16):
				await physics_frame

			if not perseguidor.esta_persiguiendo():
				_registrar_error("El perseguidor no entra en persecucion cuando el jugador esta dentro del campo de vision.")

			if absf(perseguidor.global_position.x - posicion_perseguidor_antes_persecucion) < 2.0:
				_registrar_error("El perseguidor no avanza hacia el jugador cuando entra en persecucion.")

			if absf(perseguidor.obtener_velocidad_persecucion_actual()) > jugador.velocidad_base * 0.55:
				_registrar_error("El perseguidor supera el limite esperado de media velocidad del jugador.")

			if not jugador.activar_gafas():
				_registrar_error("El jugador no pudo activar las gafas cuando deberia.")

			await process_frame

			if not jugador.gafas_activas():
				_registrar_error("Las gafas no quedan activas tras usarlas.")

			if enemigo.obtener_multiplicador_velocidad() > 0.901:
				_registrar_error("Las gafas no reducen la velocidad base de los enemigos.")

			var zoom_con_gafas_x_antes: float = camara_1.zoom.x
			await create_timer(0.35).timeout

			if not plataforma_gafas.esta_revelada():
				_registrar_error("Las plataformas ocultas no se revelan con las gafas activas.")

			if camara_1.zoom.x >= escena_principal.zoom_base_mundo.x or camara_1.zoom.x >= zoom_con_gafas_x_antes:
				_registrar_error("Las gafas no amplian el rango de vision de la camara principal.")

			jugador.habilidad_gafas.actualizar(10.1)
			await process_frame

			if jugador.gafas_activas():
				_registrar_error("Las gafas no terminan despues de agotar su duracion.")

			if jugador.obtener_cooldown_gafas_restante() < 1.9:
				_registrar_error("Las gafas no entran en cooldown al terminar su efecto.")

			if jugador.activar_gafas():
				_registrar_error("Las gafas pueden activarse durante el cooldown.")

			if plataforma_gafas.esta_revelada():
				_registrar_error("Las plataformas de gafas no vuelven a ocultarse al terminar el efecto.")

			await create_timer(0.35).timeout

			if not is_equal_approx(camara_1.zoom.x, escena_principal.zoom_base_mundo.x):
				_registrar_error("La camara principal no vuelve a su zoom base al terminar las gafas.")

			jugador.habilidad_gafas.actualizar(2.1)
			await process_frame

			if absf(jugador.obtener_siguiente_cooldown_gafas() - 3.5) > 0.05:
				_registrar_error("El cooldown progresivo de las gafas no aumenta en 1.5 segundos tras el primer uso.")

			jugador.global_position = llave.global_position
			for _j in range(3):
				await physics_frame

			llave.interactuar()
			await process_frame

			if not escena_principal.esta_puzzle_activo():
				_registrar_error("La llave no activa el puzzle al interactuar.")

			if not enemigo.esta_congelado() or not perseguidor.esta_congelado():
				_registrar_error("Los enemigos no se congelan cuando el puzzle esta activo.")

			if jugador.tiene_control_habilitado():
				_registrar_error("El jugador no se congela mientras el puzzle esta activo.")

			if jugador.estado_actual != &"bloqueado":
				_registrar_error("El jugador no cambia al estado bloqueado cuando se abre el puzzle.")

			puzzle.resolver_automaticamente_para_prueba()
			await process_frame

			if not escena_principal.tiene_llave():
				_registrar_error("Completar el puzzle no entrega la llave.")

			if escena_principal.esta_puzzle_activo():
				_registrar_error("El puzzle no se cierra despues de completarse.")

			if enemigo.esta_congelado() or perseguidor.esta_congelado():
				_registrar_error("Los enemigos no reanudan su comportamiento al cerrar el puzzle.")

			if jugador.estado_actual != &"normal":
				_registrar_error("El jugador no regresa al estado normal al cerrar el puzzle.")

			jugador.global_position = puerta.global_position
			for _k in range(3):
				await physics_frame

			puerta.interactuar()
			await process_frame

			if not puerta.esta_abierta():
				_registrar_error("La puerta no se abre despues de obtener la llave.")

			if not puerta.puede_teletransportar():
				_registrar_error("La puerta abierta no queda lista para teletransportar al jugador.")

			var salida_esperada: Vector2 = puerta_destino.obtener_punto_salida()
			var checkpoint = escena_principal.get_node_or_null("Objetos/CheckpointPuerta")
			puerta.teletransportar_jugador(jugador)
			await create_timer(0.4).timeout

			if jugador.global_position.distance_to(salida_esperada) > 24.0:
				_registrar_error("La puerta abierta no teletransporta al jugador hacia la puerta destino.")

			if escena_principal.checkpoint_esta_activo():
				_registrar_error("El checkpoint posterior se activa sin pasar por encima del punto.")

			jugador.global_position = checkpoint_puerta_activador.global_position
			jugador.velocity = Vector2.ZERO
			for _cp in range(3):
				await physics_frame

			if not escena_principal.checkpoint_esta_activo():
				_registrar_error("Pasar por encima del checkpoint posterior no activa el respawn.")

			var respawn_checkpoint: Vector2 = escena_principal.obtener_respawn_actual()
			if checkpoint != null and respawn_checkpoint.distance_to(checkpoint.global_position) > 1.0:
				_registrar_error("El respawn actual no coincide con el checkpoint esperado despues de la puerta.")

			jugador.global_position = altar_gafas.global_position
			jugador.velocity = Vector2.ZERO
			for _r in range(3):
				await physics_frame

			altar_gafas.interactuar()
			await process_frame

			if escena_principal.esta_puzzle_activo():
				_registrar_error("El altar de gafas abre el puzzle aun sin tener las gafas activas.")

			if not jugador.activar_gafas():
				_registrar_error("No se pudieron reactivar las gafas antes del altar final.")

			await create_timer(0.35).timeout

			altar_gafas.interactuar()
			await process_frame

			if not escena_principal.esta_puzzle_activo():
				_registrar_error("El altar de gafas no abre su puzzle cuando las gafas estan activas.")

			puzzle_gafas.resolver_automaticamente_para_prueba()
			await process_frame

			if not escena_principal.puzzle_gafas_esta_superado():
				_registrar_error("Completar el puzzle de gafas no marca el reto final como superado.")

			if escena_principal.obtener_respawn_actual().distance_to(respawn_checkpoint) > 1.0:
				_registrar_error("Completar el puzzle de gafas no deberia activar el checkpoint final automaticamente.")

			jugador.global_position = checkpoint_puzzle_gafas_activador.global_position
			jugador.velocity = Vector2.ZERO
			for _cg in range(3):
				await physics_frame

			var respawn_final: Vector2 = escena_principal.obtener_respawn_actual()
			if respawn_final.distance_to(checkpoint_puzzle_gafas.global_position) > 1.0:
				_registrar_error("Pasar por encima del checkpoint final no actualiza el respawn.")

			jefe_sombras.establecer_congelado(true)
			jugador.habilidad_gafas.reiniciar()
			if not jugador.activar_gafas():
				_registrar_error("No se pudieron activar las gafas para probar la arena del jefe.")

			await create_timer(0.35).timeout

			escena_principal.call("_on_totem_jefe_interaccion_solicitada", totem_jefe_a)
			await process_frame

			if jefe_sombras.obtener_sellos_activados() != 1:
				_registrar_error("El primer totem no activa el primer sello del jefe.")

			if jefe_sombras.obtener_fase_actual() != 2:
				_registrar_error("El jefe no pasa a fase 2 tras el primer sello.")

			if jefe_sombras.obtener_estado_jefe() != &"aturdido":
				_registrar_error("El jefe no queda aturdido brevemente al activar un sello.")

			escena_principal.call("_on_totem_jefe_interaccion_solicitada", totem_jefe_b)
			await process_frame

			if jefe_sombras.obtener_sellos_activados() != 2:
				_registrar_error("El segundo totem no activa el segundo sello del jefe.")

			if jefe_sombras.obtener_fase_actual() != 3:
				_registrar_error("El jefe no pasa a fase 3 tras el segundo sello.")

			escena_principal.call("_on_totem_jefe_interaccion_solicitada", totem_jefe_c)
			await process_frame

			if not jefe_sombras.esta_derrotado():
				_registrar_error("Activar los tres totems no derrota al jefe de sombras.")

			jugador.global_position = Vector2(1800, 1000)
			jugador.velocity = Vector2.ZERO
			escena_principal.reiniciar_nivel()
			await process_frame
			await physics_frame

			if jugador.global_position.distance_to(respawn_final) > 2.0:
				_registrar_error("Reiniciar el nivel no devuelve al jugador al checkpoint activo.")

			if jugador.vida != jugador.obtener_vida_inicial():
				_registrar_error("El respawn no restaura la vida inicial del jugador.")

			if enemigo.global_position.distance_to(Vector2(522, 231)) > 2.0:
				_registrar_error("El respawn no reinicia al enemigo patrulla a su posicion base.")

			if jefe_sombras.esta_derrotado():
				_registrar_error("El respawn no restablece el estado del jefe.")

			escena_principal.abrir_menu_pausa()
			await process_frame

			if not escena_principal.esta_pausa_activa():
				_registrar_error("El menu de pausa no se activa al abrirlo.")

			if Engine.time_scale > 0.00001:
				_registrar_error("La pausa no reduce la velocidad global del mundo al minimo esperado.")

			if jugador.tiene_control_habilitado():
				_registrar_error("El jugador sigue con controles habilitados durante la pausa.")

			if not enemigo.esta_congelado():
				_registrar_error("El enemigo patrulla no queda congelado al abrir la pausa.")

			escena_principal.cerrar_menu_pausa()
			await process_frame

			if escena_principal.esta_pausa_activa():
				_registrar_error("El menu de pausa no se cierra correctamente.")

			if not is_equal_approx(Engine.time_scale, 1.0):
				_registrar_error("La velocidad global no vuelve a la normalidad despues de cerrar la pausa.")

	if _errores.is_empty():
		print("MOVIMIENTO_OK")
		quit()
		return

	for error in _errores:
		push_error(error)

	quit(1)


func _registrar_error(mensaje: String) -> void:
	_errores.append(mensaje)
