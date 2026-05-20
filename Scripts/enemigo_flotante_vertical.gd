extends "res://Scripts/enemigo_flotante_base.gd"
class_name EnemigoFlotanteVertical


func obtener_eje_flotacion() -> Vector2:
	return Vector2.UP


func _actualizar_visual(_eje: Vector2) -> void:
	visual.rotation = -PI * 0.08 if _direccion_actual < 0.0 else PI * 0.08
