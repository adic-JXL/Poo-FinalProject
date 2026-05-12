extends Node2D
class_name MainGame

const MENU_SCENE := "res://Escenas/Menu.tscn"
const MENSAJE_PUERTA_CERRADA := "La puerta sigue cerrada. Resuelve el puzzle de la llave."
const MENSAJE_NIVEL_COMPLETO := "La puerta se abrio. El nivel base ya esta completo."
const MENSAJE_CHECKPOINT_ACTIVADO := "Checkpoint activado. Si caes, volveras despues de la puerta."
const MENSAJE_CHECKPOINT_GAFAS := "Checkpoint activado. Activa las gafas para revelar el parkour oculto."
const MENSAJE_PUZZLE_GAFAS_COMPLETADO := "Reto de gafas superado. Has revelado el camino alternativo final."
const MENSAJE_GAFAS_REQUERIDAS := "Activa las gafas antes de tocar el altar. Solo asi podras leer sus glifos."
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
@export var duracion_transicion_gafas: float = 0.22

@onready var tile_map: TileMapLayer = $Mapa/TileMapLayer
@onready var puerta = $Objetos/Puerta
@onready var puerta_salida = $Objetos/Puerta2
@onready var checkpoint_puerta: Marker2D = $Objetos/CheckpointPuerta
@onready var altar_gafas = $Objetos/AltarGafas
@onready var checkpoint_puzzle_gafas: Marker2D = $Objetos/CheckpointPuzzleGafas
@onready var jugador: CharacterBody2D = $Player/Jugador
@onready var camara_1: Camera2D = $Player/Camara1
@onready var camara_2: Camera2D = $Player/Camara2
@onready var hud = $Canvas/HUD
@onready var menu_pausa = $Canvas/MenuPausa
@onready var distorsion_overlay: ColorRect = $Canvas/DistorsionOverlay
@onready var llave = $Objetos/Llave
@onready var puzzle = $Canvas/PuzzleSecuencia
@onready var puzzle_gafas = $Canvas/PuzzleGafas

var _posicion_inicial_jugador: Vector2
var _posicion_respawn_actual: Vector2
var _llave_obtenida: bool = false
var _nivel_completado: bool = false
var _puzzle_activo: bool = false
var _checkpoint_activo: bool = false
var _pausa_activa: bool = false
var _golpe_lento_activo: bool = false
var _temporizador_golpe: Timer
var _puzzle_gafas_superado: bool = false
var _tipo_puzzle_activo: StringName = &""
var _tween_transicion_gafas: Tween
var _estado_gafas_aplicado: bool = false


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
	_configurar_interactivo(altar_gafas, _on_altar_gafas_interaccion_solicitada)
	_configurar_interactivo(puerta, _on_puerta_interaccion_solicitada)
	_configurar_puzzles()
	_estado_gafas_aplicado = false
	_aplicar_estado_gafas(false, true)
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

		if altar_gafas != null and altar_gafas.esta_en_rango():
			altar_gafas.interactuar()
			return

		if puerta != null and puerta.esta_en_rango():
			puerta.interactuar()


func reiniciar_nivel() -> void:
	cerrar_menu_pausa()
	_restaurar_tiempo_normal()
	_cerrar_puzzle_si_esta_abierto()
	_restaurar_entidades()
	jugador.restaurar_para_respawn(_posicion_respawn_actual)
	_aplicar_estado_gafas(jugador.gafas_activas(), true)
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


func puzzle_gafas_esta_superado() -> bool:
	return _puzzle_gafas_superado


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


func _configurar_puzzles() -> void:
	puzzle.completado.connect(_on_puzzle_completado)
	puzzle.cancelado.connect(_on_puzzle_cancelado)
	puzzle_gafas.completado.connect(_on_puzzle_gafas_completado)
	puzzle_gafas.cancelado.connect(_on_puzzle_gafas_cancelado)


func _on_llave_interaccion_solicitada() -> void:
	if _llave_obtenida or _puzzle_activo:
		return

	_puzzle_activo = true
	_tipo_puzzle_activo = &"llave"
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


func _on_altar_gafas_interaccion_solicitada() -> void:
	if _puzzle_gafas_superado or _puzzle_activo:
		return

	if not jugador.gafas_activas():
		hud.mostrar_mensaje(MENSAJE_GAFAS_REQUERIDAS)
		return

	_puzzle_activo = true
	_tipo_puzzle_activo = &"gafas"
	jugador.establecer_control_habilitado(false)
	_establecer_enemigos_congelados(true)
	hud.mostrar_mensaje("Los glifos aparecen en el altar. Memoriza el patron antes de que se desvanezca.")
	puzzle_gafas.iniciar_puzzle()


func _on_puzzle_gafas_completado() -> void:
	_puzzle_gafas_superado = true
	if altar_gafas != null and altar_gafas.has_method("marcar_resuelto"):
		altar_gafas.marcar_resuelto()

	if checkpoint_puzzle_gafas != null:
		_establecer_checkpoint(checkpoint_puzzle_gafas.global_position)
		hud.actualizar_checkpoint(_checkpoint_activo)

	_cerrar_puzzle(MENSAJE_PUZZLE_GAFAS_COMPLETADO)


func _on_puzzle_gafas_cancelado() -> void:
	_cerrar_puzzle("El altar se oscurece. Activa las gafas otra vez si quieres reintentar.")


func _cerrar_puzzle(mensaje: String) -> void:
	_puzzle_activo = false
	_tipo_puzzle_activo = &""
	if not _pausa_activa:
		jugador.establecer_control_habilitado(true)
	_establecer_enemigos_congelados(_pausa_activa)
	_cerrar_overlay_puzzle_activo()
	hud.mostrar_mensaje(mensaje)


func _cerrar_puzzle_si_esta_abierto() -> void:
	if not _puzzle_activo and not puzzle.esta_visible() and not puzzle_gafas.esta_visible():
		return

	_puzzle_activo = false
	_tipo_puzzle_activo = &""
	if not _pausa_activa:
		jugador.establecer_control_habilitado(true)
	_establecer_enemigos_congelados(_pausa_activa)
	if puzzle.esta_visible():
		puzzle.cerrar()
	if puzzle_gafas.esta_visible():
		puzzle_gafas.cerrar()


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
	_activar_checkpoint(nueva_posicion_checkpoint, MENSAJE_CHECKPOINT_GAFAS)


func _activar_checkpoint(posicion: Vector2, mensaje: String = MENSAJE_CHECKPOINT_ACTIVADO) -> void:
	_establecer_checkpoint(posicion)
	hud.actualizar_checkpoint(_checkpoint_activo)
	hud.mostrar_mensaje(mensaje)


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
	if activa == _estado_gafas_aplicado:
		return

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
	if _puzzle_gafas_superado:
		hud.mostrar_mensaje("Reto de gafas superado. El camino alternativo final ya es tuyo.")
		return

	if _checkpoint_activo:
		hud.mostrar_mensaje("Checkpoint activo. Usa las gafas para revelar el parkour oculto.")
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


func _aplicar_estado_gafas(activa: bool, instantaneo: bool = false) -> void:
	_estado_gafas_aplicado = activa
	_animar_transicion_gafas(activa, instantaneo)

	var multiplicador_enemigos := FACTOR_LENTITUD_GAFAS_ENEMIGOS if activa else 1.0
	for enemigo in get_tree().get_nodes_in_group("enemigo"):
		if enemigo.has_method("establecer_multiplicador_velocidad"):
			enemigo.establecer_multiplicador_velocidad(multiplicador_enemigos)

	for plataforma in get_tree().get_nodes_in_group("plataforma_gafas"):
		if plataforma.has_method("establecer_revelada"):
			plataforma.establecer_revelada(activa)


func _animar_transicion_gafas(activa: bool, instantaneo: bool) -> void:
	var zoom_objetivo := zoom_con_gafas if activa else zoom_base_mundo
	var alpha_objetivo := alpha_distorsion_gafas if activa else alpha_distorsion_base

	if instantaneo:
		_aplicar_zoom_camaras(zoom_objetivo)
		if distorsion_overlay != null:
			var color_base := distorsion_overlay.color
			color_base.a = alpha_objetivo
			distorsion_overlay.color = color_base
		return

	if _tween_transicion_gafas != null and _tween_transicion_gafas.is_valid():
		_tween_transicion_gafas.kill()

	_tween_transicion_gafas = create_tween()
	_tween_transicion_gafas.set_parallel(true)
	_tween_transicion_gafas.set_trans(Tween.TRANS_SINE)
	_tween_transicion_gafas.set_ease(Tween.EASE_IN_OUT)
	_tween_transicion_gafas.set_ignore_time_scale(true)

	if camara_1 != null:
		_tween_transicion_gafas.tween_property(camara_1, "zoom", zoom_objetivo, duracion_transicion_gafas)

	if camara_2 != null:
		_tween_transicion_gafas.tween_property(camara_2, "zoom", zoom_objetivo, duracion_transicion_gafas)

	if distorsion_overlay != null:
		var color_objetivo := distorsion_overlay.color
		color_objetivo.a = alpha_objetivo
		_tween_transicion_gafas.tween_property(distorsion_overlay, "color", color_objetivo, duracion_transicion_gafas)


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


func _establecer_checkpoint(posicion: Vector2) -> void:
	_checkpoint_activo = true
	_posicion_respawn_actual = posicion


func _cerrar_overlay_puzzle_activo() -> void:
	match _tipo_puzzle_activo:
		&"llave":
			puzzle.cerrar()
		&"gafas":
			puzzle_gafas.cerrar()
		_:
			if puzzle.esta_visible():
				puzzle.cerrar()
			if puzzle_gafas.esta_visible():
				puzzle_gafas.cerrar()


func _exit_tree() -> void:
	_restaurar_tiempo_normal()
