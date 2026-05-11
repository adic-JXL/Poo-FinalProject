extends Camera2D
@export var object:Node2D
@onready var detector: CollisionShape2D = $"../Area2D/Area1"
@onready var camara_1: Camera2D = $"."



	



func _process(_delta: float) -> void:
	if object != null :
		position = object.position


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Jugador":
		enabled = true
		make_current()
		

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Jugador":
		enabled = false
