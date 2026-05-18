extends Area2D
class_name MuroCarne

signal jugador_alcanzado

@export var velocidad_base: float = 72.0
@export var amplitud_pulso: float = 0.04
@export var velocidad_pulso: float = 1.55
@export var adelanto_camara: float = 316.0
@export var tamano_textura: Vector2i = Vector2i(52, 188)

var _jugador: Node2D = null
var _activo: bool = true
var _congelado: bool = false
var _multiplicador_velocidad: float = 1.0
var _posicion_inicio: Vector2 = Vector2.ZERO

static var _textura_cuerpo_cache: Texture2D
static var _textura_ojo_cache: Texture2D
static var _textura_boca_cache: Texture2D

@onready var visual: Node2D = $Visual
@onready var cuerpo: Sprite2D = $Visual/Cuerpo
@onready var ojo_izquierdo: Sprite2D = $Visual/OjoIzquierdo
@onready var ojo_derecho: Sprite2D = $Visual/OjoDerecho
@onready var boca: Sprite2D = $Visual/Boca


func _ready() -> void:
	add_to_group("muro_carne")
	_posicion_inicio = global_position
	body_entered.connect(_on_body_entered)
	_configurar_visual()


func _physics_process(delta: float) -> void:
	if not _activo or _congelado:
		return

	global_position.x += obtener_velocidad_actual() * delta
	_animar_pulso()


func configurar_objetivo(jugador: Node2D) -> void:
	_jugador = jugador


func establecer_activo(activo: bool) -> void:
	_activo = activo
	monitoring = activo
	monitorable = activo


func establecer_congelado(congelado: bool) -> void:
	_congelado = congelado


func establecer_multiplicador_velocidad(multiplicador: float) -> void:
	_multiplicador_velocidad = max(multiplicador, 0.1)


func reiniciar(posicion_objetivo: Vector2 = _posicion_inicio) -> void:
	global_position = posicion_objetivo
	_posicion_inicio = posicion_objetivo
	visual.scale = Vector2.ONE
	establecer_activo(true)
	establecer_congelado(false)


func obtener_velocidad_actual() -> float:
	return velocidad_base * _multiplicador_velocidad


func obtener_x_impulso_camara() -> float:
	return global_position.x + adelanto_camara


func _on_body_entered(body: Node) -> void:
	if body == null or not body.is_in_group("jugador"):
		return

	if not _activo:
		return

	emit_signal("jugador_alcanzado")


func _animar_pulso() -> void:
	if visual == null:
		return

	var pulso := sin(Time.get_ticks_msec() * 0.001 * velocidad_pulso)
	visual.scale = Vector2(1.0 + (pulso * amplitud_pulso * 0.55), 1.0 + (absf(pulso) * amplitud_pulso))


func _configurar_visual() -> void:
	if cuerpo != null:
		cuerpo.texture = _obtener_textura_cuerpo()
		cuerpo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	if ojo_izquierdo != null:
		ojo_izquierdo.texture = _obtener_textura_ojo()
		ojo_izquierdo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	if ojo_derecho != null:
		ojo_derecho.texture = _obtener_textura_ojo()
		ojo_derecho.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	if boca != null:
		boca.texture = _obtener_textura_boca()
		boca.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _obtener_textura_cuerpo() -> Texture2D:
	if _textura_cuerpo_cache != null:
		return _textura_cuerpo_cache

	var ancho := max(tamano_textura.x, 24)
	var alto := max(tamano_textura.y, 96)
	var imagen := Image.create(ancho, alto, false, Image.FORMAT_RGBA8)
	var centro_x := float(ancho) * 0.5

	for y in range(alto):
		for x in range(ancho):
			var nx := float(x) / float(ancho)
			var ny := float(y) / float(alto)
			var curvatura := absf((x - centro_x) / centro_x)
			var vena := sin((ny * 22.0) + (nx * 13.0)) * 0.08
			var carne := Color(0.52, 0.14, 0.18, 1.0).lerp(Color(0.73, 0.22, 0.28, 1.0), ny * 0.45)
			var sombra := 0.16 + (curvatura * 0.21) + absf(sin((nx * 15.0) + (ny * 6.0))) * 0.05
			carne = carne.darkened(sombra - vena)
			if int(x + (y * 0.4)) % 11 == 0:
				carne = carne.lightened(0.08)
			if int(y + (x * 0.7)) % 17 == 0:
				carne = carne.darkened(0.12)
			if ny < 0.09 or ny > 0.92:
				carne = carne.darkened(0.18)
			imagen.set_pixel(x, y, carne)

	_textura_cuerpo_cache = ImageTexture.create_from_image(imagen)
	return _textura_cuerpo_cache


func _obtener_textura_ojo() -> Texture2D:
	if _textura_ojo_cache != null:
		return _textura_ojo_cache

	var imagen := Image.create(16, 10, false, Image.FORMAT_RGBA8)
	var centro := Vector2(7.5, 4.5)
	for y in range(imagen.get_height()):
		for x in range(imagen.get_width()):
			var punto := Vector2(x, y)
			var distancia := ((punto - centro) / Vector2(7.5, 4.2)).length()
			if distancia <= 1.0:
				var color := Color(0.98, 0.93, 0.72, 1.0)
				if distancia > 0.82:
					color = Color(0.20, 0.06, 0.08, 1.0)
				if absf(x - centro.x) < 1.4:
					color = Color(0.08, 0.03, 0.04, 1.0)
				imagen.set_pixel(x, y, color)
			else:
				imagen.set_pixel(x, y, Color(0, 0, 0, 0))

	_textura_ojo_cache = ImageTexture.create_from_image(imagen)
	return _textura_ojo_cache


func _obtener_textura_boca() -> Texture2D:
	if _textura_boca_cache != null:
		return _textura_boca_cache

	var imagen := Image.create(24, 12, false, Image.FORMAT_RGBA8)
	for y in range(imagen.get_height()):
		for x in range(imagen.get_width()):
			var color := Color(0, 0, 0, 0)
			if y >= 3 and y <= 8 and x >= 2 and x <= 21:
				color = Color(0.25, 0.04, 0.05, 1.0)
				if y == 3 or y == 8 or x == 2 or x == 21:
					color = Color(0.61, 0.16, 0.18, 1.0)
			if y <= 4 and x % 4 == 0 and x >= 4 and x <= 20:
				color = Color(0.95, 0.93, 0.86, 1.0)
			imagen.set_pixel(x, y, color)

	_textura_boca_cache = ImageTexture.create_from_image(imagen)
	return _textura_boca_cache
