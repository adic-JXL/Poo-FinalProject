extends AnimatableBody2D
class_name PlataformaGafas

@export var alpha_oculta: float = 0.0
@export var alpha_revelada: float = 0.92
@export var duracion_transicion: float = 0.18
@export var margen_zona_segura: Vector2 = Vector2(14, 12)

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _tween_visual: Tween
var _activacion_colision_pendiente: bool = false


func _ready() -> void:
	add_to_group("plataforma_gafas")
	set_physics_process(false)
	establecer_revelada(false)


func establecer_revelada(activa: bool) -> void:
	if activa:
		_programar_colision_segura()
	else:
		_activacion_colision_pendiente = false
		set_physics_process(false)
		collision_shape.set_deferred("disabled", true)

	_animar_alpha(alpha_revelada if activa else alpha_oculta)


func esta_revelada() -> bool:
	return not collision_shape.disabled


func _animar_alpha(alpha_objetivo: float) -> void:
	if sprite == null:
		return

	if _tween_visual != null and _tween_visual.is_valid():
		_tween_visual.kill()

	_tween_visual = create_tween()
	_tween_visual.set_trans(Tween.TRANS_SINE)
	_tween_visual.set_ease(Tween.EASE_IN_OUT)
	_tween_visual.set_ignore_time_scale(true)
	_tween_visual.tween_property(sprite, "modulate:a", alpha_objetivo, duracion_transicion)


func _physics_process(_delta: float) -> void:
	if not _activacion_colision_pendiente:
		return

	if _jugador_superpone_colision():
		return

	_activacion_colision_pendiente = false
	set_physics_process(false)
	collision_shape.set_deferred("disabled", false)


func _programar_colision_segura() -> void:
	if collision_shape == null:
		return

	if _jugador_superpone_colision():
		_activacion_colision_pendiente = true
		set_physics_process(true)
		collision_shape.set_deferred("disabled", true)
		return

	_activacion_colision_pendiente = false
	set_physics_process(false)
	collision_shape.set_deferred("disabled", false)


func _jugador_superpone_colision() -> bool:
	if collision_shape == null or collision_shape.shape == null or get_world_2d() == null:
		return false

	for candidato in get_tree().get_nodes_in_group("jugador"):
		var jugador = candidato as Node2D
		if jugador == null:
			continue

		var shape_jugador := jugador.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape_jugador != null and _shapes_rectangulares_se_superponen(collision_shape, shape_jugador):
			return true

	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = collision_shape.shape
	consulta.transform = collision_shape.global_transform
	consulta.collide_with_areas = false
	consulta.collide_with_bodies = true
	consulta.exclude = [get_rid()]

	for resultado in get_world_2d().direct_space_state.intersect_shape(consulta, 8):
		var collider = resultado.get("collider")
		if collider != null and collider.is_in_group("jugador"):
			return true

	return false


func _shapes_rectangulares_se_superponen(a: CollisionShape2D, b: CollisionShape2D) -> bool:
	if a == null or b == null:
		return false

	if not (a.shape is RectangleShape2D) or not (b.shape is RectangleShape2D):
		return false

	var rect_a := _obtener_rectangulo_global(a)
	rect_a = rect_a.grow_individual(margen_zona_segura.x, margen_zona_segura.y, margen_zona_segura.x, margen_zona_segura.y)
	var rect_b := _obtener_rectangulo_global(b)
	return rect_a.intersects(rect_b)


func _obtener_rectangulo_global(shape_node: CollisionShape2D) -> Rect2:
	var shape_rect := shape_node.shape as RectangleShape2D
	var tamano := shape_rect.size
	var centro := shape_node.global_position
	return Rect2(centro - (tamano * 0.5), tamano)
