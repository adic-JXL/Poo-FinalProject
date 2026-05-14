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
	_activar_camara_si_jugador(body)


func _on_area_2d_2_body_exited(body: Node2D) -> void:
	pass


func _on_area_2d_3_body_entered(body: Node2D) -> void:
	_activar_camara_si_jugador(body)


func _on_area_2d_3_body_exited(body: Node2D) -> void:
	pass


func _activar_camara_si_jugador(body: Node) -> void:
	if body == null or not body.is_in_group("jugador"):
		return

	enabled = true
	make_current()
	_desactivar_otras_camaras()


func _desactivar_otras_camaras() -> void:
	var contenedor := get_parent()
	if contenedor == null:
		return

	for child in contenedor.get_children():
		if child is Camera2D and child != self:
			(child as Camera2D).enabled = false
