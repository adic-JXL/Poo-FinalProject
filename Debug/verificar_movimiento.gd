extends SceneTree

var _errores: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_ejecutar_verificacion")


func _ejecutar_verificacion() -> void:
	var escena_principal: Node = load("res://Escenas/MainGame.tscn").instantiate()
	root.add_child(escena_principal)

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

		var estamina_despues_sprint: float = jugador.obtener_estamina_actual()
		if estamina_despues_sprint >= estamina_inicial:
			_registrar_error("El sprint no consumio estamina.")

		jugador.actualizar_movimiento_horizontal(0.0, false, 0.5)
		if jugador.obtener_estamina_actual() <= estamina_despues_sprint:
			_registrar_error("La estamina no se regenera cuando el jugador deja de correr.")

		var llave = escena_principal.get_node_or_null("Llave")
		var puzzle = escena_principal.get_node_or_null("PuzzleSecuencia")
		var puerta = escena_principal.get_node_or_null("Puerta")

		if llave == null or puzzle == null or puerta == null:
			_registrar_error("Faltan nodos del flujo llave-puzzle-puerta en MainGame.")
		else:
			jugador.global_position = llave.global_position
			for _j in range(3):
				await physics_frame

			llave.interactuar()
			await process_frame

			if not escena_principal.esta_puzzle_activo():
				_registrar_error("La llave no activa el puzzle al interactuar.")

			if jugador.tiene_control_habilitado():
				_registrar_error("El jugador no se congela mientras el puzzle esta activo.")

			puzzle.resolver_automaticamente_para_prueba()
			await process_frame

			if not escena_principal.tiene_llave():
				_registrar_error("Completar el puzzle no entrega la llave.")

			if escena_principal.esta_puzzle_activo():
				_registrar_error("El puzzle no se cierra despues de completarse.")

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
