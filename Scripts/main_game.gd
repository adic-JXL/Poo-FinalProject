extends Node2D
class_name MainGame

const MENU_SCENE := "res://Escenas/Menu.tscn"
const MENSAJE_PUERTA_CERRADA := "La puerta sigue cerrada. Resuelve el puzzle de la llave."
const MENSAJE_NIVEL_COMPLETO := "La puerta se abrio. El nivel base ya esta completo."
const MENSAJE_CHECKPOINT_ACTIVADO := "Checkpoint activado. Si caes, volveras despues de la puerta."
const MENSAJE_CHECKPOINT_PUERTA_DISPONIBLE := "Nueva zona alcanzada. Pisa el punto verde para guardar tu avance."
const MENSAJE_CHECKPOINT_GAFAS_ACTIVADO := "Checkpoint activado. Activa las gafas para revelar el parkour oculto."
const MENSAJE_PUZZLE_GAFAS_COMPLETADO := "Reto de gafas superado. La puerta hacia la arena del jefe ya esta activa."
const MENSAJE_CHECKPOINT_ALTAR_DISPONIBLE := "El altar respondio. Pisa el punto azul para guardar este avance."
const MENSAJE_GAFAS_REQUERIDAS := "Activa las gafas antes de tocar el altar. Solo asi podras leer sus glifos."
const MENSAJE_TOTEM_SIN_GAFAS := "Los totems solo responden cuando miras con las gafas."
const MENSAJE_JEFE_DERROTADO := "El jefe se desmorona. Una puerta al siguiente mundo emerge dentro de la arena."
const MENSAJE_PUERTA_JEFE_REVELADA := "El puzzle se resolvio. La puerta hacia la arena del jefe se revela frente a ti."
const MENSAJE_LLEGADA_ARENA_JEFE := "Has entrado en la arena del jefe. Usa las gafas y activa los tres totems."
const MENSAJE_LLEGADA_MUNDO_2 := "Has cruzado al inicio provisional del mundo 2. Avanza hasta el punto dorado para fijar este nuevo comienzo."
const MENSAJE_CHECKPOINT_MUNDO_2_ACTIVADO := "Checkpoint del mundo 2 activado. Esta base plana ya puede servir como nuevo inicio."
const ESCALA_TIEMPO_PAUSA := 0.000001
const FACTOR_LENTITUD_GAFAS_ENEMIGOS := 0.90

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
@onready var puerta_3 = get_node_or_null("Objetos/Puerta3")
@onready var puerta_4 = get_node_or_null("Objetos/Puerta4")
@onready var puerta_mundo_2 = get_node_or_null("Objetos/PuertaMundo2")
@onready var puerta_mundo_2_destino = get_node_or_null("Objetos/PuertaMundo2Destino")
@onready var checkpoint_puerta: Marker2D = $Objetos/CheckpointPuerta
@onready var checkpoint_puerta_activador = $Objetos/CheckpointPuerta/Activador
@onready var altar_gafas = $Objetos/AltarGafas
@onready var checkpoint_puzzle_gafas: Marker2D = $Objetos/CheckpointPuzzleGafas
@onready var checkpoint_puzzle_gafas_activador = $Objetos/CheckpointPuzzleGafas/Activador
@onready var checkpoint_mundo_2_inicio: Marker2D = get_node_or_null("Objetos/CheckpointMundo2Inicio") as Marker2D
@onready var checkpoint_mundo_2_inicio_activador = get_node_or_null("Objetos/CheckpointMundo2Inicio/Activador")
@onready var totem_jefe_a = $Objetos/TotemJefeA
@onready var totem_jefe_b = $Objetos/TotemJefeB
@onready var totem_jefe_c = $Objetos/TotemJefeC
@onready var jugador: CharacterBody2D = $Player/Jugador
@onready var camara_1: Camera2D = $Player/Camara1
@onready var camara_2: Camera2D = $Player/Camara2
@onready var camara_3: Camera2D = $Player/Camara3
@onready var area_camara_1: Area2D = $Player/Area2D
@onready var area_camara_2: Area2D = $Player/Area2D2
@onready var area_camara_3: Area2D = $Player/Area2D3
@onready var hud = $Canvas/HUD
@onready var menu_pausa = $Canvas/MenuPausa
@onready var distorsion_overlay: ColorRect = $Canvas/DistorsionOverlay
@onready var llave = $Objetos/Llave
@onready var puzzle = $Canvas/PuzzleSecuencia
@onready var puzzle_gafas = $Canvas/PuzzleGafas
@onready var jefe_sombras = $Enemigos/JefeSombras

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
var _totems_jefe: Array = []
var _totems_activados_jefe: int = 0
var _jefe_derrotado: bool = false
var _mundo_2_desbloqueado: bool = false
var _mundo_2_alcanzado: bool = false
var _tween_puerta_jefe: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_preparar_temporizador_golpe()
	_posicion_inicial_jugador = jugador.global_position
	_posicion_respawn_actual = _posicion_inicial_jugador

	_configurar_hud()
	_configurar_jugador()
	_configurar_puertas()
	_configurar_checkpoints()
	_configurar_enemigos()
	_configurar_gafas()
	_configurar_menu_pausa()
	_preparar_canvas_runtime()
	_configurar_interactivo(llave, _on_llave_interaccion_solicitada)
	_configurar_interactivo(altar_gafas, _on_altar_gafas_interaccion_solicitada)
	_configurar_totems_jefe()
	_configurar_interactivo(puerta, _on_puerta_interaccion_solicitada)
	_configurar_puzzles()
	_estado_gafas_aplicado = false
	_aplicar_estado_gafas(false, true)
	_sincronizar_camara_con_jugador()
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

		for totem in _totems_jefe:
			if totem != null and totem.esta_en_rango():
				totem.interactuar()
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
	_sincronizar_camara_con_jugador()
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


func mundo_2_esta_desbloqueado() -> bool:
	return _mundo_2_desbloqueado


func mundo_2_esta_alcanzado() -> bool:
	return _mundo_2_alcanzado


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
	hud.show()
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

	if puerta_3 != null and puerta_4 != null and puerta_3.has_method("configurar_destino"):
		puerta_3.configurar_destino(puerta_4)

	if puerta_3 != null and puerta_3.has_signal("teletransporte_realizado"):
		puerta_3.teletransporte_realizado.connect(_on_puerta_jefe_teletransporte_realizado)

	if puerta_mundo_2 != null and puerta_mundo_2_destino != null and puerta_mundo_2.has_method("configurar_destino"):
		puerta_mundo_2.configurar_destino(puerta_mundo_2_destino)

	if puerta_mundo_2 != null and puerta_mundo_2.has_signal("teletransporte_realizado"):
		puerta_mundo_2.teletransporte_realizado.connect(_on_puerta_mundo_2_teletransporte_realizado)

	_actualizar_puerta_jefe(_puzzle_gafas_superado)
	_actualizar_puerta_mundo_2(_mundo_2_desbloqueado)


func _configurar_checkpoints() -> void:
	if checkpoint_puerta_activador != null and checkpoint_puerta_activador.has_signal("checkpoint_alcanzado"):
		checkpoint_puerta_activador.checkpoint_alcanzado.connect(_on_checkpoint_puerta_alcanzado)

	if checkpoint_puzzle_gafas_activador != null and checkpoint_puzzle_gafas_activador.has_signal("checkpoint_alcanzado"):
		checkpoint_puzzle_gafas_activador.checkpoint_alcanzado.connect(_on_checkpoint_puzzle_gafas_alcanzado)

	if checkpoint_mundo_2_inicio_activador != null and checkpoint_mundo_2_inicio_activador.has_signal("checkpoint_alcanzado"):
		checkpoint_mundo_2_inicio_activador.checkpoint_alcanzado.connect(_on_checkpoint_mundo_2_alcanzado)


func _configurar_enemigos() -> void:
	for enemigo in get_tree().get_nodes_in_group("enemigo"):
		if enemigo.has_signal("jugador_danado"):
			enemigo.jugador_danado.connect(_on_enemigo_jugador_danado)

	if jefe_sombras != null and jefe_sombras.has_signal("jefe_derrotado"):
		jefe_sombras.jefe_derrotado.connect(_on_jefe_sombras_derrotado)

	if jefe_sombras != null and jefe_sombras.has_signal("fase_cambiada"):
		jefe_sombras.fase_cambiada.connect(_on_jefe_sombras_fase_cambiada)


func _configurar_gafas() -> void:
	if distorsion_overlay != null:
		distorsion_overlay.show()
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


func _configurar_totems_jefe() -> void:
	_totems_jefe = [totem_jefe_a, totem_jefe_b, totem_jefe_c]

	for totem in _totems_jefe:
		if totem == null:
			continue

		_configurar_interactivo(totem, _on_totem_jefe_interaccion_solicitada.bind(totem))


func _configurar_puzzles() -> void:
	puzzle.show()
	puzzle.cerrar()
	puzzle_gafas.show()
	puzzle_gafas.cerrar()
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


func _on_totem_jefe_interaccion_solicitada(totem) -> void:
	if _jefe_derrotado or totem == null:
		return

	if not jugador.gafas_activas():
		hud.mostrar_mensaje(MENSAJE_TOTEM_SIN_GAFAS)
		return

	if not totem.activar():
		return

	_totems_activados_jefe += 1
	var jefe_recibio_sello := false
	if jefe_sombras != null and jefe_sombras.has_method("activar_sello"):
		jefe_sombras.activar_sello()
		jefe_recibio_sello = true

	if not jefe_recibio_sello:
		hud.mostrar_mensaje("Sello activado %d / 3. Mantente en movimiento." % _totems_activados_jefe)


func _on_puzzle_gafas_completado() -> void:
	_puzzle_gafas_superado = true
	if altar_gafas != null and altar_gafas.has_method("marcar_resuelto"):
		altar_gafas.marcar_resuelto()

	_actualizar_puerta_jefe(true, true)
	_cerrar_puzzle(MENSAJE_PUERTA_JEFE_REVELADA)


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

	_sincronizar_camara_con_jugador()
	hud.mostrar_mensaje(MENSAJE_CHECKPOINT_PUERTA_DISPONIBLE)


func _on_checkpoint_puerta_alcanzado(posicion: Vector2, _mensaje: String) -> void:
	_activar_checkpoint(posicion, MENSAJE_CHECKPOINT_GAFAS_ACTIVADO)


func _on_checkpoint_puzzle_gafas_alcanzado(posicion: Vector2, _mensaje: String) -> void:
	_activar_checkpoint(posicion, MENSAJE_PUZZLE_GAFAS_COMPLETADO)


func _on_checkpoint_mundo_2_alcanzado(posicion: Vector2, _mensaje: String) -> void:
	_mundo_2_alcanzado = true
	_activar_checkpoint(posicion, MENSAJE_CHECKPOINT_MUNDO_2_ACTIVADO)


func _on_jefe_sombras_derrotado() -> void:
	_jefe_derrotado = true
	_mundo_2_desbloqueado = true
	_actualizar_puerta_mundo_2(true)
	hud.mostrar_mensaje(MENSAJE_JEFE_DERROTADO)


func _on_jefe_sombras_fase_cambiada(fase_actual: int, sellos_activados: int) -> void:
	hud.mostrar_mensaje(_obtener_mensaje_fase_jefe(fase_actual, sellos_activados))


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


func _on_puerta_mundo_2_teletransporte_realizado(_jugador: Node2D, destino: Node2D) -> void:
	if destino == null or not destino.has_method("obtener_punto_salida"):
		return

	hud.mostrar_mensaje(MENSAJE_LLEGADA_MUNDO_2)


func _on_puerta_jefe_teletransporte_realizado(_jugador: Node2D, destino: Node2D) -> void:
	if destino == null or not destino.has_method("obtener_punto_salida"):
		return

	_sincronizar_camara_con_jugador()
	hud.mostrar_mensaje(MENSAJE_LLEGADA_ARENA_JEFE)


func _establecer_enemigos_congelados(congelados: bool) -> void:
	for enemigo in get_tree().get_nodes_in_group("enemigo"):
		if enemigo.has_method("establecer_congelado"):
			enemigo.establecer_congelado(congelados)


func _restaurar_entidades() -> void:
	for enemigo in get_tree().get_nodes_in_group("enemigo"):
		if _mundo_2_desbloqueado and enemigo == jefe_sombras:
			if enemigo.has_method("establecer_multiplicador_velocidad"):
				enemigo.establecer_multiplicador_velocidad(FACTOR_LENTITUD_GAFAS_ENEMIGOS if jugador.gafas_activas() else 1.0)
			continue

		if enemigo.has_method("reiniciar_enemigo"):
			enemigo.reiniciar_enemigo()

		if enemigo.has_method("establecer_multiplicador_velocidad"):
			enemigo.establecer_multiplicador_velocidad(FACTOR_LENTITUD_GAFAS_ENEMIGOS if jugador.gafas_activas() else 1.0)

	if _mundo_2_desbloqueado:
		_totems_activados_jefe = max(_totems_activados_jefe, 3)
		_jefe_derrotado = true
	else:
		_totems_activados_jefe = 0
		_jefe_derrotado = false
		for totem in _totems_jefe:
			if totem != null and totem.has_method("reiniciar_totem"):
				totem.reiniciar_totem()

	_actualizar_puerta_jefe(_puzzle_gafas_superado)
	_actualizar_puerta_mundo_2(_mundo_2_desbloqueado)


func _on_rango_interaccion_cambiado(activo: bool, mensaje: String) -> void:
	if _puzzle_activo or _pausa_activa:
		return

	if activo:
		hud.mostrar_mensaje(mensaje)
		return

	_restaurar_mensaje_hud()


func _restaurar_mensaje_hud() -> void:
	if _mundo_2_alcanzado:
		hud.mostrar_mensaje(MENSAJE_LLEGADA_MUNDO_2)
		return

	if _mundo_2_desbloqueado:
		hud.mostrar_mensaje(MENSAJE_JEFE_DERROTADO)
		return

	if _jefe_derrotado:
		hud.mostrar_mensaje(MENSAJE_JEFE_DERROTADO)
		return

	if _puzzle_gafas_superado:
		hud.mostrar_mensaje("Reto de gafas superado. La puerta a la arena del jefe ya esta abierta.")
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


func _actualizar_puerta_mundo_2(activa: bool) -> void:
	if puerta_mundo_2 == null:
		return

	puerta_mundo_2.visible = activa
	puerta_mundo_2.monitoring = activa
	puerta_mundo_2.monitorable = activa

	if activa:
		if puerta_mundo_2.has_method("abrir"):
			puerta_mundo_2.abrir()
		elif puerta_mundo_2.has_method("establecer_transporte_habilitado"):
			puerta_mundo_2.establecer_transporte_habilitado(true)
		return

	if puerta_mundo_2.has_method("establecer_transporte_habilitado"):
		puerta_mundo_2.establecer_transporte_habilitado(false)


func _actualizar_puerta_jefe(activa: bool, animar: bool = false) -> void:
	if puerta_3 == null:
		return

	if _tween_puerta_jefe != null and _tween_puerta_jefe.is_valid():
		_tween_puerta_jefe.kill()

	if not activa:
		puerta_3.visible = false
		puerta_3.monitoring = false
		puerta_3.monitorable = false
		puerta_3.modulate = Color(1, 1, 1, 0)
		if puerta_3.has_method("establecer_transporte_habilitado"):
			puerta_3.establecer_transporte_habilitado(false)
		return

	puerta_3.visible = true
	puerta_3.monitoring = false
	puerta_3.monitorable = false

	if animar:
		puerta_3.modulate = Color(1, 1, 1, 0)
		_tween_puerta_jefe = create_tween()
		_tween_puerta_jefe.set_ignore_time_scale(true)
		_tween_puerta_jefe.set_trans(Tween.TRANS_SINE)
		_tween_puerta_jefe.set_ease(Tween.EASE_OUT)
		_tween_puerta_jefe.tween_property(puerta_3, "modulate", Color(1, 1, 1, 1), 0.55)
		_tween_puerta_jefe.finished.connect(_habilitar_puerta_jefe.bind(true), CONNECT_ONE_SHOT)
		return

	puerta_3.modulate = Color(1, 1, 1, 1)
	_habilitar_puerta_jefe()


func _habilitar_puerta_jefe(_desde_animacion: bool = false) -> void:
	if puerta_3 == null:
		return

	if puerta_3.has_method("abrir"):
		puerta_3.abrir()
	elif puerta_3.has_method("establecer_transporte_habilitado"):
		puerta_3.establecer_transporte_habilitado(true)

	puerta_3.monitoring = true
	puerta_3.monitorable = true


func _obtener_mensaje_fase_jefe(fase_actual: int, sellos_activados: int) -> String:
	match fase_actual:
		2:
			return "Sello %d / 3. Fase 2: el jefe prepara embestidas. Lee la carga y esquiva." % sellos_activados
		3:
			return "Sello %d / 3. Fase 3: la arena se acelera. Usa las gafas y remata el ultimo totem." % sellos_activados
		_:
			return "Sello %d / 3. Mantente en movimiento." % sellos_activados


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

	if camara_3 != null:
		_tween_transicion_gafas.tween_property(camara_3, "zoom", zoom_objetivo, duracion_transicion_gafas)

	if distorsion_overlay != null:
		var color_objetivo := distorsion_overlay.color
		color_objetivo.a = alpha_objetivo
		_tween_transicion_gafas.tween_property(distorsion_overlay, "color", color_objetivo, duracion_transicion_gafas)


func _aplicar_zoom_camaras(zoom_objetivo: Vector2) -> void:
	if camara_1 != null:
		camara_1.zoom = zoom_objetivo

	if camara_2 != null:
		camara_2.zoom = zoom_objetivo

	if camara_3 != null:
		camara_3.zoom = zoom_objetivo


func _sincronizar_camara_con_jugador() -> void:
	if jugador == null:
		return

	var camara_objetivo: Camera2D = camara_1
	if _area_contiene_posicion(area_camara_3, jugador.global_position):
		camara_objetivo = camara_3
	elif _area_contiene_posicion(area_camara_2, jugador.global_position):
		camara_objetivo = camara_2
	elif _area_contiene_posicion(area_camara_1, jugador.global_position):
		camara_objetivo = camara_1

	_activar_camara(camara_objetivo)


func _activar_camara(camara_objetivo: Camera2D) -> void:
	if camara_objetivo == null:
		return

	for camara in [camara_1, camara_2, camara_3]:
		if camara == null:
			continue
		camara.enabled = camara == camara_objetivo

	camara_objetivo.make_current()


func _area_contiene_posicion(area: Area2D, posicion_global: Vector2) -> bool:
	if area == null:
		return false

	for child in area.get_children():
		if child is CollisionShape2D and _shape_contiene_posicion(child as CollisionShape2D, posicion_global):
			return true

	return false


func _shape_contiene_posicion(shape_node: CollisionShape2D, posicion_global: Vector2) -> bool:
	if shape_node == null or shape_node.shape == null or shape_node.disabled:
		return false

	var posicion_local := shape_node.global_transform.affine_inverse() * posicion_global
	if shape_node.shape is RectangleShape2D:
		var rectangulo := shape_node.shape as RectangleShape2D
		var mitad := rectangulo.size * 0.5
		return absf(posicion_local.x) <= mitad.x and absf(posicion_local.y) <= mitad.y

	if shape_node.shape is CircleShape2D:
		var circulo := shape_node.shape as CircleShape2D
		return posicion_local.length() <= circulo.radius

	return false


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


func _preparar_canvas_runtime() -> void:
	if menu_pausa != null:
		menu_pausa.hide()


func _exit_tree() -> void:
	_restaurar_tiempo_normal()
