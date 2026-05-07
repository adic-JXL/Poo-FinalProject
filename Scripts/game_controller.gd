extends Node2D
class_name GameController

const MENU_SCENE := "res://Escenas/Menu.tscn"

@onready var estado_label: Label = $CanvasLayer/MarginContainer/PanelContainer/VBoxContainer/EstadoLabel


func _ready() -> void:
	iniciar_juego()


func iniciar_juego() -> void:
	estado_label.text = "Base tecnica lista para empezar a construir el nivel."


func cargar_nivel(_id: int = 0) -> void:
	estado_label.text = "Escena principal preparada para integrar Jugador, Nivel y HUD."


func reiniciar_nivel() -> void:
	get_tree().reload_current_scene()


func finalizar_nivel() -> void:
	estado_label.text = "Nivel finalizado."


func _on_volver_menu_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
