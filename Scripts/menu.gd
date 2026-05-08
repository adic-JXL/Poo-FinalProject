extends Control

<<<<<<< HEAD
const MAIN_GAME_SCENE := "res://Escenas/MainGame.tscn"


const OPTIONS_SCENE := "res://Escenas/MenuOpciones.tscn"

=======
>>>>>>> Manu2


func _on_salir_pressed() -> void:
	get_tree().quit()


func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/MainGame.tscn")


func _on_opciones_pressed() -> void:
	_change_scene(OPTIONS_SCENE)
