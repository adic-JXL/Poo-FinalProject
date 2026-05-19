extends SceneTree

const RUTA_CAPTURA_BASE := "C:/Users/HP/Documents/GitHub/Poo-FinalProject/Debug/vigneta_base.png"
const RUTA_CAPTURA_GAFAS := "C:/Users/HP/Documents/GitHub/Poo-FinalProject/Debug/vigneta_gafas.png"


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	var escena_principal: Node = load("res://Escenas/MainGame.tscn").instantiate()
	root.add_child(escena_principal)
	escena_principal.limite_caida_y = 5000.0

	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	_guardar_captura(RUTA_CAPTURA_BASE)

	var jugador = escena_principal.get_node_or_null("Player/Jugador")
	if jugador != null and jugador.has_method("activar_gafas"):
		jugador.activar_gafas()

	await process_frame
	await create_timer(0.35).timeout
	await RenderingServer.frame_post_draw
	_guardar_captura(RUTA_CAPTURA_GAFAS)
	quit()


func _guardar_captura(ruta: String) -> void:
	var imagen := root.get_texture().get_image()
	if imagen == null:
		return

	imagen.save_png(ruta)
