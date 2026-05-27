extends "res://Scripts/interactivo_base.gd"
class_name LlaveInteractiva

@export var rutas_frames: PackedStringArray = []
@export var fps_animacion: float = 7.0
@export var amplitud_flotacion: float = 2.8
@export var velocidad_flotacion: float = 1.9
@export var amplitud_giro_grados: float = 6.0

var _reclamada: bool = false
var _fase_animacion: float = 0.0
var _frames: Array[Texture2D] = []
var _indice_frame: int = 0
var _tiempo_frame: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var _posicion_base_sprite: Vector2 = Vector2.ZERO


func _ready() -> void:
	super()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_fase_animacion = rng.randf_range(0.0, TAU)
	_cargar_frames()
	if sprite != null:
		_posicion_base_sprite = sprite.position


func _process(_delta: float) -> void:
	if _reclamada or sprite == null:
		return

	var tiempo := Time.get_ticks_msec() * 0.001
	sprite.position.y = _posicion_base_sprite.y + (sin((tiempo * velocidad_flotacion) + _fase_animacion) * amplitud_flotacion)
	sprite.rotation_degrees = sin((tiempo * velocidad_flotacion * 0.75) + (_fase_animacion * 0.35)) * amplitud_giro_grados
	_actualizar_animacion(_delta)


func puede_interactuar() -> bool:
	return not _reclamada


func otorgar_llave() -> void:
	_reclamada = true
	collision_shape.set_deferred("disabled", true)
	if sprite != null:
		sprite.rotation_degrees = 0.0
	desactivar_interaccion()
	hide()


func _actualizar_animacion(delta: float) -> void:
	if sprite == null or _frames.size() <= 1:
		return

	_tiempo_frame += delta
	if _tiempo_frame < 1.0 / max(fps_animacion, 0.1):
		return

	_tiempo_frame = 0.0
	_indice_frame = (_indice_frame + 1) % _frames.size()
	sprite.texture = _frames[_indice_frame]


func _cargar_frames() -> void:
	_frames.clear()
	for ruta in rutas_frames:
		var textura := _cargar_textura_png(ruta)
		if textura != null:
			_frames.append(textura)

	if sprite != null and not _frames.is_empty():
		sprite.texture = _frames[0]


func _cargar_textura_png(ruta: String) -> Texture2D:
	var textura_importada := load(ruta) as Texture2D
	if textura_importada != null:
		return textura_importada

	var imagen := Image.load_from_file(ProjectSettings.globalize_path(ruta))
	if imagen == null or imagen.is_empty():
		return null

	return ImageTexture.create_from_image(imagen)
