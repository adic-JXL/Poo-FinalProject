extends SceneTree


func _initialize() -> void:
	call_deferred("_ejecutar")


func _ejecutar() -> void:
	var escena_principal: Node = load("res://Escenas/MainGame.tscn").instantiate()
	root.add_child(escena_principal)
	await process_frame
	await process_frame

	var jugador = escena_principal.get_node_or_null("Player/Jugador")
	var overlay = escena_principal.get_node_or_null("Canvas/DistorsionOverlay")
	var puerta_4 = escena_principal.get_node_or_null("Objetos/Puerta4")
	if jugador == null or overlay == null or puerta_4 == null:
		print("FALTAN_NODOS")
		quit(1)
		return

	jugador.global_position = puerta_4.global_position + Vector2(24, 8)
	jugador.habilidad_gafas.reiniciar()
	escena_principal.call("_actualizar_estado_zona_jefe", true)
	escena_principal.call("_sincronizar_camara_con_jugador")
	await process_frame
	await create_timer(0.2).timeout

	var material = overlay.material as ShaderMaterial
	print("ALPHA=", overlay.color.a)
	if material != null:
		print("EDGE=", material.get_shader_parameter("edge_darkness"))
		print("ABERRATION=", material.get_shader_parameter("aberration_strength"))

	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("C:/Users/HP/Documents/GitHub/Poo-FinalProject/Debug/vigneta_jefe.png")
	quit()
