extends Node2D
class_name MainGame

const SistemaGuardadoClass = preload("res://Scripts/sistema_guardado.gd")
const MENU_SCENE := "res://Escenas/Menu.tscn"
const SCENE_PATH := "res://Escenas/MainGame.tscn"
const MENSAJE_PUERTA_CERRADA := "La puerta sigue cerrada. Resuelve el puzzle de la llave."
const MENSAJE_NIVEL_COMPLETO := "La puerta se abrio. El nivel base ya esta completo."
const MENSAJE_CHECKPOINT_ACTIVADO := "Checkpoint activado. Si caes, volveras despues de la puerta."
const MENSAJE_CHECKPOINT_PUERTA_DISPONIBLE := "Nueva zona alcanzada. Pisa el punto verde para guardar tu avance."
const MENSAJE_CHECKPOINT_GAFAS_ACTIVADO := "Checkpoint activado. Activa las gafas para revelar el parkour oculto."
const MENSAJE_CHECKPOINT_PRE_PARKOUR_ACTIVADO := "Checkpoint activado. El parkour oculto empieza adelante. Usa las gafas con cuidado."
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
const INTERVALO_PENSAMIENTOS := 20.0
const PENSAMIENTOS_OSCUROS := [
	"Otra vez se rien. Mejor camino rapido y no miro a nadie.",
	"Si notan las gafas, van a empezar de nuevo.",
	"No quiero escuchar mi nombre en sus bocas.",
	"Tal vez si paso sin hacer ruido, no me ven.",
	"Me dijeron cuatro ojos otra vez. Como si eso fuera todo lo que soy.",
	"Cada pasillo suena como una burla antes de que pase.",
	"Las gafas pesan mas cuando todos las miran.",
	"Ojala pudiera esconderme detras del marco.",
	"No son solo lentes. A veces se sienten como una marca.",
	"Respira. Solo llega al otro lado.",
]
const PENSAMIENTOS_GAFAS := [
	"Quizas no es tan malo como parece.",
	"Al final el mundo no se ve tan mal.",
	"Con las gafas puestas, algo por fin encaja.",
	"Ver distinto no significa estar mal.",
	"Mis gafas no me hacen menos.",
	"Hay caminos que solo yo podia ver.",
	"Quizas esta claridad tambien es mia.",
]
const PENSAMIENTO_ZONA_JEFE := "La mente es como un slime, moldeable."
const PENSAMIENTO_JEFE_DERROTADO := "Pude moldear mi mente."
const PENSAMIENTO_NPCS_MOLESTIA := "Esos chicos siempre me molestan. Estoy harto, quiero irme lejos."
const PENSAMIENTO_NPCS_PATIO := "Voy a tomar un pequeño descanso en el patio."
const PENSAMIENTO_NPC_VALOR := "Ojala algun dia saque el valor para decirles como me siento."
const PENSAMIENTO_PATIO_DIFERENTE := "Wow el patio se ve diferente."

@export var limite_caida_y: float = 700.0
@export var escala_tiempo_golpe: float = 0.45
@export var duracion_golpe_lento: float = 0.1
@export var desplazamiento_checkpoint_puerta: Vector2 = Vector2(72, 0)
@export var zoom_base_mundo: Vector2 = Vector2(2.15, 2.15)
@export var zoom_con_gafas: Vector2 = Vector2(1.75, 1.75)
@export_group("Distorsion")
@export var alpha_distorsion_base: float = 0.72
@export var alpha_distorsion_jefe: float = 0.86
@export var alpha_distorsion_gafas: float = 0.0
@export var alpha_distorsion_extra_por_fase_jefe: float = 0.03
@export var duracion_transicion_gafas: float = 0.22
@export var duracion_transicion_gafas_en_jefe: float = 0.1
@export var duracion_transicion_distorsion_jefe: float = 0.35
@export var vignette_radius_base: float = 0.43
@export var vignette_radius_jefe: float = 0.35
@export var vignette_softness_base: float = 0.34
@export var vignette_softness_jefe: float = 0.25
@export var blur_strength_base: float = 4.2
@export var blur_strength_jefe: float = 5.2
@export var edge_darkness_base: float = 0.82
@export var edge_darkness_jefe: float = 0.93
@export var tint_strength_base: float = 0.22
@export var tint_strength_jefe: float = 0.3
@export var edge_desaturation_base: float = 0.34
@export var edge_desaturation_jefe: float = 0.46
@export var aberration_strength_base: float = 1.35
@export var aberration_strength_jefe: float = 2.2
@export var pulse_strength_base: float = 0.018
@export var pulse_strength_jefe: float = 0.042
@export var pulse_speed_base: float = 0.75
@export var pulse_speed_jefe: float = 1.55
@export var blur_extra_por_fase_jefe: float = 0.45
@export var edge_darkness_extra_por_fase_jefe: float = 0.02
@export var aberration_extra_por_fase_jefe: float = 0.28
@export var pulse_strength_extra_por_fase_jefe: float = 0.012
@export var pulse_speed_extra_por_fase_jefe: float = 0.18

@onready var tile_map: TileMapLayer = $Mapa/TileMapLayer
@onready var puerta = _obtener_nodo_primero(["Objetos/Puerta", "Objetos/Puerta1"])
@onready var puerta_salida = get_node_or_null("Objetos/Puerta2")
@onready var puerta_3 = get_node_or_null("Objetos/PuertaJefe")
@onready var puerta_4 = get_node_or_null("Objetos/PuertaJefeDestino")
@onready var puerta_7 = get_node_or_null("Objetos/Puerta7")
@onready var puerta_8 = get_node_or_null("Objetos/Puerta8")
@onready var puerta_mundo_2 = get_node_or_null("Objetos/PuertaMundo2")
@onready var puerta_mundo_2_destino = get_node_or_null("Objetos/PuertaMundo2Destino")
@onready var checkpoint_puerta: Marker2D = $Objetos/CheckpointPuerta
@onready var checkpoint_puerta_activador = $Objetos/CheckpointPuerta/Activador
@onready var checkpoint_pre_parkour: Marker2D = get_node_or_null("Objetos/CheckpointPreParkour") as Marker2D
@onready var checkpoint_pre_parkour_activador = get_node_or_null("Objetos/CheckpointPreParkour/Activador")
@onready var altar_gafas = $Objetos/AltarGafas
@onready var checkpoint_puzzle_gafas: Marker2D = $Objetos/CheckpointPuzzleGafas
@onready var checkpoint_puzzle_gafas_activador = $Objetos/CheckpointPuzzleGafas/Activador
@onready var checkpoint_mundo_2_inicio: Marker2D = get_node_or_null("Objetos/CheckpointMundo2Inicio") as Marker2D
@onready var checkpoint_mundo_2_inicio_activador = get_node_or_null("Objetos/CheckpointMundo2Inicio/Activador")
@onready var punto_salon_npc_2: Marker2D = get_node_or_null("Objetos/PuntoSalonNPC2") as Marker2D
@onready var punto_regreso_npc_2: Marker2D = get_node_or_null("Objetos/PuntoRegresoNPC2") as Marker2D
@onready var totem_jefe_a = $Objetos/TotemJefeA
@onready var totem_jefe_b = $Objetos/TotemJefeB
@onready var totem_jefe_c = $Objetos/TotemJefeC
@onready var jugador: CharacterBody2D = $Player/Jugador
@onready var camara_1: Camera2D = $Player/Camara1
@onready var camara_2: Camera2D = $Player/Camara2
@onready var camara_3: Camera2D = get_node_or_null("Player/Camara3") as Camera2D
@onready var area_camara_1: Area2D = $Player/Area2D
@onready var area_camara_2: Area2D = $Player/Area2D2
@onready var area_camara_3: Area2D = get_node_or_null("Player/Area2D3") as Area2D
@onready var hud = $Canvas/HUD
@onready var menu_pausa = $Canvas/MenuPausa
@onready var distorsion_overlay: ColorRect = $Canvas/DistorsionOverlay
@onready var distorsion_material: ShaderMaterial = distorsion_overlay.material as ShaderMaterial if distorsion_overlay != null else null
@onready var intro_canvas: CanvasLayer = get_node_or_null("IntroCanvas") as CanvasLayer
@onready var intro_video: VideoStreamPlayer = get_node_or_null("IntroCanvas/IntroVideo") as VideoStreamPlayer
@onready var llave = $Objetos/Llave
@onready var puzzle_salon_npc_2 = get_node_or_null("Objetos/PuzzleSalonNPC2")
@onready var puzzle = $Canvas/PuzzleSecuencia
@onready var puzzle_gafas = $Canvas/PuzzleGafas
@onready var npc_2: NPCDialogo = get_node_or_null("NPC/NPC_2") as NPCDialogo
@onready var npc_3: NPCDialogo = get_node_or_null("NPC/NPC_3") as NPCDialogo
@onready var npc_4: NPCDialogo = get_node_or_null("NPC/NPC_4") as NPCDialogo
@onready var npc_5: NPCDialogo = get_node_or_null("NPC/NPC_5") as NPCDialogo
@onready var jefe_sombras = get_node_or_null("Enemigos/JefeSombras")
@onready var ambiente_mundo_1 = get_node_or_null("AmbienteMundo1")

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
var _tween_alpha_distorsion: Tween
var _jugador_en_zona_jefe: bool = false
var _respawn_muerte_activo: bool = false
var _temporizador_pensamientos: Timer
var _indice_pensamiento: int = 0
var _indice_pensamiento_gafas: int = 0
var _pensamiento_jefe_mostrado: bool = false
var _transicionando_a_mundo_2: bool = false
var _intro_activa: bool = false
var _teletransporte_salon_npc_2_realizado: bool = false
var _puzzle_salon_npc_2_resuelto: bool = false
var _npcs_post_puzzle_dialogados := {}
var _pensamiento_patio_mostrado: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_preparar_temporizador_golpe()
	_posicion_inicial_jugador = jugador.global_position
	_posicion_respawn_actual = _posicion_inicial_jugador

	_configurar_hud()
	_configurar_pensamientos()
	_configurar_jugador()
	_configurar_puertas()
	_configurar_checkpoints()
	_configurar_enemigos()
	_configurar_gafas()
	_configurar_menu_pausa()
	_configurar_intro_video()
	_configurar_npcs()
	_preparar_canvas_runtime()
	_configurar_interactivo(llave, _on_llave_interaccion_solicitada)
	_configurar_interactivo(puzzle_salon_npc_2, _on_puzzle_salon_npc_2_interaccion_solicitada)
	_configurar_interactivo(altar_gafas, _on_altar_gafas_interaccion_solicitada)
	_configurar_totems_jefe()
	_configurar_interactivo(puerta, _on_puerta_interaccion_solicitada)
	_configurar_puzzles()
	_cargar_progreso_guardado()
	_estado_gafas_aplicado = false
	_actualizar_estado_zona_jefe(true)
	_aplicar_estado_gafas(false, true)
	_actualizar_ambiente_sonoro()
	_sincronizar_camara_con_jugador()
	_restaurar_mensaje_hud()
	if SistemaGuardadoClass.consumir_intro_nueva_partida():
		call_deferred("_reproducir_intro_video")


func _physics_process(_delta: float) -> void:
	if _intro_activa:
		return

	if _pausa_activa:
		return

	_actualizar_estado_zona_jefe()

	if jugador.global_position.y > limite_caida_y:
		reiniciar_nivel()


func _unhandled_input(event: InputEvent) -> void:
	if _intro_activa:
		get_viewport().set_input_as_handled()
		return

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

		if puzzle_salon_npc_2 != null and puzzle_salon_npc_2.has_method("esta_en_rango") and puzzle_salon_npc_2.esta_en_rango():
			puzzle_salon_npc_2.interactuar()
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
			return

		if _interactuar_con_npc_en_rango():
			return


func reiniciar_nivel() -> void:
	cerrar_menu_pausa()
	_restaurar_tiempo_normal()
	_cerrar_puzzle_si_esta_abierto()
	_restaurar_entidades()
	jugador.restaurar_para_respawn(_posicion_respawn_actual)
	_actualizar_estado_zona_jefe(true)
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


func _obtener_nodo_primero(rutas: Array[String]) -> Node:
	for ruta in rutas:
		var nodo := get_node_or_null(ruta)
		if nodo != null:
			return nodo

	return null


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


func _configurar_pensamientos() -> void:
	_temporizador_pensamientos = Timer.new()
	_temporizador_pensamientos.wait_time = INTERVALO_PENSAMIENTOS
	_temporizador_pensamientos.one_shot = false
	_temporizador_pensamientos.timeout.connect(_on_temporizador_pensamientos_timeout)
	add_child(_temporizador_pensamientos)
	_temporizador_pensamientos.start()


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

	if puerta_7 != null and puerta_7.has_signal("teletransporte_realizado"):
		puerta_7.teletransporte_realizado.connect(_on_puerta_7_teletransporte_realizado)

	if puerta_mundo_2 != null and puerta_mundo_2_destino != null and puerta_mundo_2.has_method("configurar_destino"):
		puerta_mundo_2.configurar_destino(puerta_mundo_2_destino)

	if puerta_mundo_2 != null and puerta_mundo_2.has_signal("teletransporte_realizado"):
		puerta_mundo_2.teletransporte_realizado.connect(_on_puerta_mundo_2_teletransporte_realizado)

	_actualizar_puerta_jefe(_puzzle_gafas_superado)
	_actualizar_puerta_mundo_2(_mundo_2_desbloqueado)


func _configurar_checkpoints() -> void:
	if checkpoint_puerta_activador != null and checkpoint_puerta_activador.has_signal("checkpoint_alcanzado"):
		checkpoint_puerta_activador.checkpoint_alcanzado.connect(_on_checkpoint_puerta_alcanzado)

	if checkpoint_pre_parkour_activador != null and checkpoint_pre_parkour_activador.has_signal("checkpoint_alcanzado"):
		checkpoint_pre_parkour_activador.checkpoint_alcanzado.connect(_on_checkpoint_pre_parkour_alcanzado)

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

	_actualizar_actividad_jefe()


func _configurar_gafas() -> void:
	if distorsion_overlay != null:
		if distorsion_overlay.material is ShaderMaterial:
			distorsion_material = (distorsion_overlay.material as ShaderMaterial).duplicate()
			distorsion_material.resource_local_to_scene = true
			distorsion_overlay.material = distorsion_material

		distorsion_overlay.show()
		var color_base := distorsion_overlay.color
		color_base.a = _obtener_alpha_distorsion_objetivo(false)
		distorsion_overlay.color = color_base

	_aplicar_perfil_distorsion(true)


func _configurar_menu_pausa() -> void:
	menu_pausa.continuar_solicitado.connect(cerrar_menu_pausa)
	menu_pausa.reiniciar_solicitado.connect(reiniciar_nivel)
	menu_pausa.volver_menu_solicitado.connect(volver_al_menu)


func _configurar_intro_video() -> void:
	if intro_canvas == null or intro_video == null:
		return

	intro_canvas.hide()
	if not intro_video.finished.is_connected(_on_intro_video_finished):
		intro_video.finished.connect(_on_intro_video_finished)


func _configurar_npcs() -> void:
	if npc_2 == null:
		_establecer_npcs_post_puzzle_disponibles(false)
		return

	if not npc_2.dialogo_finalizado.is_connected(_on_npc_2_dialogo_finalizado):
		npc_2.dialogo_finalizado.connect(_on_npc_2_dialogo_finalizado)

	_conectar_pensamiento_npc_post_puzzle(npc_3, &"npc_3")
	_conectar_pensamiento_npc_post_puzzle(npc_4, &"npc_4")
	_conectar_pensamiento_npc_post_puzzle(npc_5, &"npc_5")
	_establecer_npcs_post_puzzle_disponibles(false)


func _conectar_pensamiento_npc_post_puzzle(npc: NPCDialogo, id_npc: StringName) -> void:
	if npc == null:
		return

	var callback := _on_npc_post_puzzle_dialogo_finalizado.bind(id_npc)
	if not npc.dialogo_finalizado.is_connected(callback):
		npc.dialogo_finalizado.connect(callback)


func _establecer_npcs_post_puzzle_disponibles(disponibles: bool) -> void:
	_establecer_npc_disponible(npc_3, disponibles)
	_establecer_npc_disponible(npc_4, disponibles)
	_establecer_npc_disponible(npc_5, disponibles)


func _establecer_npc_disponible(npc: NPCDialogo, disponible: bool) -> void:
	if npc == null:
		return

	npc.visible = disponible
	npc.monitoring = disponible
	npc.monitorable = disponible
	if not disponible and npc.has_method("_cambiar_rango_interaccion"):
		npc._cambiar_rango_interaccion(false)
	elif disponible and npc.activar_automaticamente:
		call_deferred("_intentar_dialogo_automatico_npc", npc)


func _intentar_dialogo_automatico_npc(npc: NPCDialogo) -> void:
	if npc == null or not is_instance_valid(npc):
		return

	if npc.esta_en_rango():
		npc.interactuar()


func _reproducir_intro_video() -> void:
	if intro_canvas == null or intro_video == null or intro_video.stream == null:
		_reproducir_intro_nueva_partida()
		return

	_intro_activa = true
	jugador.velocity = Vector2.ZERO
	jugador.establecer_control_habilitado(false)
	_establecer_enemigos_congelados(true)
	intro_canvas.show()
	intro_video.play()


func _finalizar_intro_video() -> void:
	if not _intro_activa:
		return

	_intro_activa = false
	if intro_video != null:
		intro_video.stop()
	if intro_canvas != null:
		intro_canvas.hide()
	if not _pausa_activa and not _puzzle_activo:
		jugador.establecer_control_habilitado(true)
	_establecer_enemigos_congelados(_pausa_activa or _puzzle_activo)
	_restaurar_mensaje_hud()


func _on_intro_video_finished() -> void:
	_finalizar_intro_video()


func _configurar_interactivo(interactivo: Node, callback: Callable) -> void:
	if interactivo == null:
		return

	interactivo.interaccion_solicitada.connect(callback)
	interactivo.rango_interaccion_cambiado.connect(_on_rango_interaccion_cambiado)


func _interactuar_con_npc_en_rango() -> bool:
	for npc in get_tree().get_nodes_in_group("npc"):
		if npc.has_method("esta_en_rango") and npc.has_method("interactuar") and npc.esta_en_rango():
			npc.interactuar()
			return true

	return false


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


func _on_puzzle_salon_npc_2_interaccion_solicitada() -> void:
	if _puzzle_salon_npc_2_resuelto or _puzzle_activo:
		return

	_puzzle_activo = true
	_tipo_puzzle_activo = &"salon_npc_2"
	jugador.establecer_control_habilitado(false)
	_establecer_enemigos_congelados(true)
	hud.mostrar_mensaje("El cubo del salon responde. Resuelve la secuencia para volver.")
	puzzle.iniciar_puzzle()


func _on_puzzle_completado() -> void:
	if _tipo_puzzle_activo == &"salon_npc_2":
		_on_puzzle_salon_npc_2_completado()
		return

	_llave_obtenida = true
	hud.actualizar_llave(_llave_obtenida)
	llave.otorgar_llave()
	_guardar_progreso_actual()
	_cerrar_puzzle("Has obtenido la llave. Ahora vuelve a la puerta y presiona E.")


func _on_puzzle_cancelado() -> void:
	if _tipo_puzzle_activo == &"salon_npc_2":
		_cerrar_puzzle("El cubo espera en silencio. Puedes reintentarlo cuando quieras.")
		return

	_cerrar_puzzle("Saliste del puzzle. Puedes volver a intentarlo cuando quieras.")


func _on_puzzle_salon_npc_2_completado() -> void:
	_puzzle_salon_npc_2_resuelto = true
	if puzzle_salon_npc_2 != null and puzzle_salon_npc_2.has_method("desactivar_interaccion"):
		puzzle_salon_npc_2.desactivar_interaccion()

	_desaparecer_npc_2()
	_establecer_npcs_post_puzzle_disponibles(true)
	_cerrar_puzzle("La secuencia se resolvio. Volviendo al pasillo.")
	call_deferred("_teletransportar_jugador_desde_salon_npc_2")


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
	_guardar_progreso_actual()
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
	_guardar_progreso_actual()
	hud.mostrar_mensaje(MENSAJE_NIVEL_COMPLETO)


func _on_puerta_teletransporte_realizado(_jugador: Node2D, destino: Node2D) -> void:
	if destino == null or not destino.has_method("obtener_punto_salida"):
		return

	_actualizar_estado_zona_jefe(true)
	_sincronizar_camara_con_jugador()
	hud.mostrar_mensaje(MENSAJE_CHECKPOINT_PUERTA_DISPONIBLE)


func _on_puerta_7_teletransporte_realizado(_jugador: Node2D, destino: Node2D) -> void:
	if _pensamiento_patio_mostrado or destino != puerta_8:
		return

	_pensamiento_patio_mostrado = true
	_mostrar_pensamiento_interno(PENSAMIENTO_PATIO_DIFERENTE)


func _on_checkpoint_puerta_alcanzado(posicion: Vector2, _mensaje: String) -> void:
	_activar_checkpoint(posicion, MENSAJE_CHECKPOINT_GAFAS_ACTIVADO)


func _on_checkpoint_pre_parkour_alcanzado(posicion: Vector2, _mensaje: String) -> void:
	_activar_checkpoint(posicion, MENSAJE_CHECKPOINT_PRE_PARKOUR_ACTIVADO)


func _on_checkpoint_puzzle_gafas_alcanzado(posicion: Vector2, _mensaje: String) -> void:
	_activar_checkpoint(posicion, MENSAJE_PUZZLE_GAFAS_COMPLETADO)


func _on_checkpoint_mundo_2_alcanzado(posicion: Vector2, _mensaje: String) -> void:
	_mundo_2_alcanzado = true
	_activar_checkpoint(posicion, MENSAJE_CHECKPOINT_MUNDO_2_ACTIVADO)


func _on_npc_2_dialogo_finalizado(_nombre: String) -> void:
	if _teletransporte_salon_npc_2_realizado:
		return

	_teletransporte_salon_npc_2_realizado = true
	call_deferred("_teletransportar_jugador_a_salon_npc_2")


func _on_npc_post_puzzle_dialogo_finalizado(_nombre: String, id_npc: StringName) -> void:
	if not _puzzle_salon_npc_2_resuelto or _npcs_post_puzzle_dialogados.has(id_npc):
		return

	_npcs_post_puzzle_dialogados[id_npc] = true
	if id_npc == &"npc_5":
		_mostrar_pensamiento_interno(PENSAMIENTO_NPC_VALOR)
		return

	var dialogos_burla := (1 if _npcs_post_puzzle_dialogados.has(&"npc_3") else 0) + (1 if _npcs_post_puzzle_dialogados.has(&"npc_4") else 0)
	if dialogos_burla == 1:
		_mostrar_pensamiento_interno(PENSAMIENTO_NPCS_MOLESTIA)
	elif dialogos_burla == 2:
		_mostrar_pensamiento_interno(PENSAMIENTO_NPCS_PATIO)


func _mostrar_pensamiento_interno(texto: String) -> void:
	if hud == null or not hud.has_method("mostrar_pensamiento"):
		return

	hud.mostrar_pensamiento(texto)
	if _temporizador_pensamientos != null:
		_temporizador_pensamientos.start(INTERVALO_PENSAMIENTOS)


func _teletransportar_jugador_a_salon_npc_2() -> void:
	if jugador == null:
		return

	var destino := punto_salon_npc_2.global_position if punto_salon_npc_2 != null else Vector2(1399, -1900)
	jugador.global_position = destino
	jugador.velocity = Vector2.ZERO
	if jugador.has_method("establecer_control_habilitado"):
		jugador.establecer_control_habilitado(true)

	_actualizar_estado_zona_jefe(true)
	_sincronizar_camara_con_jugador()


func _teletransportar_jugador_desde_salon_npc_2() -> void:
	if jugador == null:
		return

	var destino := punto_regreso_npc_2.global_position if punto_regreso_npc_2 != null else Vector2(1399, -1538)
	jugador.global_position = destino
	jugador.velocity = Vector2.ZERO
	if jugador.has_method("establecer_control_habilitado"):
		jugador.establecer_control_habilitado(true)

	_actualizar_estado_zona_jefe(true)
	_sincronizar_camara_con_jugador()


func _desaparecer_npc_2() -> void:
	if npc_2 == null or not is_instance_valid(npc_2):
		return

	if npc_2.has_method("desactivar_interaccion"):
		npc_2.desactivar_interaccion()
	npc_2.hide()
	npc_2.queue_free()
	npc_2 = null


func _on_jefe_sombras_derrotado() -> void:
	_jefe_derrotado = true
	_mundo_2_desbloqueado = true
	_actualizar_actividad_jefe()
	_actualizar_puerta_mundo_2(true)
	_aplicar_alpha_distorsion_actual(false)
	_aplicar_perfil_distorsion(true)
	_guardar_progreso_actual()
	hud.mostrar_mensaje(MENSAJE_JEFE_DERROTADO)
	if hud != null and hud.has_method("mostrar_pensamiento"):
		hud.mostrar_pensamiento(PENSAMIENTO_JEFE_DERROTADO, true)


func _on_jefe_sombras_fase_cambiada(fase_actual: int, sellos_activados: int) -> void:
	_aplicar_alpha_distorsion_actual(false)
	_aplicar_perfil_distorsion(true)
	hud.mostrar_mensaje(_obtener_mensaje_fase_jefe(fase_actual, sellos_activados))


func _activar_checkpoint(posicion: Vector2, mensaje: String = MENSAJE_CHECKPOINT_ACTIVADO) -> void:
	_establecer_checkpoint(posicion)
	hud.actualizar_checkpoint(_checkpoint_activo)
	_guardar_progreso_actual()
	hud.mostrar_mensaje(mensaje)


func _on_jugador_vida_cambiada(vida_actual: int) -> void:
	if vida_actual > 0:
		return

	if _respawn_muerte_activo:
		return

	hud.mostrar_mensaje("La sombra te vencio. Regresando al ultimo checkpoint.")
	call_deferred("_reaparecer_tras_muerte")


func _reaparecer_tras_muerte() -> void:
	if _respawn_muerte_activo:
		return

	_respawn_muerte_activo = true
	_restaurar_tiempo_normal()
	_establecer_enemigos_congelados(true)
	if jugador != null and jugador.has_method("reproducir_muerte"):
		await jugador.reproducir_muerte()

	reiniciar_nivel()
	_establecer_enemigos_congelados(_puzzle_activo or _pausa_activa)
	_respawn_muerte_activo = false


func _on_enemigo_jugador_danado(_cantidad: int) -> void:
	if _respawn_muerte_activo:
		return

	if not _puzzle_activo:
		hud.mostrar_mensaje("Una sombra te alcanzo. Mantente en movimiento.")


func _on_jugador_dano_recibido(_cantidad: int, _direccion: float) -> void:
	_aplicar_golpe_lento()


func _on_jugador_gafas_actualizadas(activa: bool, _duracion_restante: float, _cooldown_restante: float, _cooldown_actual: float, _siguiente_cooldown: float) -> void:
	if activa == _estado_gafas_aplicado:
		_aplicar_alpha_distorsion_actual(false)
		_aplicar_perfil_distorsion(false)
		return

	_aplicar_estado_gafas(activa)
	if activa:
		_mostrar_pensamiento_gafas()


func _on_puerta_mundo_2_teletransporte_realizado(_jugador: Node2D, destino: Node2D) -> void:
	_transicionando_a_mundo_2 = true
	_mundo_2_alcanzado = true
	if destino == null or not destino.has_method("obtener_punto_salida"):
		return

	_actualizar_estado_zona_jefe(true)
	hud.mostrar_mensaje(MENSAJE_LLEGADA_MUNDO_2)


func _on_puerta_jefe_teletransporte_realizado(_jugador: Node2D, destino: Node2D) -> void:
	if destino == null or not destino.has_method("obtener_punto_salida"):
		return

	_jugador_en_zona_jefe = true
	_actualizar_actividad_jefe()
	_aplicar_alpha_distorsion_actual(true)
	_aplicar_perfil_distorsion(true)
	_sincronizar_camara_con_jugador()
	_mostrar_pensamiento_zona_jefe()
	hud.mostrar_mensaje(MENSAJE_LLEGADA_ARENA_JEFE)


func _establecer_enemigos_congelados(congelados: bool) -> void:
	for enemigo in get_tree().get_nodes_in_group("enemigo"):
		if enemigo.has_method("establecer_congelado"):
			enemigo.establecer_congelado(congelados)


func _on_temporizador_pensamientos_timeout() -> void:
	if _puzzle_activo or _pausa_activa or _respawn_muerte_activo:
		return

	if hud != null and hud.has_method("mostrar_pensamiento"):
		hud.mostrar_pensamiento(_obtener_pensamiento_siguiente())


func _obtener_pensamiento_siguiente() -> String:
	if PENSAMIENTOS_OSCUROS.is_empty():
		return ""

	var mensaje: String = PENSAMIENTOS_OSCUROS[_indice_pensamiento % PENSAMIENTOS_OSCUROS.size()]
	_indice_pensamiento += 1
	return mensaje


func _mostrar_pensamiento_gafas() -> void:
	if PENSAMIENTOS_GAFAS.is_empty() or hud == null or not hud.has_method("mostrar_pensamiento"):
		return

	var mensaje: String = PENSAMIENTOS_GAFAS[_indice_pensamiento_gafas % PENSAMIENTOS_GAFAS.size()]
	_indice_pensamiento_gafas += 1
	hud.mostrar_pensamiento(mensaje, true)
	if _temporizador_pensamientos != null:
		_temporizador_pensamientos.start(INTERVALO_PENSAMIENTOS)


func _mostrar_pensamiento_zona_jefe() -> void:
	if _pensamiento_jefe_mostrado or hud == null or not hud.has_method("mostrar_pensamiento"):
		return

	_pensamiento_jefe_mostrado = true
	hud.mostrar_pensamiento(PENSAMIENTO_ZONA_JEFE, true)


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


func _actualizar_puerta_mundo_2(activa: bool, silencioso: bool = false) -> void:
	if puerta_mundo_2 == null:
		return

	puerta_mundo_2.visible = activa
	puerta_mundo_2.monitoring = activa
	puerta_mundo_2.monitorable = activa

	if activa:
		if puerta_mundo_2.has_method("abrir"):
			puerta_mundo_2.abrir(silencioso)
		elif puerta_mundo_2.has_method("establecer_transporte_habilitado"):
			puerta_mundo_2.establecer_transporte_habilitado(true)
		return

	if puerta_mundo_2.has_method("establecer_transporte_habilitado"):
		puerta_mundo_2.establecer_transporte_habilitado(false)


func _actualizar_puerta_jefe(activa: bool, animar: bool = false, silencioso: bool = false) -> void:
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
	_habilitar_puerta_jefe(false, silencioso)


func _habilitar_puerta_jefe(_desde_animacion: bool = false, silencioso: bool = false) -> void:
	if puerta_3 == null:
		return

	if puerta_3.has_method("abrir"):
		puerta_3.abrir(silencioso and not _desde_animacion)
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
	var alpha_objetivo := _obtener_alpha_distorsion_objetivo(activa)
	var duracion_transicion_actual := duracion_transicion_gafas
	if _jugador_en_zona_jefe and not activa:
		duracion_transicion_actual = min(duracion_transicion_gafas_en_jefe, duracion_transicion_gafas)

	if _tween_alpha_distorsion != null and _tween_alpha_distorsion.is_valid():
		_tween_alpha_distorsion.kill()

	if instantaneo:
		_aplicar_zoom_camaras(zoom_objetivo)
		_aplicar_perfil_distorsion(true)
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
		_tween_transicion_gafas.tween_property(camara_1, "zoom", zoom_objetivo, duracion_transicion_actual)

	if camara_2 != null:
		_tween_transicion_gafas.tween_property(camara_2, "zoom", zoom_objetivo, duracion_transicion_actual)

	if camara_3 != null:
		_tween_transicion_gafas.tween_property(camara_3, "zoom", zoom_objetivo, duracion_transicion_actual)

	if distorsion_overlay != null:
		var color_objetivo := distorsion_overlay.color
		color_objetivo.a = alpha_objetivo
		_tween_transicion_gafas.tween_property(distorsion_overlay, "color", color_objetivo, duracion_transicion_actual)

	_aplicar_perfil_distorsion(false)


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
	if _jugador_en_zona_jefe:
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


func _actualizar_estado_zona_jefe(forzar: bool = false) -> void:
	if jugador == null:
		return

	var estaba_en_zona := _jugador_en_zona_jefe
	var dentro_area := _area_contiene_posicion(area_camara_3, jugador.global_position)
	if not dentro_area and puerta_4 != null and jefe_sombras != null:
		var margen_entrada_jaula := 42.0
		dentro_area = (
			jugador.global_position.x >= puerta_4.global_position.x + margen_entrada_jaula
			and jugador.global_position.x <= jefe_sombras.arena_max.x + 48.0
			and jugador.global_position.y >= jefe_sombras.arena_min.y - 96.0
			and jugador.global_position.y <= jefe_sombras.arena_max.y + 160.0
		)

	_jugador_en_zona_jefe = dentro_area
	_actualizar_actividad_jefe()
	_actualizar_ambiente_sonoro()
	if not forzar and estaba_en_zona == _jugador_en_zona_jefe:
		return

	if _jugador_en_zona_jefe:
		_mostrar_pensamiento_zona_jefe()

	_aplicar_alpha_distorsion_actual(forzar)
	_aplicar_perfil_distorsion(forzar)


func _actualizar_actividad_jefe() -> void:
	if jefe_sombras == null or not is_instance_valid(jefe_sombras):
		return

	if jefe_sombras.has_method("establecer_activo_en_arena"):
		jefe_sombras.establecer_activo_en_arena(_jugador_en_zona_jefe and not _jefe_derrotado and not _mundo_2_desbloqueado)


func _actualizar_ambiente_sonoro() -> void:
	if ambiente_mundo_1 == null or not is_instance_valid(ambiente_mundo_1):
		return

	if ambiente_mundo_1.has_method("establecer_modo_jefe"):
		ambiente_mundo_1.establecer_modo_jefe(_jugador_en_zona_jefe)


func _obtener_alpha_distorsion_objetivo(gafas_activas: bool) -> float:
	if gafas_activas:
		return alpha_distorsion_gafas

	if _distorsion_jefe_activa():
		return clampf(alpha_distorsion_jefe + (_obtener_intensidad_fase_jefe() * alpha_distorsion_extra_por_fase_jefe), 0.0, 0.98)

	return alpha_distorsion_base


func _aplicar_perfil_distorsion(_instantaneo: bool) -> void:
	var material := distorsion_material
	if material == null:
		return

	var es_jefe := _distorsion_jefe_activa()
	var intensidad_fase := _obtener_intensidad_fase_jefe() if es_jefe else 0.0
	var parametros := {
		"vignette_radius": max(0.22, vignette_radius_jefe - (intensidad_fase * 0.03)) if es_jefe else vignette_radius_base,
		"vignette_softness": max(0.14, vignette_softness_jefe - (intensidad_fase * 0.015)) if es_jefe else vignette_softness_base,
		"blur_strength": min(6.0, blur_strength_jefe + (intensidad_fase * blur_extra_por_fase_jefe)) if es_jefe else blur_strength_base,
		"edge_darkness": min(0.98, edge_darkness_jefe + (intensidad_fase * edge_darkness_extra_por_fase_jefe)) if es_jefe else edge_darkness_base,
		"tint_strength": min(0.52, tint_strength_jefe + (intensidad_fase * 0.03)) if es_jefe else tint_strength_base,
		"edge_desaturation": min(0.8, edge_desaturation_jefe + (intensidad_fase * 0.06)) if es_jefe else edge_desaturation_base,
		"aberration_strength": min(4.0, aberration_strength_jefe + (intensidad_fase * aberration_extra_por_fase_jefe)) if es_jefe else aberration_strength_base,
		"pulse_strength": min(0.12, pulse_strength_jefe + (intensidad_fase * pulse_strength_extra_por_fase_jefe)) if es_jefe else pulse_strength_base,
		"pulse_speed": min(4.0, pulse_speed_jefe + (intensidad_fase * pulse_speed_extra_por_fase_jefe)) if es_jefe else pulse_speed_base,
	}

	for nombre in parametros.keys():
		material.set_shader_parameter(nombre, parametros[nombre])


func _aplicar_alpha_distorsion_actual(instantaneo: bool) -> void:
	if distorsion_overlay == null:
		return

	var alpha_objetivo := _obtener_alpha_distorsion_objetivo(_estado_gafas_aplicado)
	if _tween_alpha_distorsion != null and _tween_alpha_distorsion.is_valid():
		_tween_alpha_distorsion.kill()

	if instantaneo:
		var color_actual := distorsion_overlay.color
		color_actual.a = alpha_objetivo
		distorsion_overlay.color = color_actual
		return

	var color_objetivo := distorsion_overlay.color
	color_objetivo.a = alpha_objetivo
	_tween_alpha_distorsion = create_tween()
	_tween_alpha_distorsion.set_trans(Tween.TRANS_SINE)
	_tween_alpha_distorsion.set_ease(Tween.EASE_IN_OUT)
	_tween_alpha_distorsion.set_ignore_time_scale(true)
	_tween_alpha_distorsion.tween_property(distorsion_overlay, "color", color_objetivo, duracion_transicion_distorsion_jefe)


func _distorsion_jefe_activa() -> bool:
	return _jugador_en_zona_jefe and jefe_sombras != null and is_instance_valid(jefe_sombras) and not jefe_sombras.esta_derrotado()


func _obtener_intensidad_fase_jefe() -> float:
	if not _distorsion_jefe_activa() or not jefe_sombras.has_method("obtener_fase_actual"):
		return 0.0

	return float(max(jefe_sombras.obtener_fase_actual() - 1, 0))


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


func _cargar_progreso_guardado() -> void:
	var datos_guardado := SistemaGuardadoClass.cargar_datos()
	if String(datos_guardado.get("escena_actual", SCENE_PATH)) != SCENE_PATH:
		return

	var datos_main_game: Dictionary = Dictionary(datos_guardado.get("main_game", {}))
	if datos_main_game.is_empty():
		return

	_llave_obtenida = bool(datos_main_game.get("llave_obtenida", false))
	_nivel_completado = bool(datos_main_game.get("nivel_completado", false))
	_checkpoint_activo = bool(datos_main_game.get("checkpoint_activo", false))
	_puzzle_gafas_superado = bool(datos_main_game.get("puzzle_gafas_superado", false))
	_mundo_2_desbloqueado = bool(datos_main_game.get("mundo_2_desbloqueado", false))
	_mundo_2_alcanzado = bool(datos_main_game.get("mundo_2_alcanzado", false))
	_jefe_derrotado = bool(datos_main_game.get("jefe_derrotado", _mundo_2_desbloqueado))
	_pensamiento_jefe_mostrado = bool(datos_main_game.get("pensamiento_jefe_mostrado", false))
	_totems_activados_jefe = 3 if _mundo_2_desbloqueado else 0

	var posicion_guardada: Variant = datos_main_game.get("posicion_respawn", _posicion_inicial_jugador)
	if posicion_guardada is Vector2:
		_posicion_respawn_actual = posicion_guardada
	elif posicion_guardada is Array and posicion_guardada.size() >= 2:
		_posicion_respawn_actual = Vector2(float(posicion_guardada[0]), float(posicion_guardada[1]))

	if _llave_obtenida and llave != null and llave.has_method("otorgar_llave"):
		llave.otorgar_llave()

	if _nivel_completado and puerta != null and puerta.has_method("abrir"):
		puerta.abrir(true)

	if _puzzle_gafas_superado and altar_gafas != null and altar_gafas.has_method("marcar_resuelto"):
		altar_gafas.marcar_resuelto()

	_actualizar_puerta_jefe(_puzzle_gafas_superado, false, true)
	_actualizar_puerta_mundo_2(_mundo_2_desbloqueado, true)

	if hud != null:
		hud.actualizar_llave(_llave_obtenida)
		hud.actualizar_checkpoint(_checkpoint_activo)

	if jugador != null:
		var posicion_inicio := _posicion_respawn_actual if _checkpoint_activo else _posicion_inicial_jugador
		jugador.restaurar_para_respawn(posicion_inicio)


func _guardar_progreso_actual() -> void:
	if jugador == null:
		return

	var datos_main_game := {
		"llave_obtenida": _llave_obtenida,
		"nivel_completado": _nivel_completado,
		"checkpoint_activo": _checkpoint_activo,
		"puzzle_gafas_superado": _puzzle_gafas_superado,
		"mundo_2_desbloqueado": _mundo_2_desbloqueado,
		"mundo_2_alcanzado": _mundo_2_alcanzado,
		"jefe_derrotado": _jefe_derrotado or _mundo_2_desbloqueado,
		"pensamiento_jefe_mostrado": _pensamiento_jefe_mostrado,
		"posicion_respawn": _posicion_respawn_actual if _checkpoint_activo else _posicion_inicial_jugador,
	}
	SistemaGuardadoClass.guardar_estado_main_game(datos_main_game)


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


func _reproducir_intro_nueva_partida() -> void:
	if jugador == null or hud == null:
		return

	jugador.establecer_control_habilitado(false)
	var overlay := ColorRect.new()
	overlay.anchor_left = 0.0
	overlay.anchor_top = 0.0
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.offset_left = 0.0
	overlay.offset_top = 0.0
	overlay.offset_right = 0.0
	overlay.offset_bottom = 0.0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.color = Color(0.01, 0.01, 0.02, 1.0)
	$Canvas.add_child(overlay)
	$Canvas.move_child(overlay, $Canvas.get_child_count() - 1)
	hud.mostrar_mensaje("Respira. Solo cruza el pasillo una vez mas.")
	if hud.has_method("mostrar_pensamiento"):
		hud.mostrar_pensamiento("Otra vez esas miradas. Solo sigue.", false)

	var tween := create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(overlay, "color:a", 0.0, 1.05)
	await tween.finished
	overlay.queue_free()
	await get_tree().create_timer(0.2, true, false, true).timeout
	jugador.establecer_control_habilitado(true)
	_restaurar_mensaje_hud()


func _exit_tree() -> void:
	if not _transicionando_a_mundo_2:
		_guardar_progreso_actual()
	_restaurar_tiempo_normal()
