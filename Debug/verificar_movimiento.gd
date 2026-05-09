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

	var jugador = escena_principal.get_node_or_null("Jugador")
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

		var enemigo = escena_principal.get_node_or_null("EnemigoPatrulla")
		var perseguidor = escena_principal.get_node_or_null("EnemigoPerseguidor")
		var llave = escena_principal.get_node_or_null("Llave")
		var puzzle = escena_principal.get_node_or_null("PuzzleSecuencia")
		var puerta = escena_principal.get_node_or_null("Puerta")

		if enemigo == null or perseguidor == null or llave == null or puzzle == null or puerta == null:
			_registrar_error("Faltan nodos del flujo principal en MainGame.")
		else:
			var posicion_inicial_enemigo_x: float = enemigo.global_position.x
			for _m in range(15):
				await physics_frame

			if absf(enemigo.global_position.x - posicion_inicial_enemigo_x) < 2.0:
				_registrar_error("El enemigo patrulla no se esta desplazando.")

			var vida_inicial: int = jugador.vida
			jugador.global_position = enemigo.global_position + Vector2(24, 0)
			jugador.velocity = Vector2.ZERO
			for _n in range(18):
				await physics_frame

			if jugador.vida >= vida_inicial:
				_registrar_error("El enemigo no dano al jugador al entrar en contacto.")

			if not jugador.esta_invulnerable():
				_registrar_error("El jugador no entra en invulnerabilidad despues de recibir dano.")

			var vida_tras_golpe: int = jugador.vida
			if jugador.recibir_danio(1):
				_registrar_error("La invulnerabilidad no bloquea un segundo golpe inmediato.")

			if jugador.vida != vida_tras_golpe:
				_registrar_error("La vida del jugador cambio durante la invulnerabilidad.")

			jugador.global_position = Vector2(120, 291)
			jugador.velocity = Vector2.ZERO
			for _o in range(70):
				await physics_frame

			if jugador.esta_invulnerable():
				_registrar_error("La invulnerabilidad del jugador no termina despues del tiempo esperado.")

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

			jugador.global_position = perseguidor.global_position + Vector2(direccion_mirada * 150.0, 0.0)
			jugador.velocity = Vector2.ZERO
			for _q in range(16):
				await physics_frame

			if not perseguidor.esta_persiguiendo():
				_registrar_error("El perseguidor no entra en persecucion cuando el jugador esta dentro del campo de vision.")

			if absf(perseguidor.velocity.x) <= 0.0:
				_registrar_error("El perseguidor no genera movimiento horizontal al perseguir.")

			if absf(perseguidor.velocity.x) > jugador.velocidad_base * 0.55:
				_registrar_error("El perseguidor supera el limite esperado de media velocidad del jugador.")

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

	if _errores.is_empty():
		print("MOVIMIENTO_OK")
		quit()
		return

	for error in _errores:
		push_error(error)

	quit(1)


func _registrar_error(mensaje: String) -> void:
	_errores.append(mensaje)
