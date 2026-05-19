extends Node2D
class_name SombrasPlataformas

@export var ruta_plataformas: NodePath = NodePath("../Plataformas")
@export var y_referencia_superior: float = 170.0
@export var y_referencia_inferior: float = 420.0
@export var alpha_minimo: float = 0.04
@export var alpha_maximo: float = 0.34
@export var color_profundidad: Color = Color(0.012, 0.014, 0.018, 1.0)


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

		var sprite := plataforma.get_node_or_null("Sprite2D") as Sprite2D
		if sprite == null:
			continue

		_aplicar_profundidad(plataforma as Node2D, sprite)


func _aplicar_profundidad(plataforma: Node2D, sprite: Sprite2D) -> void:
	var progreso := inverse_lerp(y_referencia_superior, y_referencia_inferior, plataforma.global_position.y)
	var alpha := lerpf(alpha_minimo, alpha_maximo, clampf(progreso, 0.0, 1.0))
	var luz := 1.0 - clampf(alpha, 0.0, 0.72)
	sprite.self_modulate = Color(luz, luz, luz, 1.0)
