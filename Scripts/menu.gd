extends Control

const MAIN_GAME_SCENE := "res://Escenas/MainGame.tscn"
const SistemaGuardadoClass = preload("res://Scripts/sistema_guardado.gd")

@onready var boton_jugar: Button = $VBoxContainer/Jugar


func _ready() -> void:
	if boton_jugar != null and SistemaGuardadoClass.existe_guardado():
		boton_jugar.text = "Continuar"


func _on_salir_pressed() -> void:
	get_tree().quit()


func _on_jugar_pressed() -> void:
	var escena_destino := MAIN_GAME_SCENE
	if SistemaGuardadoClass.existe_guardado():
		escena_destino = SistemaGuardadoClass.obtener_escena_inicio()

	get_tree().change_scene_to_file(escena_destino)


func _on_opciones_pressed() -> void:
	MenuOpciones.aparecer()
