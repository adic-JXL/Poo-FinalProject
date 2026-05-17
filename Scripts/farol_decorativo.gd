extends Node2D
class_name FarolDecorativo

@export var intensidad_luz: float = 1.0
@export var escala_aura: float = 1.0
@export var energia_base: float = 0.88
@export var velocidad_parpadeo: float = 2.9
@export var amplitud_parpadeo: float = 0.11
@export var velocidad_llama: float = 4.2
@export var altura_llama: float = 0.9

var _fase_animacion: float = 0.0
static var _textura_radial_cache: Texture2D
static var _textura_particula_cache: Texture2D

@onready var antorcha: Node2D = $Lampara
@onready var sombra_entorno: Sprite2D = $Lampara/SombraEntorno
@onready var aura_exterior: Sprite2D = $Lampara/AuraExterior
@onready var aura_interior: Sprite2D = $Lampara/AuraInterior
@onready var point_light: PointLight2D = $Lampara/PointLight2D
@onready var llama_exterior: Polygon2D = $Lampara/LlamaExterior
@onready var llama_interior: Polygon2D = $Lampara/LlamaInterior
@onready var brasa: Polygon2D = $Lampara/Brasa
@onready var chispa: Polygon2D = $Lampara/Chispa
@onready var particulas_chispa: CPUParticles2D = $Lampara/Chispas
@onready var particulas_humo: CPUParticles2D = $Lampara/Humo


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_fase_animacion = rng.randf_range(0.0, TAU)
	var textura_radial := _obtener_textura_radial()
	if sombra_entorno != null:
		sombra_entorno.texture = textura_radial
	if aura_exterior != null:
		aura_exterior.texture = textura_radial
	if aura_interior != null:
		aura_interior.texture = textura_radial
	if point_light != null:
		point_light.texture = textura_radial
	_configurar_particulas()
	_actualizar_farol(0.0)


func _process(_delta: float) -> void:
	_actualizar_farol(Time.get_ticks_msec() * 0.001)


func _actualizar_farol(tiempo: float) -> void:
	var onda_principal := sin((tiempo * velocidad_parpadeo) + _fase_animacion)
	var onda_secundaria := sin((tiempo * velocidad_llama) + (_fase_animacion * 0.63))
	var pulso := clampf(
		1.0 + (onda_principal * amplitud_parpadeo) + (onda_secundaria * amplitud_parpadeo * 0.45),
		0.82,
		1.24
	)

	if aura_exterior != null:
		aura_exterior.scale = Vector2.ONE * (0.72 * escala_aura * (1.0 + ((pulso - 1.0) * 0.18)))
		aura_exterior.modulate = Color(1.0, 0.76, 0.32, 0.26 * intensidad_luz * minf(pulso, 1.12))

	if sombra_entorno != null:
		sombra_entorno.scale = Vector2.ONE * (1.42 * escala_aura * (1.0 + ((pulso - 1.0) * 0.08)))
		sombra_entorno.modulate = Color(0.02, 0.03, 0.05, 0.18)

	if aura_interior != null:
		aura_interior.scale = Vector2.ONE * (0.42 * escala_aura * pulso)
		aura_interior.modulate = Color(1.0, 0.94, 0.64, 0.34 * intensidad_luz * minf(pulso, 1.16))

	if point_light != null:
		point_light.energy = energia_base * intensidad_luz * (0.94 + ((pulso - 1.0) * 1.65))
		point_light.texture_scale = 1.28 * escala_aura * (0.98 + ((pulso - 1.0) * 0.35))
		point_light.color = Color(1.0, 0.78, 0.42, 1.0)

	if antorcha != null:
		antorcha.position.x = onda_secundaria * 0.25

	if llama_exterior != null:
		llama_exterior.position = Vector2(onda_principal * 0.6, -18.0 + (onda_secundaria * altura_llama))
		llama_exterior.scale = Vector2(1.0 + (onda_principal * 0.05), 1.0 + (onda_secundaria * 0.08))
		llama_exterior.color = Color(1.0, 0.62 + (pulso * 0.08), 0.22, 0.95)

	if llama_interior != null:
		llama_interior.position = Vector2(onda_principal * 0.35, -18.5 + (onda_secundaria * (altura_llama * 0.7)))
		llama_interior.scale = Vector2(1.0 + (onda_principal * 0.03), 1.0 + (onda_secundaria * 0.06))
		llama_interior.color = Color(1.0, 0.95, 0.7, 0.98)

	if brasa != null:
		brasa.color = Color(0.95, 0.4 + (pulso * 0.1), 0.14, 0.9)

	if chispa != null:
		chispa.position = Vector2(onda_secundaria * 0.8, -24.0 + (onda_principal * 1.2))
		chispa.color = Color(1.0, 0.98, 0.82, 0.86 * minf(pulso, 1.1))

	if particulas_chispa != null:
		particulas_chispa.position = Vector2(0.0, -18.0)

	if particulas_humo != null:
		particulas_humo.position = Vector2(0.0, -21.0)


func _obtener_textura_radial() -> Texture2D:
	if _textura_radial_cache != null:
		return _textura_radial_cache

	_textura_radial_cache = _crear_textura_radial(144)
	return _textura_radial_cache


func _obtener_textura_particula() -> Texture2D:
	if _textura_particula_cache != null:
		return _textura_particula_cache

	_textura_particula_cache = _crear_textura_radial(18)
	return _textura_particula_cache


func _configurar_particulas() -> void:
	var textura_particula := _obtener_textura_particula()

	if particulas_chispa != null:
		particulas_chispa.texture = textura_particula
		particulas_chispa.amount = 6
		particulas_chispa.lifetime = 0.55
		particulas_chispa.one_shot = false
		particulas_chispa.explosiveness = 0.0
		particulas_chispa.randomness = 0.72
		particulas_chispa.direction = Vector2(0.0, -1.0)
		particulas_chispa.spread = 20.0
		particulas_chispa.gravity = Vector2(0.0, -4.0)
		particulas_chispa.initial_velocity_min = 9.0
		particulas_chispa.initial_velocity_max = 16.0
		particulas_chispa.scale_amount_min = 0.14
		particulas_chispa.scale_amount_max = 0.28
		particulas_chispa.modulate = Color(1.0, 0.86, 0.48, 0.68)
		particulas_chispa.emitting = true

	if particulas_humo != null:
		particulas_humo.texture = textura_particula
		particulas_humo.amount = 4
		particulas_humo.lifetime = 1.3
		particulas_humo.one_shot = false
		particulas_humo.explosiveness = 0.0
		particulas_humo.randomness = 0.58
		particulas_humo.direction = Vector2(0.0, -1.0)
		particulas_humo.spread = 14.0
		particulas_humo.gravity = Vector2(0.0, -3.0)
		particulas_humo.initial_velocity_min = 4.0
		particulas_humo.initial_velocity_max = 8.0
		particulas_humo.scale_amount_min = 0.32
		particulas_humo.scale_amount_max = 0.55
		particulas_humo.modulate = Color(0.18, 0.2, 0.24, 0.18)
		particulas_humo.emitting = true


func _crear_textura_radial(size: int) -> Texture2D:
	var imagen := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var centro := Vector2(size * 0.5, size * 0.5)
	var radio := size * 0.5

	for y in range(size):
		for x in range(size):
			var distancia := Vector2(x, y).distance_to(centro) / radio
			var borde := clampf(1.0 - distancia, 0.0, 1.0)
			var alpha := borde * borde * (3.0 - (2.0 * borde))
			alpha = pow(alpha, 1.6)
			imagen.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))

	return ImageTexture.create_from_image(imagen)
