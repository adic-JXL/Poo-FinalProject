extends Node2D

const SistemaGuardadoClass = preload("res://Scripts/sistema_guardado.gd")
const PERSONAJE_SCENE := preload("res://Escenas/Personaje.tscn")
const HUD_SCENE := preload("res://Escenas/HUD.tscn")
const SCENE_PATH := "res://Escenas/Mundo2.tscn"

@export var altura_caida_respawn: float = 760.0
@export var offset_camara: Vector2 = Vector2(0, -44)
@export var posicion_spawn_defecto: Vector2 = Vector2(144, 520)
@export var mensaje_llegada: String = "Has cruzado al mundo 2. La persecucion apenas comienza."
@export var mensaje_respawn: String = "Respawn en el inicio del mundo 2."

var jugador: Node2D = null
var hud: CanvasLayer = null
var punto_respawn: Marker2D = null
var camara_1: Camera2D = null
var camara_2: Camera2D = null
var area_camara_1: Area2D = null
var area_camara_2: Area2D = null
var _camara_actual: Camera2D = null
var _posicion_respawn_actual: Vector2 = Vector2.ZERO


func _ready() -> void:
	_asegurar_estructura_base()
	_resolver_nodos()
	_configurar_camaras()
	_cargar_guardado_mundo_2()
	_configurar_hud()
	_sincronizar_camara_con_jugador()
	_guardar_progreso()


func _process(_delta: float) -> void:
	if jugador == null or not is_instance_valid(jugador):
		return

	_actualizar_camara_por_posicion()
	_sincronizar_camara_con_jugador()

	if jugador.global_position.y > altura_caida_respawn:
		_respawnear_jugador()


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


func _resolver_nodos() -> void:
	jugador = get_node_or_null("Player/Jugador") as Node2D
	hud = get_node_or_null("Canvas/HUD") as CanvasLayer
	punto_respawn = get_node_or_null("SpawnJugador") as Marker2D
	camara_1 = get_node_or_null("Camera2D") as Camera2D
	camara_2 = get_node_or_null("Camera2D2") as Camera2D
	area_camara_1 = get_node_or_null("Area2D") as Area2D
	area_camara_2 = get_node_or_null("Area2D2") as Area2D
	if punto_respawn != null and punto_respawn.position == Vector2.ZERO:
		punto_respawn.position = posicion_spawn_defecto


func _configurar_camaras() -> void:
	if area_camara_1 != null and not area_camara_1.body_entered.is_connected(_on_area_camara_1_body_entered):
		area_camara_1.body_entered.connect(_on_area_camara_1_body_entered)

	if area_camara_2 != null and not area_camara_2.body_entered.is_connected(_on_area_camara_2_body_entered):
		area_camara_2.body_entered.connect(_on_area_camara_2_body_entered)

	if camara_1 != null:
		camara_1.enabled = false
		camara_1.position_smoothing_enabled = true
		camara_1.position_smoothing_speed = 8.0

	if camara_2 != null:
		camara_2.enabled = false
		camara_2.position_smoothing_enabled = true
		camara_2.position_smoothing_speed = 8.0

	_actualizar_camara_por_posicion()


func _configurar_hud() -> void:
	if hud == null or jugador == null:
		return

	if hud.has_method("configurar_jugador"):
		hud.configurar_jugador(jugador)
	if hud.has_method("actualizar_checkpoint"):
		hud.actualizar_checkpoint(true)
	if hud.has_method("actualizar_llave"):
		hud.actualizar_llave(false)
	if hud.has_method("mostrar_mensaje"):
		hud.mostrar_mensaje(mensaje_llegada)


func _cargar_guardado_mundo_2() -> void:
	var datos_guardado := SistemaGuardadoClass.cargar_datos()
	_posicion_respawn_actual = punto_respawn.global_position if punto_respawn != null else posicion_spawn_defecto
	var posicion_jugador_objetivo := _posicion_respawn_actual

	if String(datos_guardado.get("escena_actual", SCENE_PATH)) == SCENE_PATH:
		var datos_mundo_2: Dictionary = Dictionary(datos_guardado.get("mundo_2", {}))
		if not datos_mundo_2.is_empty():
			_posicion_respawn_actual = _parsear_vector2(datos_mundo_2.get("posicion_respawn", _posicion_respawn_actual), _posicion_respawn_actual)
			posicion_jugador_objetivo = _parsear_vector2(datos_mundo_2.get("posicion_jugador", _posicion_respawn_actual), _posicion_respawn_actual)

	if punto_respawn != null:
		punto_respawn.global_position = _posicion_respawn_actual

	if jugador != null and jugador.has_method("restaurar_para_respawn"):
		jugador.restaurar_para_respawn(posicion_jugador_objetivo)


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
	}
	SistemaGuardadoClass.guardar_estado_mundo_2(datos_mundo_2)


func _respawnear_jugador() -> void:
	if jugador == null or not jugador.has_method("restaurar_para_respawn"):
		return

	var destino_respawn := _posicion_respawn_actual if _posicion_respawn_actual != Vector2.ZERO else posicion_spawn_defecto
	jugador.restaurar_para_respawn(destino_respawn)
	_sincronizar_camara_con_jugador()
	_guardar_progreso()
	if hud != null and hud.has_method("mostrar_mensaje"):
		hud.mostrar_mensaje(mensaje_respawn)


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


func _sincronizar_camara_con_jugador() -> void:
	if _camara_actual == null or jugador == null:
		return

	_camara_actual.global_position = jugador.global_position + offset_camara


func _on_area_camara_1_body_entered(body: Node) -> void:
	if body != null and body.is_in_group("jugador"):
		_activar_camara(camara_1)


func _on_area_camara_2_body_entered(body: Node) -> void:
	if body != null and body.is_in_group("jugador"):
		_activar_camara(camara_2)


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
