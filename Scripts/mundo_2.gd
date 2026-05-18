extends Node2D

const SistemaGuardadoClass = preload("res://Scripts/sistema_guardado.gd")
const PERSONAJE_SCENE := preload("res://Escenas/Personaje.tscn")
const HUD_SCENE := preload("res://Escenas/HUD.tscn")
const MENU_PAUSA_SCENE := preload("res://Escenas/MenuPausa.tscn")
const MURO_CARNE_SCENE := preload("res://Escenas/MuroCarne.tscn")
const MENU_SCENE := "res://Escenas/Menu.tscn"
const SCENE_PATH := "res://Escenas/Mundo2.tscn"
const ESCALA_TIEMPO_PAUSA := 0.000001
const FACTOR_LENTITUD_GAFAS_MURO := 0.9

@export_group("Flujo")
@export var altura_caida_respawn: float = 760.0
@export var offset_camara: Vector2 = Vector2(0, -52)
@export var posicion_spawn_defecto: Vector2 = Vector2(144, 520)
@export var mensaje_llegada: String = "Mundo 2. Corre: el muro no se detendra, pero las gafas revelan la ruta."
@export var mensaje_respawn: String = "Has vuelto al inicio del mundo 2."
@export var mensaje_fallo_muro: String = "El muro te alcanzo. Respira y vuelve a correr."

@export_group("Jugador")
@export var jugador_velocidad_base: float = 100.0
@export var jugador_fuerza_salto: float = 300.0
@export var jugador_aceleracion: float = 1000.0

@export_group("Camara")
@export var zoom_base_mundo: Vector2 = Vector2(1.94, 1.94)
@export var zoom_con_gafas: Vector2 = Vector2(1.62, 1.62)
@export var suavizado_camara: float = 6.0
@export var adelanto_camara_muro: float = 316.0
@export var adelanto_camara_jugador: float = 34.0

@export_group("Muro")
@export var posicion_inicial_muro: Vector2 = Vector2(-136, 326)
@export var velocidad_muro: float = 72.0

var jugador: Jugador = null
var hud: HUD = null
var menu_pausa: MenuPausa = null
var muro_carne: MuroCarne = null
var punto_respawn: Marker2D = null
var camara_1: Camera2D = null
var camara_2: Camera2D = null
var area_camara_1: Area2D = null
var area_camara_2: Area2D = null
var _camara_actual: Camera2D = null
var _posicion_respawn_actual: Vector2 = Vector2.ZERO
var _pausa_activa: bool = false
var _respawn_activo: bool = false
var _estado_gafas_aplicado: bool = false
var _tween_zoom: Tween


func _ready() -> void:
	_asegurar_estructura_base()
	_resolver_nodos()
	_configurar_jugador_base()
	_configurar_puertas_decorativas()
	_configurar_menu_pausa()
	_configurar_jugador()
	_configurar_muro()
	_configurar_camaras()
	_cargar_guardado_mundo_2()
	_configurar_hud()
	_aplicar_estado_gafas(jugador.gafas_activas(), true)
	_sincronizar_camara_con_jugador(true, 0.0)
	_guardar_progreso()


func _process(delta: float) -> void:
	if _pausa_activa or _respawn_activo or jugador == null or not is_instance_valid(jugador):
		return

	_actualizar_camara_por_posicion()
	_sincronizar_camara_con_jugador(false, delta)

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
	if get_node_or_null("SpawnJugador") == null:
		var spawn := Marker2D.new()
		spawn.name = "SpawnJugador"
		spawn.position = posicion_spawn_defecto
		add_child(spawn)

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

	if String(datos_guardado.get("escena_actual", SCENE_PATH)) == SCENE_PATH:
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
	if jugador == null or not is_instance_valid(jugador):
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
	jugador.establecer_control_habilitado(true)
	_guardar_progreso()
	if hud != null:
		hud.mostrar_mensaje(mensaje)

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
	_aplicar_estado_gafas(activa)
	if activa and hud != null and hud.has_method("mostrar_mensaje"):
		hud.mostrar_mensaje("Las gafas revelan plataformas y ralentizan un poco el muro.")


func _aplicar_estado_gafas(activa: bool, instantaneo: bool = false) -> void:
	_estado_gafas_aplicado = activa
	if muro_carne != null:
		muro_carne.establecer_multiplicador_velocidad(FACTOR_LENTITUD_GAFAS_MURO if activa else 1.0)

	for plataforma in get_tree().get_nodes_in_group("plataforma_gafas"):
		if plataforma != null and plataforma.has_method("establecer_revelada"):
			plataforma.establecer_revelada(activa)

	_animar_zoom_camaras(activa, instantaneo)


func _animar_zoom_camaras(activa: bool, instantaneo: bool) -> void:
	var zoom_objetivo := zoom_con_gafas if activa else zoom_base_mundo
	if _tween_zoom != null and _tween_zoom.is_valid():
		_tween_zoom.kill()

	if instantaneo:
		for camara in [camara_1, camara_2]:
			if camara != null:
				camara.zoom = zoom_objetivo
		return

	_tween_zoom = create_tween()
	_tween_zoom.set_parallel(true)
	_tween_zoom.set_ignore_time_scale(true)
	_tween_zoom.set_trans(Tween.TRANS_SINE)
	_tween_zoom.set_ease(Tween.EASE_IN_OUT)
	for camara in [camara_1, camara_2]:
		if camara != null:
			_tween_zoom.tween_property(camara, "zoom", zoom_objetivo, 0.22)


func _on_muro_carne_jugador_alcanzado() -> void:
	call_deferred("_reiniciar_carrera", true, mensaje_fallo_muro)


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
