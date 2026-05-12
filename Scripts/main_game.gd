extends Node2D
class_name MainGame

const MENU_SCENE := "res://Escenas/Menu.tscn"
const MENSAJE_PUERTA_CERRADA := "La puerta sigue cerrada. Resuelve el puzzle de la llave."
const MENSAJE_NIVEL_COMPLETO := "La puerta se abrio. El nivel base ya esta completo."
const MENSAJE_CHECKPOINT_ACTIVADO := "Checkpoint activado. Si caes, volveras despues de la puerta."
const ESCALA_TIEMPO_PAUSA := 0.000001
const FACTOR_LENTITUD_GAFAS_ENEMIGOS := 0.97

@export var limite_caida_y: float = 700.0
@export var escala_tiempo_golpe: float = 0.45
@export var duracion_golpe_lento: float = 0.1
@export var desplazamiento_checkpoint_puerta: Vector2 = Vector2(72, 0)
@export var zoom_base_mundo: Vector2 = Vector2(2.15, 2.15)
@export var zoom_con_gafas: Vector2 = Vector2(1.75, 1.75)
@export var alpha_distorsion_base: float = 0.18
@export var alpha_distorsion_gafas: float = 0.0

@onready var tile_map: TileMapLayer = $Mapa/TileMapLayer
@onready var puerta = $Objetos/Puerta
@onready var puerta_salida = $Objetos/Puerta2
@onready var checkpoint_puerta: Marker2D = $Objetos/CheckpointPuerta
@onready var jugador: CharacterBody2D = $Player/Jugador
@onready var camara_1: Camera2D = $Player/Camara1
@onready var camara_2: Camera2D = $Player/Camara2
@onready var hud = $Canvas/HUD
@onready var menu_pausa = $Canvas/MenuPausa
@onready var distorsion_overlay: ColorRect = $Canvas/DistorsionOverlay
@onready var llave = $Objetos/Llave
@onready var puzzle = $Canvas/PuzzleSecuencia

var _posicion_inicial_jugador: Vector2
var _posicion_respawn_actual: Vector2
var _llave_obtenida: bool = false
var _nivel_completado: bool = false
var _puzzle_activo: bool = false
var _checkpoint_activo: bool = false
var _pausa_activa: bool = false
var _golpe_lento_activo: bool = false
var _temporizador_golpe: Timer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_preparar_temporizador_golpe()
	_posicion_inicial_jugador = jugador.global_position
	_posicion_respawn_actual = _posicion_inicial_jugador

	_configurar_hud()
	_configurar_jugador()
	_configurar_puertas()
	_configurar_enemigos()
	_configurar_gafas()
	_configurar_menu_pausa()
	_configurar_interactivo(llave, _on_llave_interaccion_solicitada)
	_configurar_interactivo(puerta, _on_puerta_interaccion_solicitada)
	_configurar_puzzle()
	_aplicar_estado_gafas(false)
	_restaurar_mensaje_hud()


func _physics_process(_delta: float) -> void:
	if _pausa_activa:
		return

	if jugador.global_position.y > limite_caida_y:
		reiniciar_nivel()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pausa"):
		alternar_pausa()
		get_viewport().set_input_as_handled()
		return

	if _pausa_activa:
		return

	if event.is_action_pressed("reiniciar"):
		reiniciar_nivel()
		return

	if _puzzle_activo:
		return

	if event.is_action_pressed("interactuar"):
		if llave != null and llave.esta_en_rango():
			llave.interactuar()
			return

		if puerta != null and puerta.esta_en_rango():
			puerta.interactuar()


func reiniciar_nivel() -> void:
	cerrar_menu_pausa()
	_restaurar_tiempo_normal()
	_cerrar_puzzle_si_esta_abierto()
	_restaurar_entidades()
	jugador.restaurar_para_respawn(_posicion_respawn_actual)
	_aplicar_estado_gafas(jugador.gafas_activas())
	_restaurar_mensaje_hud()


func volver_al_menu() -> void:
	cerrar_menu_pausa()
	_restaurar_tiempo_normal()
	get_tree().change_scene_to_file(MENU_SCENE)


func obtener_jugador() -> CharacterBody2D:
	return jugador


func obtener_spawn_jugador() -> Vector2:
	return _posicion_inicial_jugador


func obtener_respawn_actual() -> Vector2:
	return _posicion_respawn_actual


func tiene_llave() -> bool:
	return _llave_obtenida


func esta_puzzle_activo() -> bool:
	return _puzzle_activo


func checkpoint_esta_activo() -> bool:
	return _checkpoint_activo


func esta_pausa_activa() -> bool:
	return _pausa_activa


func nivel_esta_completado() -> bool:
	return _nivel_completado


func alternar_pausa() -> void:
	if _pausa_activa:
		cerrar_menu_pausa()
		return

	abrir_menu_pausa()


func abrir_menu_pausa() -> void:
	if _pausa_activa:
		return

	_pausa_activa = true
	jugador.velocity = Vector2.ZERO
	jugador.establecer_control_habilitado(false)
	_establecer_enemigos_congelados(true)
	_actualizar_escala_tiempo()
	menu_pausa.abrir(_checkpoint_activo, _obtener_descripcion_checkpoint())


func cerrar_menu_pausa() -> void:
	if not _pausa_activa:
		return

	_pausa_activa = false
	if not _puzzle_activo:
		jugador.establecer_control_habilitado(true)
	_establecer_enemigos_congelados(_puzzle_activo)
	_actualizar_escala_tiempo()
	menu_pausa.cerrar()


func _configurar_hud() -> void:
	hud.configurar_jugador(jugador)
	hud.actualizar_llave(_llave_obtenida)
	hud.actualizar_checkpoint(_checkpoint_activo)


func _configurar_jugador() -> void:
	jugador.vida_cambiada.connect(_on_jugador_vida_cambiada)
	jugador.dano_recibido.connect(_on_jugador_dano_recibido)
	jugador.gafas_actualizadas.connect(_on_jugador_gafas_actualizadas)


func _configurar_puertas() -> void:
	if puerta != null and puerta_salida != null and puerta.has_method("configurar_destino"):
		puerta.configurar_destino(puerta_salida)

	if puerta != null and puerta.has_signal("teletransporte_realizado"):
		puerta.teletransporte_realizado.connect(_on_puerta_teletransporte_realizado)


func _configurar_enemigos() -> void:
	for enemigo in get_tree().get_nodes_in_group("enemigo"):
		if enemigo.has_signal("jugador_danado"):
			enemigo.jugador_danado.connect(_on_enemigo_jugador_danado)


func _configurar_gafas() -> void:
	if distorsion_overlay != null:
		distorsion_overlay.color.a = alpha_distorsion_base


func _configurar_menu_pausa() -> void:
	menu_pausa.continuar_solicitado.connect(cerrar_menu_pausa)
	menu_pausa.reiniciar_solicitado.connect(reiniciar_nivel)
	menu_pausa.volver_menu_solicitado.connect(volver_al_menu)


func _configurar_interactivo(interactivo: Node, callback: Callable) -> void:
	if interactivo == null:
		return

	interactivo.interaccion_solicitada.connect(callback)
	interactivo.rango_interaccion_cambiado.connect(_on_rango_interaccion_cambiado)


func _configurar_puzzle() -> void:
	puzzle.completado.connect(_on_puzzle_completado)
	puzzle.cancelado.connect(_on_puzzle_cancelado)


func _on_llave_interaccion_solicitada() -> void:
	if _llave_obtenida or _puzzle_activo:
		return

	_puzzle_activo = true
	jugador.establecer_control_habilitado(false)
	_establecer_enemigos_congelados(true)
	hud.mostrar_mensaje("La llave te arrastra a un ritual. Resuelve la secuencia para reclamarla.")
	puzzle.iniciar_puzzle()


func _on_puzzle_completado() -> void:
	_llave_obtenida = true
	hud.actualizar_llave(_llave_obtenida)
	llave.otorgar_llave()
	_cerrar_puzzle("Has obtenido la llave. Ahora vuelve a la puerta y presiona E.")


func _on_puzzle_cancelado() -> void:
	_cerrar_puzzle("Saliste del puzzle. Puedes volver a intentarlo cuando quieras.")


func _cerrar_puzzle(mensaje: String) -> void:
	_puzzle_activo = false
	if not _pausa_activa:
		jugador.establecer_control_habilitado(true)
	_establecer_enemigos_congelados(_pausa_activa)
	puzzle.cerrar()
	hud.mostrar_mensaje(mensaje)


func _cerrar_puzzle_si_esta_abierto() -> void:
	if not _puzzle_activo and not puzzle.esta_visible():
		return

	_puzzle_activo = false
	if not _pausa_activa:
		jugador.establecer_control_habilitado(true)
	_establecer_enemigos_congelados(_pausa_activa)
	puzzle.cerrar()


func _on_puerta_interaccion_solicitada() -> void:
	if _nivel_completado:
		return

	if not _llave_obtenida:
		hud.mostrar_mensaje(MENSAJE_PUERTA_CERRADA)
		return

	_nivel_completado = true
	puerta.abrir()
	hud.mostrar_mensaje(MENSAJE_NIVEL_COMPLETO)


func _on_puerta_teletransporte_realizado(_jugador: Node2D, destino: Node2D) -> void:
	if destino == null or not destino.has_method("obtener_punto_salida"):
		return

	var nueva_posicion_checkpoint := _obtener_posicion_checkpoint_puerta(destino)
	_activar_checkpoint(nueva_posicion_checkpoint)


func _activar_checkpoint(posicion: Vector2) -> void:
	_checkpoint_activo = true
	_posicion_respawn_actual = posicion
	hud.actualizar_checkpoint(_checkpoint_activo)
	hud.mostrar_mensaje(MENSAJE_CHECKPOINT_ACTIVADO)


func _on_jugador_vida_cambiada(vida_actual: int) -> void:
	if vida_actual > 0:
		return

	hud.mostrar_mensaje("La sombra te vencio. Regresando al ultimo checkpoint.")
	call_deferred("reiniciar_nivel")


func _on_enemigo_jugador_danado(_cantidad: int) -> void:
	if not _puzzle_activo:
		hud.mostrar_mensaje("Una sombra te alcanzo. Mantente en movimiento.")


func _on_jugador_dano_recibido(_cantidad: int, _direccion: float) -> void:
	_aplicar_golpe_lento()


func _on_jugador_gafas_actualizadas(activa: bool, _duracion_restante: float, _cooldown_restante: float, _cooldown_actual: float, _siguiente_cooldown: float) -> void:
	_aplicar_estado_gafas(activa)


func _establecer_enemigos_congelados(congelados: bool) -> void:
	for enemigo in get_tree().get_nodes_in_group("enemigo"):
		if enemigo.has_method("establecer_congelado"):
			enemigo.establecer_congelado(congelados)


func _restaurar_entidades() -> void:
	for enemigo in get_tree().get_nodes_in_group("enemigo"):
		if enemigo.has_method("reiniciar_enemigo"):
			enemigo.reiniciar_enemigo()

		if enemigo.has_method("establecer_multiplicador_velocidad"):
			enemigo.establecer_multiplicador_velocidad(FACTOR_LENTITUD_GAFAS_ENEMIGOS if jugador.gafas_activas() else 1.0)


func _on_rango_interaccion_cambiado(activo: bool, mensaje: String) -> void:
	if _puzzle_activo or _pausa_activa:
		return

	if activo:
		hud.mostrar_mensaje(mensaje)
		return

	_restaurar_mensaje_hud()


func _restaurar_mensaje_hud() -> void:
	if _checkpoint_activo:
		hud.mostrar_mensaje("Checkpoint activo. Puedes seguir avanzando desde la nueva zona.")
		return

	if _nivel_completado:
		hud.mostrar_mensaje(MENSAJE_NIVEL_COMPLETO)
		return

	if _llave_obtenida:
		hud.mostrar_mensaje("Tienes la llave. Busca la puerta y presiona E para abrirla.")
		return

	hud.mostrar_mensaje("Explora el nivel, encuentra la llave y presiona E para activar el puzzle.")


func _obtener_descripcion_checkpoint() -> String:
	return "(%.0f, %.0f)" % [_posicion_respawn_actual.x, _posicion_respawn_actual.y]


func _aplicar_estado_gafas(activa: bool) -> void:
	_aplicar_zoom_camaras(zoom_con_gafas if activa else zoom_base_mundo)

	if distorsion_overlay != null:
		distorsion_overlay.color.a = alpha_distorsion_gafas if activa else alpha_distorsion_base

	var multiplicador_enemigos := FACTOR_LENTITUD_GAFAS_ENEMIGOS if activa else 1.0
	for enemigo in get_tree().get_nodes_in_group("enemigo"):
		if enemigo.has_method("establecer_multiplicador_velocidad"):
			enemigo.establecer_multiplicador_velocidad(multiplicador_enemigos)

	for plataforma in get_tree().get_nodes_in_group("plataforma_gafas"):
		if plataforma.has_method("establecer_revelada"):
			plataforma.establecer_revelada(activa)


func _aplicar_zoom_camaras(zoom_objetivo: Vector2) -> void:
	if camara_1 != null:
		camara_1.zoom = zoom_objetivo

	if camara_2 != null:
		camara_2.zoom = zoom_objetivo


func _preparar_temporizador_golpe() -> void:
	_temporizador_golpe = Timer.new()
	_temporizador_golpe.one_shot = true
	_temporizador_golpe.ignore_time_scale = true
	_temporizador_golpe.timeout.connect(_on_temporizador_golpe_timeout)
	add_child(_temporizador_golpe)


func _aplicar_golpe_lento() -> void:
	if duracion_golpe_lento <= 0.0:
		return

	_golpe_lento_activo = true
	_actualizar_escala_tiempo()
	_temporizador_golpe.start(duracion_golpe_lento)


func _on_temporizador_golpe_timeout() -> void:
	_golpe_lento_activo = false
	_restaurar_tiempo_normal()


func _restaurar_tiempo_normal() -> void:
	_actualizar_escala_tiempo()


func _actualizar_escala_tiempo() -> void:
	if _pausa_activa:
		Engine.time_scale = ESCALA_TIEMPO_PAUSA
		return

	if _golpe_lento_activo:
		Engine.time_scale = min(max(escala_tiempo_golpe, 0.05), 1.0)
		return

	Engine.time_scale = 1.0


func _obtener_posicion_checkpoint_puerta(destino: Node2D) -> Vector2:
	if checkpoint_puerta != null:
		return checkpoint_puerta.global_position

	return destino.obtener_punto_salida() + desplazamiento_checkpoint_puerta


func _exit_tree() -> void:
	_restaurar_tiempo_normal()
