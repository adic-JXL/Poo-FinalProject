extends Camera2D
@onready var jugador: Jugador = $"../Jugador"
@onready var camara_2: Camera2D = $"."
@export var object:Node2D


func _ready() -> void:
	enabled = false

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	camara_2.position = jugador.position
	



	


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.name == "Jugador":
		enabled = true
		make_current()
		var camara_1: Camera2D = $"../Camara1"
		if camara_1 != null:
			camara_1.enabled = false


func _on_area_2d_2_body_exited(body: Node2D) -> void:
	pass
