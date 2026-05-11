extends Node2D
class_name MainGame

const MENU_SCENE := "res://Escenas/Menu.tscn"
const MENSAJE_PUERTA_CERRADA := "La puerta sigue cerrada. Resuelve el puzzle de la llave."
const MENSAJE_NIVEL_COMPLETO := "La puerta se abrio. El nivel base ya esta completo."

@export var limite_caida_y: float = 700.0
@export var escala_tiempo_golpe: float = 0.45
@export var duracion_golpe_lento: float = 0.1


@onready var tile_map: TileMapLayer = $Mapa/TileMapLayer
@onready var camara: Camera2D = $Player/Camera2D
@onready var puerta = $Objetos/Puerta
@onready var jugador: CharacterBody2D = $Player/Jugador
@onready var hud = $Canvas/HUD
@onready var llave = $Objetos/Llave
@onready var puzzle = $Canvas/PuzzleSecuencia

var _posicion_inicial_jugador: Vector2
var _llave_obtenida: bool = false
var _nivel_completado: bool = false
var _puzzle_activo: bool = false
var _temporizador_golpe: Timer


func _ready() -> void:
	_preparar_temporizador_golpe()
	_posicion_inicial_jugador = jugador.global_position

	_configurar_hud()
	_configurar_jugador()
	_configurar_enemigos()
	_configurar_interactivo(llave, _on_llave_interaccion_solicitada)
	_configurar_interactivo(puerta, _on_puerta_interaccion_solicitada)
	_configurar_puzzle()
	_restaurar_mensaje_hud()


func _physics_process(_delta: float) -> void:
	if jugador.global_position.y > limite_caida_y:
		reiniciar_nivel()


func _unhandled_input(event: InputEvent) -> void:
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
	_restaurar_tiempo_normal()
	get_tree().reload_current_scene()


func volver_al_menu() -> void:
	_restaurar_tiempo_normal()
	get_tree().change_scene_to_file(MENU_SCENE)


func obtener_jugador() -> CharacterBody2D:
	return jugador


func obtener_spawn_jugador() -> Vector2:
	return _posicion_inicial_jugador


func tiene_llave() -> bool:
	return _llave_obtenida


func esta_puzzle_activo() -> bool:
	return _puzzle_activo


func nivel_esta_completado() -> bool:
	return _nivel_completado





func _configurar_hud() -> void:
	hud.configurar_jugador(jugador)
	hud.actualizar_llave(_llave_obtenida)


func _configurar_jugador() -> void:
	jugador.vida_cambiada.connect(_on_jugador_vida_cambiada)
	jugador.dano_recibido.connect(_on_jugador_dano_recibido)


func _configurar_enemigos() -> void:
	for enemigo in get_tree().get_nodes_in_group("enemigo"):
		if enemigo.has_signal("jugador_danado"):
			enemigo.jugador_danado.connect(_on_enemigo_jugador_danado)


func _configurar_interactivo(interactivo: Node, callback: Callable) -> void:
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
	jugador.establecer_control_habilitado(true)
	_establecer_enemigos_congelados(false)
	puzzle.cerrar()
	hud.mostrar_mensaje(mensaje)


func _on_puerta_interaccion_solicitada() -> void:
	if _nivel_completado:
		return

	if not _llave_obtenida:
		hud.mostrar_mensaje(MENSAJE_PUERTA_CERRADA)
		return

	_nivel_completado = true
	puerta.abrir()
	hud.mostrar_mensaje(MENSAJE_NIVEL_COMPLETO)


func _on_jugador_vida_cambiada(vida_actual: int) -> void:
	if vida_actual > 0:
		return

	hud.mostrar_mensaje("La sombra te vencio. Reiniciando el nivel.")
	call_deferred("reiniciar_nivel")


func _on_enemigo_jugador_danado(_cantidad: int) -> void:
	if not _puzzle_activo:
		hud.mostrar_mensaje("Una sombra te alcanzo. Mantente en movimiento.")


func _on_jugador_dano_recibido(_cantidad: int, _direccion: float) -> void:
	_aplicar_golpe_lento()


func _establecer_enemigos_congelados(congelados: bool) -> void:
	for enemigo in get_tree().get_nodes_in_group("enemigo"):
		if enemigo.has_method("establecer_congelado"):
			enemigo.establecer_congelado(congelados)


func _on_rango_interaccion_cambiado(activo: bool, mensaje: String) -> void:
	if _puzzle_activo:
		return

	if activo:
		hud.mostrar_mensaje(mensaje)
		return

	_restaurar_mensaje_hud()


func _restaurar_mensaje_hud() -> void:
	if _nivel_completado:
		hud.mostrar_mensaje(MENSAJE_NIVEL_COMPLETO)
		return

	if _llave_obtenida:
		hud.mostrar_mensaje("Tienes la llave. Busca la puerta y presiona E para abrirla.")
		return

	hud.mostrar_mensaje("Explora el nivel, encuentra la llave y presiona E para activar el puzzle.")


func _preparar_temporizador_golpe() -> void:
	_temporizador_golpe = Timer.new()
	_temporizador_golpe.one_shot = true
	_temporizador_golpe.ignore_time_scale = true
	_temporizador_golpe.timeout.connect(_on_temporizador_golpe_timeout)
	add_child(_temporizador_golpe)


func _aplicar_golpe_lento() -> void:
	if duracion_golpe_lento <= 0.0:
		return

	Engine.time_scale = min(max(escala_tiempo_golpe, 0.05), 1.0)
	_temporizador_golpe.start(duracion_golpe_lento)


func _on_temporizador_golpe_timeout() -> void:
	_restaurar_tiempo_normal()


func _restaurar_tiempo_normal() -> void:
	Engine.time_scale = 1.0


func _exit_tree() -> void:
	_restaurar_tiempo_normal()
