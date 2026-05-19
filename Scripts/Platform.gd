extends AnimatableBody2D

@export var alpha_minima_colision: float = 0.78
@export var margen_zona_segura: Vector2 = Vector2(2, 2)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _quiere_colision: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if animation_player :
		animation_player.play("new_animation")
	set_physics_process(true)


func _physics_process(_delta: float) -> void:
	if sprite == null or collision_shape == null:
		return

	_quiere_colision = sprite.modulate.a >= alpha_minima_colision
	if not _quiere_colision:
		collision_shape.disabled = true
		return

	if not collision_shape.disabled:
		return

	if _jugador_ocupa_volumen():
		return

	collision_shape.disabled = false


func _jugador_ocupa_volumen() -> bool:
	if collision_shape == null or collision_shape.shape == null:
		return false

	for candidato in get_tree().get_nodes_in_group("jugador"):
		var jugador := candidato as Node2D
		if jugador == null:
			continue

		var shape_jugador := jugador.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape_jugador != null and _rectangulos_se_superponen(collision_shape, shape_jugador):
			return true

	return false


func _rectangulos_se_superponen(a: CollisionShape2D, b: CollisionShape2D) -> bool:
	if not (a.shape is RectangleShape2D) or not (b.shape is RectangleShape2D):
		return false

	var rect_a := _obtener_rectangulo_global(a)
	rect_a = rect_a.grow_individual(margen_zona_segura.x, margen_zona_segura.y, margen_zona_segura.x, margen_zona_segura.y)
	var rect_b := _obtener_rectangulo_global(b)
	return rect_a.intersects(rect_b)


func _obtener_rectangulo_global(shape_node: CollisionShape2D) -> Rect2:
	var shape_rect := shape_node.shape as RectangleShape2D
	var escala := shape_node.global_scale.abs()
	var tamano := Vector2(shape_rect.size.x * escala.x, shape_rect.size.y * escala.y)
	var centro := shape_node.global_position
	return Rect2(centro - (tamano * 0.5), tamano)
