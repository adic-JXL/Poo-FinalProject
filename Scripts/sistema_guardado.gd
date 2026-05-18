extends RefCounted
class_name SistemaGuardado

const RUTA_GUARDADO := "user://deep_shadow_save.cfg"
const ESCENA_MAIN_GAME := "res://Escenas/MainGame.tscn"
const ESCENA_MUNDO_2 := "res://Escenas/Mundo2.tscn"


static func existe_guardado() -> bool:
	return FileAccess.file_exists(RUTA_GUARDADO)


static func obtener_escena_inicio() -> String:
	var datos := cargar_datos()
	var escena: String = String(datos.get("escena_actual", ESCENA_MAIN_GAME))
	if ResourceLoader.exists(escena):
		return escena

	return ESCENA_MAIN_GAME


static func cargar_datos() -> Dictionary:
	var config := ConfigFile.new()
	var resultado := config.load(RUTA_GUARDADO)
	if resultado != OK:
		return {}

	return {
		"escena_actual": String(config.get_value("general", "escena_actual", ESCENA_MAIN_GAME)),
		"main_game": Dictionary(config.get_value("main_game", "datos", {})),
		"mundo_2": Dictionary(config.get_value("mundo_2", "datos", {})),
	}


static func guardar_estado_main_game(datos: Dictionary) -> void:
	var config := _cargar_config_existente()
	config.set_value("general", "escena_actual", ESCENA_MAIN_GAME)
	config.set_value("main_game", "datos", datos.duplicate(true))
	config.save(RUTA_GUARDADO)


static func guardar_estado_mundo_2(datos: Dictionary) -> void:
	var config := _cargar_config_existente()
	config.set_value("general", "escena_actual", ESCENA_MUNDO_2)
	config.set_value("mundo_2", "datos", datos.duplicate(true))
	config.save(RUTA_GUARDADO)


static func _cargar_config_existente() -> ConfigFile:
	var config := ConfigFile.new()
	config.load(RUTA_GUARDADO)
	return config
