extends Control

const MENU_SCENE := "res://Escenas/Menu.tscn"


func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
