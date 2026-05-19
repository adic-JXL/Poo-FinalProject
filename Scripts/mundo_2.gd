extends Node2D

const SistemaGuardadoClass = preload("res://Scripts/sistema_guardado.gd")
const PERSONAJE_SCENE := preload("res://Escenas/Personaje.tscn")
const HUD_SCENE := preload("res://Escenas/HUD.tscn")
const MENU_PAUSA_SCENE := preload("res://Escenas/MenuPausa.tscn")
const MURO_CARNE_SCENE := preload("res://Escenas/MuroCarne.tscn")
const FONDO_MUNDO_FINAL_SCRIPT := preload("res://Scripts/fondo_mundo_final.gd")
const AMBIENTE_MUNDO_2_SCRIPT := preload("res://Scripts/ambiente_mundo_2.gd")
const DISTORSION_SHADER := preload("res://Shaders/vigneta_distorsion.gdshader")
const MENU_SCENE := "res://Escenas/Menu.tscn"
const SCENE_PATH := "res://Escenas/Mundo2.tscn"
const ESCALA_TIEMPO_PAUSA := 0.000001
const FACTOR_LENTITUD_GAFAS_MURO := 0.9
const INTERVALO_PENSAMIENTOS := 20.0
const PENSAMIENTOS_OSCUROS := [
	"Si tropiezo otra vez, va a sonar igual que sus risas.",
	"Corro, pero el ruido no deja de perseguirme.",
	"Ni escapando siento que me quieren dejar en paz.",
	"Si me alcanza, vuelvo a ser el chiste de siempre.",
	"Cada salto se siente como intentar salir de sus burlas.",
]
const PENSAMIENTOS_GAFAS := [
	"Con las gafas puestas, el camino deja de esconderse.",
	"Si puedo verlo claro, tambien puedo seguir.",
	"No todo lo que me persigue decide quien soy.",
]

@export_group("Flujo")
@export var altura_caida_respawn: float = 760.0
@export var offset_camara: Vector2 = Vector2(0, -64)
@export var posicion_spawn_defecto: Vector2 = Vector2(144, 520)
@export var mensaje_llegada: String = "Mundo 2. Corre: el muro no se detendra, pero las gafas revelan la ruta."
@export var mensaje_respawn: String = "Has vuelto al inicio del mundo 2."
@export var mensaje_fallo_muro: String = "El muro te alcanzo. Respira y vuelve a correr."
@export var duracion_restablecer_mensaje_llegada: float = 2.45
@export var duracion_intro_entrada_puerta: float = 0.46
@export var desplazamiento_salida_puerta: Vector2 = Vector2(72, 0)
@export var espera_inicio_persecucion: float = 0.5

@export_group("Jugador")
@export var jugador_velocidad_base: float = 100.0
@export var jugador_fuerza_salto: float = 300.0
@export var jugador_aceleracion: float = 1000.0

@export_group("Camara")
@export var zoom_base_mundo: Vector2 = Vector2(1.9, 1.9)
@export var zoom_con_gafas: Vector2 = Vector2(1.6, 1.6)
@export var suavizado_camara: float = 6.0
@export var adelanto_camara_muro: float = 316.0
@export var adelanto_camara_jugador: float = 48.0

@export_group("Muro")
@export var posicion_inicial_muro: Vector2 = Vector2(-136, 326)
@export var velocidad_muro: float = 72.0

@export_group("Distorsion")
@export var alpha_distorsion_base: float = 0.72
@export var alpha_distorsion_gafas: float = 0.0
@export var duracion_transicion_gafas: float = 0.22
@export var vignette_radius_base: float = 0.56
@export var vignette_softness_base: float = 0.28
@export var blur_strength_base: float = 2.2
@export var edge_darkness_base: float = 0.6
@export var tint_strength_base: float = 0.18
@export var edge_desaturation_base: float = 0.22
@export var aberration_strength_base: float = 1.2
@export var pulse_strength_base: float = 0.02
@export var pulse_speed_base: float = 0.8

@export_group("Sonido")
@export var distancia_peligro_maxima_muro: float = 620.0

var jugador: Jugador = null
var hud: HUD = null
var menu_pausa: MenuPausa = null
var muro_carne: MuroCarne = null
var punto_respawn: Marker2D = null
var camara_1: Camera2D = null
var camara_2: Camera2D = null
var area_camara_1: Area2D = null
var area_camara_2: Area2D = null
var puerta_entrada_mundo_1: Node2D = null
var salida_entrada_mundo_1: Marker2D = null
var fondo_mundo_final: Node2D = null
var ambiente_mundo_2: AudioStreamPlayer = null
var distorsion_overlay: ColorRect = null
var distorsion_material: ShaderMaterial = null
var _camara_actual: Camera2D = null
var _posicion_respawn_actual: Vector2 = Vector2.ZERO
var _pausa_activa: bool = false
var _respawn_activo: bool = false
var _estado_gafas_aplicado: bool = false
var _tween_zoom: Tween
var _tween_alpha_distorsion: Tween
var _temporizador_pensamientos: Timer = null
var _indice_pensamiento: int = 0
var _indice_pensamiento_gafas: int = 0
var _token_restablecer_mensaje: int = 0
var _datos_transicion_entrada: Dictionary = {}
var _intro_persecucion_activa: bool = false


func _ready() -> void:
	_datos_transicion_entrada = SistemaGuardadoClass.consumir_transicion_pendiente()
	_asegurar_estructura_base()
	_resolver_nodos()
	_configurar_jugador_base()
	_configurar_puertas_decorativas()
	_configurar_menu_pausa()
	_configurar_distorsion_visual()
	_configurar_jugador()
	_configurar_muro()
	_configurar_camaras()
	_configurar_pensamientos()
	_cargar_guardado_mundo_2()
	_configurar_hud()
	_aplicar_estado_gafas(jugador.gafas_activas(), true)
	_sincronizar_camara_con_jugador(true, 0.0)
	_actualizar_presion_ambiente()
	if _debe_reproducir_entrada_desde_mundo_1():
		_intro_persecucion_activa = true
		call_deferred("_reproducir_intro_entrada_mundo_1")
		return
	_guardar_progreso()


func _process(delta: float) -> void:
	if _pausa_activa or _respawn_activo or _intro_persecucion_activa or jugador == null or not is_instance_valid(jugador):
		return

	_actualizar_camara_por_posicion()
	_sincronizar_camara_con_jugador(false, delta)
	_actualizar_presion_ambiente()

	if jugador.global_position.y > altura_caida_respawn:
		call_deferred("_reiniciar_carrera", false, mensaje_respawn)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pausa"):
		alternar_pausa()
		get_viewport().set_input_as_handled()


func alternar_pausa() -> void:
	if _respawn_activo:
		return

	if _pausa_activa:
		cerrar_menu_pausa()
		return

	abrir_menu_pausa()


func abrir_menu_pausa() -> void:
	if _pausa_activa or menu_pausa == null or jugador == null:
		return

	_pausa_activa = true
	jugador.velocity = Vector2.ZERO
	jugador.establecer_control_habilitado(false)
	if muro_carne != null:
		muro_carne.establecer_congelado(true)
	_actualizar_escala_tiempo()
	menu_pausa.establecer_modo_carrera(true)
	menu_pausa.abrir(false, "Inicio del mundo 2")


func cerrar_menu_pausa() -> void:
	if not _pausa_activa:
		return

	_pausa_activa = false
	if jugador != null:
		jugador.establecer_control_habilitado(true)
	if muro_carne != null:
		muro_carne.establecer_congelado(false)
	_actualizar_escala_tiempo()
	if menu_pausa != null:
		menu_pausa.cerrar()


func reiniciar_nivel() -> void:
	call_deferred("_reiniciar_carrera", false, mensaje_respawn)


func volver_al_menu() -> void:
	cerrar_menu_pausa()
	_restaurar_tiempo_normal()
	get_tree().change_scene_to_file(MENU_SCENE)


func _asegurar_estructura_base() -> void:
	if get_node_or_null("FondoMundoFinal") == null:
		var fondo_instancia: Node2D = FONDO_MUNDO_FINAL_SCRIPT.new()
		fondo_instancia.name = "FondoMundoFinal"
		add_child(fondo_instancia)
		move_child(fondo_instancia, 0)

	if get_node_or_null("SpawnJugador") == null:
		var spawn := Marker2D.new()
		spawn.name = "SpawnJugador"
		spawn.position = posicion_spawn_defecto
		add_child(spawn)

	if get_node_or_null("SalidaEntradaMundo1") == null:
		var puerta_inicio := get_node_or_null("PuertaBloqueada") as Node2D
		if puerta_inicio != null:
			var salida := Marker2D.new()
			salida.name = "SalidaEntradaMundo1"
			salida.position = puerta_inicio.position + desplazamiento_salida_puerta
			add_child(salida)

	var player_root := get_node_or_null("Player") as Node2D
	if player_root == null:
		player_root = Node2D.new()
		player_root.name = "Player"
		add_child(player_root)

	if player_root.get_node_or_null("Jugador") == null:
		var jugador_instancia := PERSONAJE_SCENE.instantiate()
		jugador_instancia.name = "Jugador"
		player_root.add_child(jugador_instancia)

	var canvas := get_node_or_null("Canvas") as CanvasLayer
	if canvas == null:
		canvas = CanvasLayer.new()
		canvas.name = "Canvas"
		add_child(canvas)

	if canvas.get_node_or_null("DistorsionOverlay") == null:
		var overlay := ColorRect.new()
		overlay.name = "DistorsionOverlay"
		overlay.anchor_left = 0.0
		overlay.anchor_top = 0.0
		overlay.anchor_right = 1.0
		overlay.anchor_bottom = 1.0
		overlay.offset_left = 0.0
		overlay.offset_top = 0.0
		overlay.offset_right = 0.0
		overlay.offset_bottom = 0.0
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.color = Color(0.4, 0.72, 0.88, alpha_distorsion_base)
		var material := ShaderMaterial.new()
		material.shader = DISTORSION_SHADER
		material.resource_local_to_scene = true
		overlay.material = material
		canvas.add_child(overlay)
		canvas.move_child(overlay, 0)

	if canvas.get_node_or_null("HUD") == null:
		var hud_instancia := HUD_SCENE.instantiate()
		hud_instancia.name = "HUD"
		canvas.add_child(hud_instancia)

	if canvas.get_node_or_null("MenuPausa") == null:
		var menu_instancia := MENU_PAUSA_SCENE.instantiate()
		menu_instancia.name = "MenuPausa"
		canvas.add_child(menu_instancia)

	if get_node_or_null("MuroCarne") == null:
		var muro_instancia := MURO_CARNE_SCENE.instantiate()
		muro_instancia.name = "MuroCarne"
		add_child(muro_instancia)

	if get_node_or_null("AmbienteMundo2") == null:
		var ambiente_instancia: AudioStreamPlayer = AMBIENTE_MUNDO_2_SCRIPT.new()
		ambiente_instancia.name = "AmbienteMundo2"
		add_child(ambiente_instancia)


func _resolver_nodos() -> void:
	jugador = get_node_or_null("Player/Jugador") as Jugador
	hud = get_node_or_null("Canvas/HUD") as HUD
	menu_pausa = get_node_or_null("Canvas/MenuPausa") as MenuPausa
	muro_carne = get_node_or_null("MuroCarne") as MuroCarne
	punto_respawn = get_node_or_null("SpawnJugador") as Marker2D
	camara_1 = get_node_or_null("Camera2D") as Camera2D
	camara_2 = get_node_or_null("Camera2D2") as Camera2D
	area_camara_1 = get_node_or_null("Area2D") as Area2D
	area_camara_2 = get_node_or_null("Area2D2") as Area2D
	puerta_entrada_mundo_1 = get_node_or_null("PuertaBloqueada") as Node2D
	salida_entrada_mundo_1 = get_node_or_null("SalidaEntradaMundo1") as Marker2D
	fondo_mundo_final = get_node_or_null("FondoMundoFinal") as Node2D
	ambiente_mundo_2 = get_node_or_null("AmbienteMundo2") as AudioStreamPlayer
	distorsion_overlay = get_node_or_null("Canvas/DistorsionOverlay") as ColorRect
	distorsion_material = distorsion_overlay.material as ShaderMaterial if distorsion_overlay != null else null
	if punto_respawn != null and punto_respawn.position == Vector2.ZERO:
		punto_respawn.position = posicion_spawn_defecto


func _configurar_jugador_base() -> void:
	if jugador == null:
		return

	jugador.velocidad_base = jugador_velocidad_base
	jugador.fuerza_salto = jugador_fuerza_salto
	jugador.aceleracion = jugador_aceleracion


func _configurar_puertas_decorativas() -> void:
	for child in get_children():
		if child == null or not String(child.name).begins_with("PuertaBloqueada"):
			continue

		if child.has_method("desactivar_interaccion"):
			child.desactivar_interaccion()


func _configurar_menu_pausa() -> void:
	if menu_pausa == null:
		return

	menu_pausa.hide()
	if not menu_pausa.continuar_solicitado.is_connected(cerrar_menu_pausa):
		menu_pausa.continuar_solicitado.connect(cerrar_menu_pausa)
	if not menu_pausa.reiniciar_solicitado.is_connected(reiniciar_nivel):
		menu_pausa.reiniciar_solicitado.connect(reiniciar_nivel)
	if not menu_pausa.volver_menu_solicitado.is_connected(volver_al_menu):
		menu_pausa.volver_menu_solicitado.connect(volver_al_menu)
	menu_pausa.establecer_modo_carrera(true)


func _configurar_distorsion_visual() -> void:
	if distorsion_overlay == null:
		return

	if distorsion_overlay.material is ShaderMaterial:
		distorsion_material = (distorsion_overlay.material as ShaderMaterial).duplicate()
		distorsion_material.resource_local_to_scene = true
		distorsion_overlay.material = distorsion_material

	distorsion_overlay.show()
	var color_base := distorsion_overlay.color
	color_base = Color(0.4, 0.72, 0.88, _obtener_alpha_distorsion_objetivo(false))
	distorsion_overlay.color = color_base
	_aplicar_perfil_distorsion(true)


func _configurar_jugador() -> void:
	if jugador == null:
		return

	if not jugador.gafas_actualizadas.is_connected(_on_jugador_gafas_actualizadas):
		jugador.gafas_actualizadas.connect(_on_jugador_gafas_actualizadas)


func _configurar_muro() -> void:
	if muro_carne == null:
		return

	muro_carne.velocidad_base = velocidad_muro
	muro_carne.adelanto_camara = adelanto_camara_muro
	muro_carne.configurar_objetivo(jugador)
	muro_carne.reiniciar(posicion_inicial_muro)
	if not muro_carne.jugador_alcanzado.is_connected(_on_muro_carne_jugador_alcanzado):
		muro_carne.jugador_alcanzado.connect(_on_muro_carne_jugador_alcanzado)


func _configurar_camaras() -> void:
	if area_camara_1 != null and not area_camara_1.body_entered.is_connected(_on_area_camara_1_body_entered):
		area_camara_1.body_entered.connect(_on_area_camara_1_body_entered)

	if area_camara_2 != null and not area_camara_2.body_entered.is_connected(_on_area_camara_2_body_entered):
		area_camara_2.body_entered.connect(_on_area_camara_2_body_entered)

	for camara in [camara_1, camara_2]:
		if camara == null:
			continue
		camara.enabled = false
		camara.zoom = zoom_base_mundo
		camara.position_smoothing_enabled = false

	_actualizar_camara_por_posicion()


func _configurar_pensamientos() -> void:
	if _temporizador_pensamientos != null:
		return

	_temporizador_pensamientos = Timer.new()
	_temporizador_pensamientos.wait_time = INTERVALO_PENSAMIENTOS
	_temporizador_pensamientos.one_shot = false
	_temporizador_pensamientos.ignore_time_scale = true
	_temporizador_pensamientos.timeout.connect(_on_temporizador_pensamientos_timeout)
	add_child(_temporizador_pensamientos)
	_temporizador_pensamientos.start()


func _configurar_hud() -> void:
	if hud == null or jugador == null:
		return

	hud.show()
	hud.configurar_jugador(jugador)
	hud.actualizar_llave(false)
	hud.actualizar_checkpoint(false)
	hud.mostrar_mensaje(mensaje_llegada)


func _cargar_guardado_mundo_2() -> void:
	var datos_guardado := SistemaGuardadoClass.cargar_datos()
	_posicion_respawn_actual = punto_respawn.global_position if punto_respawn != null else posicion_spawn_defecto
	var posicion_jugador_objetivo := _posicion_respawn_actual
	var posicion_muro_objetivo := posicion_inicial_muro

	if not _debe_reproducir_entrada_desde_mundo_1() and String(datos_guardado.get("escena_actual", SCENE_PATH)) == SCENE_PATH:
		var datos_mundo_2: Dictionary = Dictionary(datos_guardado.get("mundo_2", {}))
		if not datos_mundo_2.is_empty():
			_posicion_respawn_actual = _parsear_vector2(datos_mundo_2.get("posicion_respawn", _posicion_respawn_actual), _posicion_respawn_actual)
			posicion_jugador_objetivo = _parsear_vector2(datos_mundo_2.get("posicion_jugador", _posicion_respawn_actual), _posicion_respawn_actual)
			posicion_muro_objetivo = _parsear_vector2(datos_mundo_2.get("posicion_muro", posicion_inicial_muro), posicion_inicial_muro)

	if punto_respawn != null:
		punto_respawn.global_position = posicion_spawn_defecto
		_posicion_respawn_actual = punto_respawn.global_position

	if jugador != null and jugador.has_method("restaurar_para_respawn"):
		jugador.restaurar_para_respawn(posicion_jugador_objetivo)

	if muro_carne != null:
		muro_carne.reiniciar(posicion_muro_objetivo)


func _guardar_progreso() -> void:
	if _intro_persecucion_activa or jugador == null or not is_instance_valid(jugador):
		return

	if punto_respawn == null:
		_posicion_respawn_actual = posicion_spawn_defecto
	else:
		_posicion_respawn_actual = punto_respawn.global_position

	var datos_mundo_2 := {
		"posicion_respawn": _posicion_respawn_actual,
		"posicion_jugador": jugador.global_position,
		"posicion_muro": muro_carne.global_position if muro_carne != null else posicion_inicial_muro,
	}
	SistemaGuardadoClass.guardar_estado_mundo_2(datos_mundo_2)


func _reiniciar_carrera(con_animacion_muerte: bool, mensaje: String) -> void:
	if _respawn_activo or jugador == null:
		return

	_respawn_activo = true
	_token_restablecer_mensaje += 1
	var token_actual := _token_restablecer_mensaje

	if _pausa_activa:
		cerrar_menu_pausa()
	_restaurar_tiempo_normal()

	if muro_carne != null:
		muro_carne.establecer_congelado(true)
		muro_carne.establecer_activo(false)

	jugador.velocity = Vector2.ZERO
	jugador.establecer_control_habilitado(false)

	if con_animacion_muerte and jugador.has_method("reproducir_muerte"):
		await jugador.reproducir_muerte()

	jugador.restaurar_para_respawn(_posicion_respawn_actual)
	_aplicar_estado_gafas(false, true)

	if muro_carne != null:
		muro_carne.reiniciar(posicion_inicial_muro)
		muro_carne.establecer_multiplicador_velocidad(1.0)

	_actualizar_camara_por_posicion()
	_sincronizar_camara_con_jugador(true, 0.0)
	_actualizar_presion_ambiente()
	jugador.establecer_control_habilitado(true)
	_guardar_progreso()
	if hud != null:
		hud.mostrar_mensaje(mensaje)

	if mensaje == mensaje_fallo_muro:
		_reiniciar_ciclo_pensamientos()
		_programar_restablecer_mensaje_llegada(token_actual)

	_respawn_activo = false


func _actualizar_camara_por_posicion() -> void:
	if jugador == null:
		return

	var camara_objetivo := camara_1
	if _area_contiene_posicion(area_camara_2, jugador.global_position) and camara_2 != null:
		camara_objetivo = camara_2
	elif _area_contiene_posicion(area_camara_1, jugador.global_position) and camara_1 != null:
		camara_objetivo = camara_1
	elif camara_2 != null and camara_1 == null:
		camara_objetivo = camara_2

	_activar_camara(camara_objetivo)


func _activar_camara(camara_objetivo: Camera2D) -> void:
	if camara_objetivo == null:
		return

	if _camara_actual == camara_objetivo and camara_objetivo.enabled:
		return

	for camara in [camara_1, camara_2]:
		if camara == null:
			continue
		camara.enabled = camara == camara_objetivo

	_camara_actual = camara_objetivo
	_camara_actual.make_current()


func _sincronizar_camara_con_jugador(forzar: bool = false, delta: float = 0.0) -> void:
	if _camara_actual == null or jugador == null:
		return

	var objetivo_x := jugador.global_position.x + adelanto_camara_jugador
	if muro_carne != null:
		objetivo_x = maxf(objetivo_x, muro_carne.obtener_x_impulso_camara())

	var objetivo := Vector2(objetivo_x, jugador.global_position.y + offset_camara.y)
	if forzar or delta <= 0.0:
		_camara_actual.global_position = objetivo
		return

	var peso := clampf(delta * suavizado_camara, 0.0, 1.0)
	_camara_actual.global_position = _camara_actual.global_position.lerp(objetivo, peso)


func _on_area_camara_1_body_entered(body: Node) -> void:
	if body != null and body.is_in_group("jugador"):
		_activar_camara(camara_1)


func _on_area_camara_2_body_entered(body: Node) -> void:
	if body != null and body.is_in_group("jugador"):
		_activar_camara(camara_2)


func _on_jugador_gafas_actualizadas(activa: bool, _duracion_restante: float, _cooldown_restante: float, _cooldown_actual: float, _siguiente_cooldown: float) -> void:
	if activa == _estado_gafas_aplicado:
		_aplicar_alpha_distorsion_actual(false)
		_aplicar_perfil_distorsion(false)
		return

	_aplicar_estado_gafas(activa)
	if activa:
		if hud != null and hud.has_method("mostrar_mensaje"):
			hud.mostrar_mensaje("Las gafas revelan plataformas y te dan un instante de claridad.")
		_mostrar_pensamiento_gafas()


func _aplicar_estado_gafas(activa: bool, instantaneo: bool = false) -> void:
	_estado_gafas_aplicado = activa
	if muro_carne != null:
		muro_carne.establecer_multiplicador_velocidad(FACTOR_LENTITUD_GAFAS_MURO if activa else 1.0)

	for plataforma in get_tree().get_nodes_in_group("plataforma_gafas"):
		if plataforma != null and plataforma.has_method("establecer_revelada"):
			plataforma.establecer_revelada(activa)

	if ambiente_mundo_2 != null and ambiente_mundo_2.has_method("establecer_claridad_gafas"):
		ambiente_mundo_2.establecer_claridad_gafas(activa)

	_animar_transicion_gafas(activa, instantaneo)


func _animar_transicion_gafas(activa: bool, instantaneo: bool) -> void:
	var zoom_objetivo := zoom_con_gafas if activa else zoom_base_mundo
	var alpha_objetivo := _obtener_alpha_distorsion_objetivo(activa)
	if _tween_zoom != null and _tween_zoom.is_valid():
		_tween_zoom.kill()
	if _tween_alpha_distorsion != null and _tween_alpha_distorsion.is_valid():
		_tween_alpha_distorsion.kill()

	if instantaneo:
		_aplicar_zoom_camaras(zoom_objetivo)
		_aplicar_perfil_distorsion(true)
		_aplicar_alpha_distorsion_actual(true)
		return

	_tween_zoom = create_tween()
	_tween_zoom.set_parallel(true)
	_tween_zoom.set_ignore_time_scale(true)
	_tween_zoom.set_trans(Tween.TRANS_SINE)
	_tween_zoom.set_ease(Tween.EASE_IN_OUT)
	for camara in [camara_1, camara_2]:
		if camara != null:
			_tween_zoom.tween_property(camara, "zoom", zoom_objetivo, duracion_transicion_gafas)

	if distorsion_overlay != null:
		var color_objetivo := distorsion_overlay.color
		color_objetivo.a = alpha_objetivo
		_tween_zoom.tween_property(distorsion_overlay, "color", color_objetivo, duracion_transicion_gafas)

	_aplicar_perfil_distorsion(false)


func _aplicar_zoom_camaras(zoom_objetivo: Vector2) -> void:
	for camara in [camara_1, camara_2]:
		if camara != null:
			camara.zoom = zoom_objetivo


func _on_muro_carne_jugador_alcanzado() -> void:
	call_deferred("_reiniciar_carrera", true, mensaje_fallo_muro)


func _debe_reproducir_entrada_desde_mundo_1() -> bool:
	return String(_datos_transicion_entrada.get("escena_destino", "")) == SCENE_PATH and String(_datos_transicion_entrada.get("id_entrada", "")) == "entrada_mundo_1"


func _reproducir_intro_entrada_mundo_1() -> void:
	if jugador == null:
		_guardar_progreso()
		return

	_intro_persecucion_activa = true
	if hud != null:
		hud.mostrar_mensaje("No mires atras. Solo corre.")
		if hud.has_method("mostrar_pensamiento"):
			hud.mostrar_pensamiento("Otra puerta, otro pasillo. No te detengas.", false)

	if muro_carne != null:
		muro_carne.establecer_congelado(true)
		muro_carne.establecer_activo(false)
		muro_carne.reiniciar(posicion_inicial_muro - Vector2(124, 0))

	jugador.establecer_control_habilitado(false)
	var destino := salida_entrada_mundo_1.global_position if salida_entrada_mundo_1 != null else posicion_spawn_defecto
	var origen := (puerta_entrada_mundo_1.global_position + Vector2(0, 8)) if puerta_entrada_mundo_1 != null else destino
	_posicion_respawn_actual = destino
	jugador.restaurar_para_respawn(destino)
	jugador.establecer_control_habilitado(false)
	if puerta_entrada_mundo_1 != null and puerta_entrada_mundo_1.has_method("abrir"):
		puerta_entrada_mundo_1.abrir()

	var overlay := _crear_overlay_intro()
	await jugador.animar_salida_puerta(origen, destino, duracion_intro_entrada_puerta)
	jugador.establecer_control_habilitado(false)
	_actualizar_camara_por_posicion()
	_sincronizar_camara_con_jugador(true, 0.0)

	var tween := create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(overlay, "color:a", 0.0, 0.75)
	await tween.finished
	overlay.queue_free()
	await get_tree().create_timer(espera_inicio_persecucion, true, false, true).timeout

	if muro_carne != null:
		var tween_muro := create_tween()
		tween_muro.set_ignore_time_scale(true)
		tween_muro.set_trans(Tween.TRANS_CUBIC)
		tween_muro.set_ease(Tween.EASE_OUT)
		tween_muro.tween_property(muro_carne, "global_position", posicion_inicial_muro, 0.55)
		await tween_muro.finished
		muro_carne.establecer_activo(true)
		muro_carne.establecer_congelado(false)
		muro_carne.establecer_multiplicador_velocidad(FACTOR_LENTITUD_GAFAS_MURO if jugador.gafas_activas() else 1.0)

	jugador.establecer_control_habilitado(true)
	_intro_persecucion_activa = false
	_actualizar_presion_ambiente()
	_guardar_progreso()


func _crear_overlay_intro() -> ColorRect:
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
	overlay.color = Color(0.01, 0.02, 0.03, 0.62)
	$Canvas.add_child(overlay)
	$Canvas.move_child(overlay, $Canvas.get_child_count() - 1)
	return overlay


func _configurar_peligro_ambiente(valor: float) -> void:
	if ambiente_mundo_2 != null and ambiente_mundo_2.has_method("establecer_presion"):
		ambiente_mundo_2.establecer_presion(valor)


func _actualizar_presion_ambiente() -> void:
	if ambiente_mundo_2 == null or jugador == null or muro_carne == null:
		return

	var distancia := maxf(jugador.global_position.x - muro_carne.global_position.x, 0.0)
	var presion := 1.0 - clampf((distancia - 128.0) / maxf(distancia_peligro_maxima_muro, 64.0), 0.0, 1.0)
	_configurar_peligro_ambiente(presion)


func _on_temporizador_pensamientos_timeout() -> void:
	if _pausa_activa or _respawn_activo or hud == null or not hud.has_method("mostrar_pensamiento"):
		return

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


func _reiniciar_ciclo_pensamientos() -> void:
	_indice_pensamiento = 0
	if _temporizador_pensamientos != null:
		_temporizador_pensamientos.start(INTERVALO_PENSAMIENTOS)


func _programar_restablecer_mensaje_llegada(token_actual: int) -> void:
	_restablecer_mensaje_llegada_async(token_actual)


func _restablecer_mensaje_llegada_async(token_actual: int) -> void:
	await get_tree().create_timer(duracion_restablecer_mensaje_llegada).timeout
	if token_actual != _token_restablecer_mensaje:
		return
	if hud == null or not is_instance_valid(hud):
		return
	hud.mostrar_mensaje(mensaje_llegada)


func _obtener_alpha_distorsion_objetivo(gafas_activas: bool) -> float:
	return alpha_distorsion_gafas if gafas_activas else alpha_distorsion_base


func _aplicar_perfil_distorsion(_instantaneo: bool) -> void:
	if distorsion_material == null:
		return

	distorsion_material.set_shader_parameter("center", Vector2(0.5, 0.5))
	distorsion_material.set_shader_parameter("vignette_radius", vignette_radius_base)
	distorsion_material.set_shader_parameter("vignette_softness", vignette_softness_base)
	distorsion_material.set_shader_parameter("blur_strength", blur_strength_base)
	distorsion_material.set_shader_parameter("edge_darkness", edge_darkness_base)
	distorsion_material.set_shader_parameter("tint_strength", tint_strength_base)
	distorsion_material.set_shader_parameter("edge_desaturation", edge_desaturation_base)
	distorsion_material.set_shader_parameter("aberration_strength", aberration_strength_base)
	distorsion_material.set_shader_parameter("pulse_strength", pulse_strength_base)
	distorsion_material.set_shader_parameter("pulse_speed", pulse_speed_base)


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
	_tween_alpha_distorsion.tween_property(distorsion_overlay, "color", color_objetivo, duracion_transicion_gafas)


func _actualizar_escala_tiempo() -> void:
	Engine.time_scale = ESCALA_TIEMPO_PAUSA if _pausa_activa else 1.0


func _restaurar_tiempo_normal() -> void:
	Engine.time_scale = 1.0


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


func _parsear_vector2(valor: Variant, fallback: Vector2) -> Vector2:
	if valor is Vector2:
		return valor
	if valor is Array and valor.size() >= 2:
		return Vector2(float(valor[0]), float(valor[1]))
	return fallback


func _exit_tree() -> void:
	_guardar_progreso()
	_restaurar_tiempo_normal()
