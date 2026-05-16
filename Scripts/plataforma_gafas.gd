extends AnimatableBody2D
class_name PlataformaGafas

@export var alpha_oculta: float = 0.0
@export var alpha_revelada: float = 0.92
@export var duracion_transicion: float = 0.18

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _tween_visual: Tween


func _ready() -> void:
	add_to_group("plataforma_gafas")
	establecer_revelada(false)


func establecer_revelada(activa: bool) -> void:
	if collision_shape != null:
		collision_shape.set_deferred("disabled", not activa)
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
