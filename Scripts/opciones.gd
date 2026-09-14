extends Control

const MENU_SCENE := "res://Escenas/Menu.tscn"


func _on_volver_pressed() -> void:
	var error := get_tree().change_scene_to_file(MENU_SCENE)
	if error != OK:
		push_error("No se pudo volver al menu principal desde la escena de opciones.")
