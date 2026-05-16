extends Node2D
class_name FondoMundo1

@export var inicio_x: float = -2048.0
@export var fin_x: float = 16000.0
@export var posicion_y: float = -245.0
@export var escala_base: float = 4.7
@export var escala_vertical: float = 6.0
@export var margen_vertical_superior: float = -1200.0
@export var margen_vertical_inferior: float = 1600.0
@export var color_cielo_base: Color = Color(0.35, 0.68, 0.76, 1.0)

const CAPAS := [
	{
		"ruta": "res://Imagenes/Fondos/Mundo1/fondo_cielo.png",
		"z": -320,
		"modulate": Color(0.78, 0.9, 0.95, 1.0),
		"offset_y": 0.0,
	},
	{
		"ruta": "res://Imagenes/Fondos/Mundo1/fondo_lejano.png",
		"z": -300,
		"modulate": Color(0.36, 0.68, 0.72, 0.48),
		"offset_y": 10.0,
	},
	{
		"ruta": "res://Imagenes/Fondos/Mundo1/fondo_medio.png",
		"z": -290,
		"modulate": Color(0.25, 0.58, 0.62, 0.62),
		"offset_y": 18.0,
	},
	{
		"ruta": "res://Imagenes/Fondos/Mundo1/fondo_frontal.png",
		"z": -280,
		"modulate": Color(0.16, 0.39, 0.43, 0.72),
		"offset_y": 22.0,
	},
	{
		"ruta": "res://Imagenes/Fondos/Mundo1/fondo_arbol_frontal.png",
		"z": -270,
		"modulate": Color(0.08, 0.19, 0.22, 0.82),
		"offset_y": 10.0,
	},
]


func _ready() -> void:
	z_as_relative = false
	_crear_relleno_base()
	for capa in CAPAS:
		_crear_capa(capa)


func _crear_relleno_base() -> void:
	var relleno := Polygon2D.new()
	relleno.z_as_relative = false
	relleno.z_index = -340
	relleno.color = color_cielo_base
	relleno.polygon = PackedVector2Array([
		Vector2(inicio_x - 1024.0, margen_vertical_superior),
		Vector2(fin_x + 1024.0, margen_vertical_superior),
		Vector2(fin_x + 1024.0, margen_vertical_inferior),
		Vector2(inicio_x - 1024.0, margen_vertical_inferior),
	])
	add_child(relleno)


func _crear_capa(capa: Dictionary) -> void:
	var textura := _cargar_textura_png(str(capa["ruta"]))
	if textura == null:
		return

	var ancho := textura.get_width() * escala_base
	if ancho <= 0.0:
		return

	var cantidad := int(ceil((fin_x - inicio_x) / ancho)) + 2
	for indice in range(cantidad):
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.texture = textura
		sprite.scale = Vector2(escala_base, escala_vertical)
		sprite.z_as_relative = false
		sprite.z_index = int(capa["z"])
		sprite.modulate = capa["modulate"]
		sprite.position = Vector2(inicio_x + (indice * ancho), posicion_y + float(capa["offset_y"]))
		add_child(sprite)


func _cargar_textura_png(ruta: String) -> Texture2D:
	var imagen := Image.load_from_file(ProjectSettings.globalize_path(ruta))
	if imagen == null or imagen.is_empty():
		return null

	return ImageTexture.create_from_image(imagen)
