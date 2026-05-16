extends Node2D
class_name SombrasPlataformas

@export var ruta_plataformas: NodePath = NodePath("../Plataformas")
@export var desplazamiento_sombra: Vector2 = Vector2(10, 17)
@export var altura_sombra: float = 20.0
@export var color_sombra: Color = Color(0.015, 0.018, 0.022, 0.34)


func _ready() -> void:
	z_as_relative = false
	z_index = -40
	call_deferred("_crear_sombras")


func _crear_sombras() -> void:
	var plataformas := get_node_or_null(ruta_plataformas)
	if plataformas == null:
		return

	for plataforma in plataformas.get_children():
		if not (plataforma is Node2D):
			continue

		var ancho := _obtener_ancho_plataforma(plataforma)
		if ancho <= 0.0:
			continue

		_crear_sombra(plataforma as Node2D, ancho)


func _crear_sombra(plataforma: Node2D, ancho: float) -> void:
	var sombra := Polygon2D.new()
	var mitad := ancho * 0.5
	sombra.z_as_relative = false
	sombra.z_index = z_index
	sombra.color = color_sombra
	sombra.polygon = PackedVector2Array([
		Vector2(-mitad + 7.0, 0.0),
		Vector2(mitad + 16.0, 0.0),
		Vector2(mitad + 4.0, altura_sombra),
		Vector2(-mitad - 12.0, altura_sombra),
	])
	add_child(sombra)
	sombra.global_position = plataforma.global_position + desplazamiento_sombra


func _obtener_ancho_plataforma(plataforma: Node) -> float:
	var sprite := plataforma.get_node_or_null("Sprite2D") as Sprite2D
	if sprite != null:
		var rect := sprite.region_rect if sprite.region_enabled else Rect2(Vector2.ZERO, sprite.texture.get_size())
		return rect.size.x * absf(sprite.global_scale.x)

	var shape := plataforma.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape != null and shape.shape is RectangleShape2D:
		return (shape.shape as RectangleShape2D).size.x * absf(shape.global_scale.x)

	return 0.0
