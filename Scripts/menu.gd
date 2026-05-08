extends Control

const MAIN_GAME_SCENE := "res://Escenas/MainGame.tscn"


const OPTIONS_SCENE := "res://Escenas/MenuOpciones.tscn"


func _change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

func _on_salir_pressed() -> void:
	get_tree().quit()


func _on_jugar_pressed() -> void:
	_change_scene(MAIN_GAME_SCENE)


func _on_opciones_pressed() -> void:
	_change_scene(OPTIONS_SCENE)
