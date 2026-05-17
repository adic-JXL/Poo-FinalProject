extends Node2D
class_name FarolDecorativo

@export var intensidad_luz: float = 1.0
@export var escala_aura: float = 1.0
@export var velocidad_parpadeo: float = 2.6
@export var amplitud_parpadeo: float = 0.08
@export var velocidad_balanceo: float = 1.35
@export var amplitud_balanceo_grados: float = 1.25

var _fase_animacion: float = 0.0

@onready var lampara: Node2D = $Lampara
@onready var glow_exterior: Polygon2D = $Lampara/GlowExterior
@onready var glow_interior: Polygon2D = $Lampara/GlowInterior
@onready var cristal: Polygon2D = $Lampara/Cristal
@onready var llama: Polygon2D = $Lampara/Llama
@onready var reflejo: Polygon2D = $Lampara/Reflejo


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_fase_animacion = rng.randf_range(0.0, TAU)
	_actualizar_farol(0.0)


func _process(_delta: float) -> void:
	_actualizar_farol(Time.get_ticks_msec() * 0.001)


func _actualizar_farol(tiempo: float) -> void:
	var onda_principal := sin((tiempo * velocidad_parpadeo) + _fase_animacion)
	var onda_secundaria := sin((tiempo * velocidad_parpadeo * 1.83) + (_fase_animacion * 0.63))
	var pulso := clampf(
		1.0 + (onda_principal * amplitud_parpadeo) + (onda_secundaria * amplitud_parpadeo * 0.45),
		0.84,
		1.18
	)
	var balanceo := sin((tiempo * velocidad_balanceo) + (_fase_animacion * 0.5)) * amplitud_balanceo_grados

	if lampara != null:
		lampara.rotation_degrees = balanceo

	if glow_interior != null:
		glow_interior.scale = Vector2.ONE * (escala_aura * pulso)
		glow_interior.color = Color(0.97, 0.92, 0.58, 0.26 * intensidad_luz * minf(pulso, 1.08))

	if glow_exterior != null:
		var escala_exterior := escala_aura * (1.18 + ((pulso - 1.0) * 0.55))
		glow_exterior.scale = Vector2.ONE * escala_exterior
		glow_exterior.color = Color(0.38, 0.83, 0.95, 0.12 * intensidad_luz * minf(pulso, 1.05))

	if cristal != null:
		var brillo_cristal := clampf(0.9 + (pulso * 0.07), 0.88, 1.0)
		cristal.color = Color(0.84 * brillo_cristal, 0.8 * brillo_cristal, 0.46 * brillo_cristal, 0.9)

	if llama != null:
		llama.position.y = -1.0 + (onda_secundaria * 0.75)
		var escala_llama := 0.96 + (onda_principal * 0.04)
		llama.scale = Vector2.ONE * escala_llama

	if reflejo != null:
		reflejo.color = Color(1.0, 1.0, 1.0, 0.16 * intensidad_luz * (0.94 + (onda_principal * 0.1)))
