extends Node2D
class_name FondoMundoFinal

@export var inicio_x: float = -2048.0
@export var fin_x: float = 22000.0
@export var posicion_y: float = -395.0
@export var escala_base: float = 4.95
@export var escala_vertical: float = 8.35
@export var margen_vertical_superior: float = -1900.0
@export var margen_vertical_inferior: float = 2600.0
@export var color_cielo_base: Color = Color(0.17, 0.27, 0.37, 1.0)
@export var parallax_activo: bool = true

const CAPAS := [
	{
		"ruta": "res://Imagenes/Fondos/MundoFinal/fondo_01_base.png",
		"z": -360,
		"modulate": Color(0.78, 0.86, 0.92, 0.92),
		"offset_y": -42.0,
		"scroll": 0.08,
	},
	{
		"ruta": "res://Imagenes/Fondos/MundoFinal/fondo_03_nubes.png",
		"z": -350,
		"modulate": Color(0.84, 0.9, 0.95, 0.28),
		"offset_y": -56.0,
		"scroll": 0.16,
	},
	{
		"ruta": "res://Imagenes/Fondos/MundoFinal/fondo_02_montanas.png",
		"z": -340,
		"modulate": Color(0.36, 0.48, 0.58, 0.52),
		"offset_y": -12.0,
		"scroll": 0.26,
	},
	{
		"ruta": "res://Imagenes/Fondos/MundoFinal/fondo_04_montanas_2.png",
		"z": -332,
		"modulate": Color(0.24, 0.34, 0.43, 0.68),
		"offset_y": -4.0,
		"scroll": 0.38,
	},
	{
		"ruta": "res://Imagenes/Fondos/MundoFinal/fondo_05_pilares.png",
		"z": -324,
		"modulate": Color(0.24, 0.3, 0.39, 0.58),
		"offset_y": 6.0,
		"scroll": 0.52,
	},
	{
		"ruta": "res://Imagenes/Fondos/MundoFinal/fondo_06_pilares_2.png",
		"z": -316,
		"modulate": Color(0.18, 0.22, 0.29, 0.76),
		"offset_y": 10.0,
		"scroll": 0.70,
	},
	{
		"ruta": "res://Imagenes/Fondos/MundoFinal/fondo_07_frontal.png",
		"z": 14,
		"modulate": Color(0.055, 0.075, 0.095, 0.48),
		"offset_y": 14.0,
		"scroll": 1.04,
	},
]

var _capas_runtime: Array[Dictionary] = []


func _ready() -> void:
	z_as_relative = false
	_crear_relleno_base()
	for capa in CAPAS:
		_crear_capa(capa)


func _process(_delta: float) -> void:
	if not parallax_activo:
		return

	var camara := get_viewport().get_camera_2d()
	if camara == null:
		return

	for datos in _capas_runtime:
		var capa_nodo := datos.get("nodo") as Node2D
		if capa_nodo == null or not is_instance_valid(capa_nodo):
			continue

		var scroll := float(datos.get("scroll", 1.0))
		capa_nodo.position.x = camara.global_position.x * (1.0 - scroll)


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

	var capa_nodo := Node2D.new()
	capa_nodo.name = "Capa_%s" % str(capa["z"])
	capa_nodo.z_as_relative = false
	capa_nodo.z_index = int(capa["z"])
	add_child(capa_nodo)
	_capas_runtime.append({
		"nodo": capa_nodo,
		"scroll": float(capa.get("scroll", 1.0)),
	})

	var cantidad := int(ceil((fin_x - inicio_x) / ancho)) + 2
	for indice in range(cantidad):
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.texture = textura
		sprite.scale = Vector2(escala_base, escala_vertical)
		sprite.z_as_relative = true
		sprite.z_index = 0
		sprite.modulate = capa["modulate"]
		sprite.position = Vector2(inicio_x + (indice * ancho), posicion_y + float(capa["offset_y"]))
		capa_nodo.add_child(sprite)


func _cargar_textura_png(ruta: String) -> Texture2D:
	var imagen := Image.load_from_file(ProjectSettings.globalize_path(ruta))
	if imagen == null or imagen.is_empty():
		return null

	return ImageTexture.create_from_image(imagen)
