extends Camera2D
@export var object:Node2D


func seguir_a(nuevo_objetivo: Node2D) -> void:
	object = nuevo_objetivo



func _process(_delta: float) -> void:
	if object != null:
		global_position = object.global_position
