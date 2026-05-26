extends "res://Scripts/interactivo_base.gd"
class_name AltarGafas

@export var color_inactivo: Color = Color(0.278431, 0.686275, 0.909804, 0.85)
@export var color_activo: Color = Color(0.988235, 0.866667, 0.364706, 0.98)
@export var velocidad_animacion_icono: float = 7.0

const RUTAS_ICONO_GAFAS := [
	"res://Imagenes/Objetos/gafas_00.png",
	"res://Imagenes/Objetos/gafas_01.png",
	"res://Imagenes/Objetos/gafas_02.png",
]

var _resuelto: bool = false
var _frames_icono: Array[Texture2D] = []
var _tiempo_frame_icono: float = 0.0
var _indice_frame_icono: int = 0

@onready var base_visual: Polygon2D = $BaseVisual
@onready var simbolo_visual: Polygon2D = $SimboloVisual
@onready var icono_visual: Sprite2D = get_node_or_null("IconoVisual") as Sprite2D


func _ready() -> void:
	super()
	mensaje_interaccion = "Presiona E para enfocar los simbolos del altar."
	_cargar_icono_gafas()
	_actualizar_visual()


func _process(delta: float) -> void:
	if icono_visual == null or _frames_icono.is_empty():
		return

	_tiempo_frame_icono += delta
	if _tiempo_frame_icono < 1.0 / max(velocidad_animacion_icono, 0.1):
		return

	_tiempo_frame_icono = 0.0
	_indice_frame_icono = (_indice_frame_icono + 1) % _frames_icono.size()
	icono_visual.texture = _frames_icono[_indice_frame_icono]


func puede_interactuar() -> bool:
	return not _resuelto


func marcar_resuelto() -> void:
	_resuelto = true
	_actualizar_visual()
	desactivar_interaccion()


func esta_resuelto() -> bool:
	return _resuelto


func _actualizar_visual() -> void:
	var color_objetivo := color_activo if _resuelto else color_inactivo
	if base_visual != null:
		base_visual.color = color_objetivo

	if simbolo_visual != null:
		simbolo_visual.color = color_objetivo.lightened(0.12)

	if icono_visual != null:
		icono_visual.modulate = Color(1.0, 1.0, 1.0, 0.95) if _resuelto else Color(0.78, 0.95, 1.0, 0.9)


func _cargar_icono_gafas() -> void:
	_frames_icono.clear()
	for ruta in RUTAS_ICONO_GAFAS:
		var textura := _cargar_textura_png(ruta)
		if textura != null:
			_frames_icono.append(textura)

	if icono_visual != null and not _frames_icono.is_empty():
		icono_visual.texture = _frames_icono[0]


func _cargar_textura_png(ruta: String) -> Texture2D:
	var imagen := Image.load_from_file(ProjectSettings.globalize_path(ruta))
	if imagen == null or imagen.is_empty():
		return null

	return ImageTexture.create_from_image(imagen)
