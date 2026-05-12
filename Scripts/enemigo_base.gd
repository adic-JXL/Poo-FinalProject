extends CharacterBody2D
class_name EnemigoBase

signal jugador_danado(cantidad: int)
signal vida_cambiada(vida_actual: int)

@export_group("Configuracion")
@export var vida: int = 1
@export var danio_contacto: int = 1
@export var tiempo_recarga_ataque: float = 1.0

@export_group("Movimiento")
@export var velocidad: float = 70.0
@export var aceleracion: float = 900.0
@export var usa_gravedad: bool = true

var _gravedad: float = 0.0
var _puede_atacar: bool = true
var _congelado: bool = false
var _posicion_inicial: Vector2 = Vector2.ZERO
var _vida_inicial: int = 1
var _multiplicador_velocidad_temporal: float = 1.0

@onready var visual: Node2D = $Visual
@onready var area_ataque: Area2D = $AreaAtaque
@onready var temporizador_ataque: Timer = $TemporizadorAtaque


func _ready() -> void:
	add_to_group("enemigo")
	_gravedad = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
	_posicion_inicial = global_position
	_vida_inicial = max(vida, 1)
	area_ataque.body_entered.connect(_on_area_ataque_body_entered)
	temporizador_ataque.timeout.connect(_on_temporizador_ataque_timeout)
	_inicializar_enemigo()
	emit_signal("vida_cambiada", vida)


func _physics_process(delta: float) -> void:
	if _congelado:
		velocity = Vector2.ZERO
		return

	if usa_gravedad and not is_on_floor():
		velocity.y += _gravedad * delta

	_procesar_comportamiento(delta)
	move_and_slide()
	_post_procesar_movimiento()
	_intentar_atacar_colisiones_directas()
	_intentar_atacar_cuerpos_superpuestos()


func mover_horizontal(direccion: float, delta: float, multiplicador: float = 1.0) -> void:
	var velocidad_objetivo := direccion * velocidad * multiplicador * _multiplicador_velocidad_temporal
	mover_hacia_velocidad_objetivo(velocidad_objetivo, delta)


func mover_hacia_velocidad_objetivo(velocidad_objetivo: float, delta: float) -> void:
	velocity.x = move_toward(velocity.x, velocidad_objetivo, aceleracion * delta)


func detener(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, aceleracion * delta)


func recibir_danio(cantidad: int) -> void:
	vida = max(vida - cantidad, 0)
	emit_signal("vida_cambiada", vida)

	if vida == 0:
		queue_free()


func establecer_congelado(congelado: bool) -> void:
	_congelado = congelado

	if _congelado:
		velocity = Vector2.ZERO


func esta_congelado() -> bool:
	return _congelado


func establecer_multiplicador_velocidad(factor: float) -> void:
	_multiplicador_velocidad_temporal = max(factor, 0.0)


func obtener_multiplicador_velocidad() -> float:
	return _multiplicador_velocidad_temporal


func reiniciar_enemigo() -> void:
	global_position = _posicion_inicial
	velocity = Vector2.ZERO
	vida = _vida_inicial
	_puede_atacar = true
	_congelado = false
	_multiplicador_velocidad_temporal = 1.0
	temporizador_ataque.stop()
	_inicializar_enemigo()
	emit_signal("vida_cambiada", vida)


func _inicializar_enemigo() -> void:
	pass


func _procesar_comportamiento(delta: float) -> void:
	detener(delta)


func _post_procesar_movimiento() -> void:
	pass


func _puede_danar_objetivo(objetivo: Node) -> bool:
	return _puede_atacar and objetivo.is_in_group("jugador") and objetivo.has_method("recibir_danio")


func _atacar_objetivo(objetivo: Node) -> void:
	if not objetivo.recibir_danio(danio_contacto, global_position.x):
		return

	_puede_atacar = false
	temporizador_ataque.start(tiempo_recarga_ataque)
	emit_signal("jugador_danado", danio_contacto)


func _on_area_ataque_body_entered(body: Node) -> void:
	if _puede_danar_objetivo(body):
		_atacar_objetivo(body)


func _on_temporizador_ataque_timeout() -> void:
	_puede_atacar = true


func _intentar_atacar_cuerpos_superpuestos() -> void:
	if not _puede_atacar:
		return

	for body in area_ataque.get_overlapping_bodies():
		if _puede_danar_objetivo(body):
			_atacar_objetivo(body)
			return


func _intentar_atacar_colisiones_directas() -> void:
	if not _puede_atacar:
		return

	for indice in range(get_slide_collision_count()):
		var collision := get_slide_collision(indice)
		var collider = collision.get_collider()

		if _puede_danar_objetivo(collider):
			_atacar_objetivo(collider)
			return
