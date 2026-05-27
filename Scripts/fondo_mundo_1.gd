extends Node2D
class_name FondoMundo1

@export var inicio_x: float = -2048.0
@export var fin_x: float = 16000.0
@export var posicion_y: float = -315.0
@export var escala_base: float = 4.7
@export var escala_vertical: float = 7.2
@export var margen_vertical_superior: float = -1200.0
@export var margen_vertical_inferior: float = 2400.0
@export var color_cielo_base: Color = Color(0.35, 0.68, 0.76, 1.0)
@export var parallax_activo: bool = true

const CAPAS := [
	{
		"ruta": "res://Imagenes/Fondos/Mundo1/fondo_cielo.png",
		"z": -320,
		"modulate": Color(0.78, 0.9, 0.95, 1.0),
		"offset_y": 0.0,
		"scroll": 0.08,
	},
	{
		"ruta": "res://Imagenes/Fondos/Mundo1/fondo_lejano.png",
		"z": -300,
		"modulate": Color(0.36, 0.68, 0.72, 0.48),
		"offset_y": 10.0,
		"scroll": 0.18,
	},
	{
		"ruta": "res://Imagenes/Fondos/Mundo1/fondo_medio.png",
		"z": -290,
		"modulate": Color(0.25, 0.58, 0.62, 0.62),
		"offset_y": 18.0,
		"scroll": 0.34,
	},
	{
		"ruta": "res://Imagenes/Fondos/Mundo1/fondo_frontal.png",
		"z": -280,
		"modulate": Color(0.16, 0.39, 0.43, 0.72),
		"offset_y": 22.0,
		"scroll": 0.62,
	},
	{
		"ruta": "res://Imagenes/Fondos/Mundo1/fondo_arbol_frontal.png",
		"z": 14,
		"modulate": Color(0.05, 0.12, 0.14, 0.46),
		"offset_y": 10.0,
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
		capa_nodo.position.x = camara.get_screen_center_position().x * (1.0 - scroll)


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
	var textura_importada := load(ruta) as Texture2D
	if textura_importada != null:
		return textura_importada

	var imagen := Image.load_from_file(ProjectSettings.globalize_path(ruta))
	if imagen == null or imagen.is_empty():
		return null

	return ImageTexture.create_from_image(imagen)
