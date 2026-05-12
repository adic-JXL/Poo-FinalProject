extends AnimatableBody2D
class_name PlataformaGafas

@export var alpha_oculta: float = 0.0
@export var alpha_revelada: float = 0.92

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("plataforma_gafas")
	establecer_revelada(false)


func establecer_revelada(activa: bool) -> void:
	sprite.modulate.a = alpha_revelada if activa else alpha_oculta
	collision_shape.set_deferred("disabled", not activa)


func esta_revelada() -> bool:
	return not collision_shape.disabled
