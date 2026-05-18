extends Node2D
class_name FondoMundoFinal

@export var inicio_x: float = -2048.0
@export var fin_x: float = 22000.0
@export var posicion_y: float = -276.0
@export var escala_base: float = 4.8
@export var escala_vertical: float = 5.6
@export var margen_vertical_superior: float = -1450.0
@export var margen_vertical_inferior: float = 1800.0
@export var color_cielo_base: Color = Color(0.17, 0.27, 0.37, 1.0)

const CAPAS := [
	{
		"ruta": "res://Imagenes/Fondos/MundoFinal/fondo_01_base.png",
		"z": -360,
		"modulate": Color(0.78, 0.86, 0.92, 0.92),
		"offset_y": -16.0,
	},
	{
		"ruta": "res://Imagenes/Fondos/MundoFinal/fondo_03_nubes.png",
		"z": -350,
		"modulate": Color(0.84, 0.9, 0.95, 0.28),
		"offset_y": -22.0,
	},
	{
		"ruta": "res://Imagenes/Fondos/MundoFinal/fondo_02_montanas.png",
		"z": -340,
		"modulate": Color(0.36, 0.48, 0.58, 0.52),
		"offset_y": 8.0,
	},
	{
		"ruta": "res://Imagenes/Fondos/MundoFinal/fondo_04_montanas_2.png",
		"z": -332,
		"modulate": Color(0.24, 0.34, 0.43, 0.68),
		"offset_y": 18.0,
	},
	{
		"ruta": "res://Imagenes/Fondos/MundoFinal/fondo_05_pilares.png",
		"z": -324,
		"modulate": Color(0.24, 0.3, 0.39, 0.58),
		"offset_y": 18.0,
	},
	{
		"ruta": "res://Imagenes/Fondos/MundoFinal/fondo_06_pilares_2.png",
		"z": -316,
		"modulate": Color(0.18, 0.22, 0.29, 0.76),
		"offset_y": 24.0,
	},
	{
		"ruta": "res://Imagenes/Fondos/MundoFinal/fondo_07_frontal.png",
		"z": -308,
		"modulate": Color(0.1, 0.13, 0.17, 0.9),
		"offset_y": 30.0,
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
	relleno.z_index = -380
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
