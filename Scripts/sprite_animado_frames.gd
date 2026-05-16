extends Node2D
class_name SpriteAnimadoFrames

@export var rutas_frames: PackedStringArray = []
@export var fps: float = 7.0
@export var reproducir: bool = true

var _frames: Array[Texture2D] = []
var _indice_frame: int = 0
var _tiempo_frame: float = 0.0

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D


func _ready() -> void:
	_cargar_frames()
	set_process(reproducir and _frames.size() > 1)


func _process(delta: float) -> void:
	if sprite == null or _frames.is_empty() or not reproducir:
		return

	_tiempo_frame += delta
	if _tiempo_frame < 1.0 / max(fps, 0.1):
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
	var imagen := Image.load_from_file(ProjectSettings.globalize_path(ruta))
	if imagen == null or imagen.is_empty():
		return null

	return ImageTexture.create_from_image(imagen)
