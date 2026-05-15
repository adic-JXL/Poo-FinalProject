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
		var puerta_3 = escena_principal.get_node_or_null("Objetos/Puerta3")
		var puerta_4 = escena_principal.get_node_or_null("Objetos/Puerta4")
		var puerta_mundo_2 = escena_principal.get_node_or_null("Objetos/PuertaMundo2")
		var puerta_mundo_2_destino = escena_principal.get_node_or_null("Objetos/PuertaMundo2Destino")
		var camara_1 = escena_principal.get_node_or_null("Player/Camara1")
		var camara_2 = escena_principal.get_node_or_null("Player/Camara2")
		var camara_3 = escena_principal.get_node_or_null("Player/Camara3")
		var distorsion_overlay = escena_principal.get_node_or_null("Canvas/DistorsionOverlay")
		var plataforma_gafas = escena_principal.get_node_or_null("Plataformas/PlataformaGafas1")
		var altar_gafas = escena_principal.get_node_or_null("Objetos/AltarGafas")
		var checkpoint_puzzle_gafas = escena_principal.get_node_or_null("Objetos/CheckpointPuzzleGafas")
		var checkpoint_puerta_activador = escena_principal.get_node_or_null("Objetos/CheckpointPuerta/Activador")
		var checkpoint_puzzle_gafas_activador = escena_principal.get_node_or_null("Objetos/CheckpointPuzzleGafas/Activador")
		var checkpoint_mundo_2 = escena_principal.get_node_or_null("Objetos/CheckpointMundo2Inicio")
		var checkpoint_mundo_2_activador = escena_principal.get_node_or_null("Objetos/CheckpointMundo2Inicio/Activador")
		var totem_jefe_a = escena_principal.get_node_or_null("Objetos/TotemJefeA")
		var totem_jefe_b = escena_principal.get_node_or_null("Objetos/TotemJefeB")
		var totem_jefe_c = escena_principal.get_node_or_null("Objetos/TotemJefeC")
		var puzzle_gafas = escena_principal.get_node_or_null("Canvas/PuzzleGafas")
		var muro_bloqueo_arena = escena_principal.get_node_or_null("Plataformas/ArenaJefeMuroIzquierdo")
		var muro_arena_superior = escena_principal.get_node_or_null("Plataformas/ArenaJefeMuroIzquierdoSuperior")
		var muro_arena_inferior = escena_principal.get_node_or_null("Plataformas/ArenaJefeMuroIzquierdoInferior")
		var piso_arena_jefe = escena_principal.get_node_or_null("Plataformas/ArenaJefePiso")
		var base_mundo_2 = escena_principal.get_node_or_null("Plataformas/BaseMundo2Inicio")
		var enemigo_ruta_media = escena_principal.get_node_or_null("Enemigos/EnemigoFlotanteHorizontalRutaMedia")
		var enemigo_parkour = escena_principal.get_node_or_null("Enemigos/EnemigoFlotanteHorizontalParkourA")
		var enemigo_vertical_zona_puerta = escena_principal.get_node_or_null("Enemigos/EnemigoFlotanteVerticalZonaPuerta")
		var enemigo_vertical_ruta_central = escena_principal.get_node_or_null("Enemigos/EnemigoFlotanteVerticalRutaCentral")
		var enemigo_vertical_parkour_c = escena_principal.get_node_or_null("Enemigos/EnemigoFlotanteVerticalParkourC")
		var mundo_2_configurado := puerta_mundo_2 != null and puerta_mundo_2_destino != null and checkpoint_mundo_2 != null and checkpoint_mundo_2_activador != null and base_mundo_2 != null

		if muro_bloqueo_arena != null:
			_registrar_error("La pared completa de entrada a la arena del jefe sigue bloqueando el acceso.")

		if muro_arena_superior == null and muro_arena_inferior == null:
			pass
		elif muro_arena_superior == null or muro_arena_inferior == null:
			_registrar_error("La arena del jefe no tiene la entrada abierta con muros separados.")

		if piso_arena_jefe != null and piso_arena_jefe.scale.x < 9.0:
			_registrar_error("La arena del jefe no quedo lo bastante amplia.")

		if mundo_2_configurado and camara_2 != null and camara_2.limit_right < 12000:
			_registrar_error("La camara secundaria no alcanza a cubrir la salida hacia el mundo 2.")

		if enemigo_ruta_media == null or enemigo_parkour == null:
			_registrar_error("No se instanciaron enemigos nuevos en el trayecto hacia el jefe.")

		if enemigo_vertical_zona_puerta == null or enemigo_vertical_ruta_central == null or enemigo_vertical_parkour_c == null:
			_registrar_error("No se añadieron enemigos flotantes verticales en los tramos vacios del recorrido.")

		if puerta_mundo_2 != null and puerta_mundo_2.visible:
			_registrar_error("La puerta final del mundo 2 aparece antes de derrotar al jefe.")

		if enemigo == null or perseguidor == null or flotante_horizontal == null or flotante_vertical == null or jefe_sombras == null or llave == null or puzzle == null or puerta == null or puerta_destino == null or puerta_3 == null or puerta_4 == null or camara_1 == null or camara_2 == null or camara_3 == null or distorsion_overlay == null or plataforma_gafas == null or altar_gafas == null or checkpoint_puzzle_gafas == null or checkpoint_puerta_activador == null or checkpoint_puzzle_gafas_activador == null or totem_jefe_a == null or totem_jefe_b == null or totem_jefe_c == null or puzzle_gafas == null:
			_registrar_error("Faltan nodos del flujo principal en MainGame.")
		else:
			if not distorsion_overlay.visible:
				_registrar_error("La capa de distorsion visual no esta activa al iniciar la escena.")

			if not (distorsion_overlay.material is ShaderMaterial):
				_registrar_error("La distorsion visual no usa el shader de viñeta esperado.")

			if distorsion_overlay.color.a < 0.15:
				_registrar_error("La intensidad base de la viñeta quedo demasiado baja al iniciar.")

			if puerta_3.visible:
				_registrar_error("La puerta 3 aparece antes de completar el puzzle previo al jefe.")

			if jefe_sombras.velocidad > 70.69:
				_registrar_error("La velocidad base del jefe no se redujo el 6% adicional esperado.")

			var shape_cuerpo = jefe_sombras.get_node_or_null("CollisionShape2D")
			var shape_ataque = jefe_sombras.get_node_or_null("AreaAtaque/CollisionShape2D")
			if shape_cuerpo == null or shape_ataque == null:
				_registrar_error("No se encontraron las hitboxes principales del jefe.")
			else:
				var radio_cuerpo := (shape_cuerpo.shape as CircleShape2D).radius
				var radio_ataque := (shape_ataque.shape as CircleShape2D).radius
				if radio_cuerpo > 18.6 or radio_ataque > 18.6:
					_registrar_error("La hitbox del jefe no se redujo aproximadamente un 30 por ciento.")

			if jefe_sombras.arena_min.x > puerta_4.global_position.x + 32.0 or jefe_sombras.arena_max.x < totem_jefe_b.global_position.x - 32.0:
				_registrar_error("El rango horizontal del jefe no cubre bien la nueva jaula de combate.")

			if jefe_sombras.arena_min.y > minf(totem_jefe_a.global_position.y, totem_jefe_c.global_position.y) + 12.0:
				_registrar_error("El rango vertical del jefe quedo demasiado corto para la nueva arena.")

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

			if jugador.obtener_velocidad_movimiento_actual() < jugador.velocidad_base * 1.049:
				_registrar_error("Las gafas no aumentan la velocidad base del jugador en el porcentaje esperado.")

			if jugador.obtener_fuerza_salto_actual() < jugador.fuerza_salto * 1.149:
				_registrar_error("Las gafas no aumentan la fuerza de salto del jugador en el porcentaje esperado.")

			if enemigo.obtener_multiplicador_velocidad() > 0.901:
				_registrar_error("Las gafas no reducen la velocidad base de los enemigos.")

			jugador.velocity = Vector2.ZERO
			jugador.mover_con_multiplicador(1.0, 0.2, 1.0)
			if jugador.velocity.x < jugador.velocidad_base * 1.049:
				_registrar_error("El movimiento real con gafas no refleja el buff de velocidad esperado.")

			var zoom_con_gafas_x_antes: float = camara_1.zoom.x
			await create_timer(0.35).timeout

			if not plataforma_gafas.esta_revelada():
				_registrar_error("Las plataformas ocultas no se revelan con las gafas activas.")

			if distorsion_overlay.color.a > 0.03:
				_registrar_error("La viñeta no se anula al activar las gafas.")

			jugador.global_position = plataforma_gafas.global_position
			jugador.velocity = Vector2.ZERO
			plataforma_gafas.establecer_revelada(false)
			await physics_frame
			plataforma_gafas.establecer_revelada(true)
			await physics_frame

			if plataforma_gafas.esta_revelada():
				_registrar_error("La plataforma de gafas reactiva su colision aun con el jugador superpuesto, lo que puede atascarlo.")

			jugador.global_position = plataforma_gafas.global_position + Vector2(120, 0)
			jugador.velocity = Vector2.ZERO
			for _pl in range(3):
				await physics_frame

			if not plataforma_gafas.esta_revelada():
				_registrar_error("La plataforma de gafas no reactiva su colision cuando el jugador sale de su volumen.")

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

			if distorsion_overlay.color.a < 0.15:
				_registrar_error("La viñeta no vuelve al terminar el efecto de las gafas.")

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

			escena_principal.reiniciar_nivel()
			await process_frame
			await physics_frame

			if jugador.global_position.distance_to(escena_principal.obtener_spawn_jugador()) > 2.0:
				_registrar_error("Caer antes del checkpoint posterior no devuelve al jugador al inicio esperado.")

			if not camara_1.is_current():
				_registrar_error("La camara no vuelve al tramo inicial al reiniciar antes del primer checkpoint.")

			jugador.global_position = puerta.global_position
			jugador.velocity = Vector2.ZERO
			puerta.teletransportar_jugador(jugador)
			await create_timer(0.4).timeout

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
			await create_timer(0.7).timeout

			if not escena_principal.puzzle_gafas_esta_superado():
				_registrar_error("Completar el puzzle de gafas no marca el reto final como superado.")

			if not puerta_3.visible:
				_registrar_error("La puerta 3 no aparece al completar el puzzle previo al jefe.")

			if not puerta_3.puede_teletransportar():
				_registrar_error("La puerta 3 aparece, pero no queda lista para llevar al jugador hacia la puerta 4.")

			if escena_principal.obtener_respawn_actual().distance_to(respawn_checkpoint) > 1.0:
				_registrar_error("Completar el puzzle de gafas no deberia activar el checkpoint final automaticamente.")

			var salida_puerta_3: Vector2 = puerta_4.obtener_punto_salida()
			jugador.global_position = puerta_3.global_position
			jugador.velocity = Vector2.ZERO
			puerta_3.teletransportar_jugador(jugador)
			await create_timer(0.4).timeout
			for _c3 in range(3):
				await physics_frame

			if jugador.global_position.distance_to(salida_puerta_3) > 24.0:
				_registrar_error("La puerta 3 no teletransporta correctamente al jugador hacia la puerta 4.")

			if not camara_3.is_current():
				_registrar_error("La camara 3 no se activa al entrar en el Area2D3 de la zona del jefe.")

			jugador.habilidad_gafas.reiniciar()
			await process_frame
			await create_timer(0.15).timeout

			if distorsion_overlay.color.a < escena_principal.alpha_distorsion_jefe - 0.04:
				_registrar_error("La viñeta no se intensifica al entrar en la zona del jefe.")

			var material_vineta := distorsion_overlay.material as ShaderMaterial
			if material_vineta == null:
				_registrar_error("La zona del jefe no tiene acceso al material de viñeta.")
			else:
				var oscuridad_jefe := float(material_vineta.get_shader_parameter("edge_darkness"))
				var aberracion_jefe := float(material_vineta.get_shader_parameter("aberration_strength"))
				if oscuridad_jefe < escena_principal.edge_darkness_jefe - 0.03:
					_registrar_error("El perfil de viñeta del jefe no aumenta la oscuridad periférica.")
				if aberracion_jefe < escena_principal.aberration_strength_jefe - 0.08:
					_registrar_error("El perfil de viñeta del jefe no aumenta la aberración cromática esperada.")

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

			if mundo_2_configurado:
				if not escena_principal.mundo_2_esta_desbloqueado():
					_registrar_error("Derrotar al jefe no desbloquea la salida hacia el mundo 2.")

				if not puerta_mundo_2.visible:
					_registrar_error("La puerta final no aparece al derrotar al jefe.")

				if not puerta_mundo_2.puede_teletransportar():
					_registrar_error("La puerta final aparece, pero no queda lista para llevar al mundo 2.")

				var salida_mundo_2: Vector2 = puerta_mundo_2_destino.obtener_punto_salida()
				puerta_mundo_2.teletransportar_jugador(jugador)
				await create_timer(0.4).timeout

				if jugador.global_position.distance_to(salida_mundo_2) > 24.0:
					_registrar_error("La puerta final no traslada al jugador hacia la base provisional del mundo 2.")

				jugador.global_position = checkpoint_mundo_2_activador.global_position
				jugador.velocity = Vector2.ZERO
				for _cm2 in range(3):
					await physics_frame

				if not escena_principal.mundo_2_esta_alcanzado():
					_registrar_error("El checkpoint del mundo 2 no marca la llegada a la nueva base.")

				var respawn_mundo_2: Vector2 = escena_principal.obtener_respawn_actual()
				if respawn_mundo_2.distance_to(checkpoint_mundo_2.global_position) > 1.0:
					_registrar_error("El checkpoint del mundo 2 no actualiza el respawn al inicio provisional.")

				jugador.global_position = Vector2(1800, 1000)
				jugador.velocity = Vector2.ZERO
				escena_principal.reiniciar_nivel()
				await process_frame
				await physics_frame

				if jugador.global_position.distance_to(respawn_mundo_2) > 2.0:
					_registrar_error("Reiniciar el nivel no devuelve al jugador al checkpoint activo del mundo 2.")

				if jugador.vida != jugador.obtener_vida_inicial():
					_registrar_error("El respawn no restaura la vida inicial del jugador.")

				if enemigo.global_position.distance_to(Vector2(522, 231)) > 2.0:
					_registrar_error("El respawn no reinicia al enemigo patrulla a su posicion base.")

				if not jefe_sombras.esta_derrotado():
					_registrar_error("El respawn restablecio al jefe aun despues de abrir la salida al mundo 2.")

				if not puerta_mundo_2.visible or not puerta_mundo_2.puede_teletransportar():
					_registrar_error("La puerta final deja de estar disponible tras reiniciar el nivel.")
			else:
				jugador.global_position = Vector2(1800, 1000)
				jugador.velocity = Vector2.ZERO
				escena_principal.reiniciar_nivel()
				await process_frame
				await physics_frame

				if jugador.vida != jugador.obtener_vida_inicial():
					_registrar_error("El respawn no restaura la vida inicial del jugador.")

				if enemigo.global_position.distance_to(Vector2(522, 231)) > 2.0:
					_registrar_error("El respawn no reinicia al enemigo patrulla a su posicion base.")

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
