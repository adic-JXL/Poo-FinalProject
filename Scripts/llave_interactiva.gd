extends "res://Scripts/interactivo_base.gd"
class_name LlaveInteractiva

@export var amplitud_flotacion: float = 2.8
@export var velocidad_flotacion: float = 1.9
@export var amplitud_giro_grados: float = 6.0

var _reclamada: bool = false
var _fase_animacion: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var _posicion_base_sprite: Vector2 = Vector2.ZERO


func _ready() -> void:
	super()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_fase_animacion = rng.randf_range(0.0, TAU)
	if sprite != null:
		_posicion_base_sprite = sprite.position


func _process(_delta: float) -> void:
	if _reclamada or sprite == null:
		return

	var tiempo := Time.get_ticks_msec() * 0.001
	sprite.position.y = _posicion_base_sprite.y + (sin((tiempo * velocidad_flotacion) + _fase_animacion) * amplitud_flotacion)
	sprite.rotation_degrees = sin((tiempo * velocidad_flotacion * 0.75) + (_fase_animacion * 0.35)) * amplitud_giro_grados


func puede_interactuar() -> bool:
	return not _reclamada


func otorgar_llave() -> void:
	_reclamada = true
	collision_shape.set_deferred("disabled", true)
	if sprite != null:
		sprite.rotation_degrees = 0.0
	desactivar_interaccion()
	hide()
