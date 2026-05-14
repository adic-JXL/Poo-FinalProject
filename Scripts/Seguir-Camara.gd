extends Camera2D
@export var object:Node2D
@onready var detector: CollisionShape2D = $"../Area2D/Area1"
@onready var camara_1: Camera2D = $"."



	



func _process(_delta: float) -> void:
	if object != null :
		position = object.position


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("jugador"):
		return

	enabled = true
	make_current()
	_desactivar_otras_camaras()
		

func _on_area_2d_body_exited(body: Node2D) -> void:
	pass


func _desactivar_otras_camaras() -> void:
	var contenedor := get_parent()
	if contenedor == null:
		return

	for child in contenedor.get_children():
		if child is Camera2D and child != self:
			(child as Camera2D).enabled = false
