extends RefCounted
class_name SistemaGuardado

const PREFIJO_GUARDADO := "user://deep_shadow_save_slot_%d.cfg"
const ESCENA_MAIN_GAME := "res://Escenas/MainGame.tscn"
const ESCENA_MUNDO_2 := "res://Escenas/Mundo2.tscn"
const TOTAL_SLOTS := 3

static var _slot_activo: int = 1
static var _transicion_pendiente: Dictionary = {}
static var _intro_nueva_partida_pendiente: bool = false
static var _skin_jugador_activa: String = "girl"


static func establecer_slot_activo(slot: int) -> void:
	_slot_activo = clampi(slot, 1, TOTAL_SLOTS)


static func obtener_slot_activo() -> int:
	return _slot_activo


static func existe_guardado(slot: int = -1) -> bool:
	return FileAccess.file_exists(_obtener_ruta_guardado(slot))


static func obtener_escena_inicio(slot: int = -1) -> String:
	var datos := cargar_datos(slot)
	var escena: String = String(datos.get("escena_actual", ESCENA_MAIN_GAME))
	if ResourceLoader.exists(escena):
		return escena

	return ESCENA_MAIN_GAME


static func obtener_resumen_slot(slot: int) -> Dictionary:
	if not existe_guardado(slot):
		return {
			"slot": slot,
			"existe": false,
			"escena_actual": ESCENA_MAIN_GAME,
			"skin_jugador": "girl",
		}

	var datos := cargar_datos(slot)
	return {
		"slot": slot,
		"existe": true,
		"escena_actual": String(datos.get("escena_actual", ESCENA_MAIN_GAME)),
		"skin_jugador": String(datos.get("skin_jugador", "girl")),
	}


static func obtener_skin_guardada_slot(slot: int) -> String:
	if not existe_guardado(slot):
		return "girl"

	var config := ConfigFile.new()
	if config.load(_obtener_ruta_guardado(slot)) != OK:
		return "girl"

	return _normalizar_skin_jugador(String(config.get_value("general", "skin_jugador", "girl")))


static func establecer_skin_jugador(skin_id: String) -> void:
	_skin_jugador_activa = _normalizar_skin_jugador(skin_id)


static func obtener_skin_jugador() -> String:
	return _skin_jugador_activa


static func cargar_datos(slot: int = -1) -> Dictionary:
	var config := ConfigFile.new()
	var resultado := config.load(_obtener_ruta_guardado(slot))
	if resultado != OK:
		return {}

	_skin_jugador_activa = _normalizar_skin_jugador(String(config.get_value("general", "skin_jugador", _skin_jugador_activa)))

	return {
		"escena_actual": String(config.get_value("general", "escena_actual", ESCENA_MAIN_GAME)),
		"slot": int(config.get_value("general", "slot", _resolver_slot(slot))),
		"skin_jugador": _skin_jugador_activa,
		"main_game": Dictionary(config.get_value("main_game", "datos", {})),
		"mundo_2": Dictionary(config.get_value("mundo_2", "datos", {})),
	}


static func guardar_estado_main_game(datos: Dictionary, slot: int = -1) -> void:
	var config := _cargar_config_existente(slot)
	var slot_resuelto := _resolver_slot(slot)
	config.set_value("general", "slot", slot_resuelto)
	config.set_value("general", "escena_actual", ESCENA_MAIN_GAME)
	config.set_value("general", "skin_jugador", _skin_jugador_activa)
	config.set_value("main_game", "datos", datos.duplicate(true))
	config.save(_obtener_ruta_guardado(slot_resuelto))


static func guardar_estado_mundo_2(datos: Dictionary, slot: int = -1) -> void:
	var config := _cargar_config_existente(slot)
	var slot_resuelto := _resolver_slot(slot)
	config.set_value("general", "slot", slot_resuelto)
	config.set_value("general", "escena_actual", ESCENA_MUNDO_2)
	config.set_value("general", "skin_jugador", _skin_jugador_activa)
	config.set_value("mundo_2", "datos", datos.duplicate(true))
	config.save(_obtener_ruta_guardado(slot_resuelto))


static func guardar_skin_guardada_slot(slot: int, skin_id: String) -> void:
	var slot_resuelto := _resolver_slot(slot)
	var config := _cargar_config_existente(slot_resuelto)
	var escena_actual := String(config.get_value("general", "escena_actual", ESCENA_MAIN_GAME))
	config.set_value("general", "slot", slot_resuelto)
	config.set_value("general", "escena_actual", escena_actual)
	config.set_value("general", "skin_jugador", _normalizar_skin_jugador(skin_id))
	config.save(_obtener_ruta_guardado(slot_resuelto))


static func borrar_guardado_slot(slot: int) -> void:
	var ruta := _obtener_ruta_guardado(slot)
	if FileAccess.file_exists(ruta):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))


static func preparar_transicion_escena(escena_destino: String, id_entrada: String = "", reproducir_animacion: bool = true) -> void:
	_transicion_pendiente = {
		"escena_destino": escena_destino,
		"id_entrada": id_entrada,
		"reproducir_animacion": reproducir_animacion,
	}


static func consumir_transicion_pendiente() -> Dictionary:
	var datos := _transicion_pendiente.duplicate(true)
	_transicion_pendiente.clear()
	return datos


static func limpiar_transicion_pendiente() -> void:
	_transicion_pendiente.clear()


static func marcar_intro_nueva_partida(activo: bool = true) -> void:
	_intro_nueva_partida_pendiente = activo


static func consumir_intro_nueva_partida() -> bool:
	var valor := _intro_nueva_partida_pendiente
	_intro_nueva_partida_pendiente = false
	return valor


static func _cargar_config_existente(slot: int = -1) -> ConfigFile:
	var config := ConfigFile.new()
	config.load(_obtener_ruta_guardado(slot))
	return config


static func _obtener_ruta_guardado(slot: int = -1) -> String:
	return PREFIJO_GUARDADO % _resolver_slot(slot)


static func _resolver_slot(slot: int = -1) -> int:
	if slot >= 1:
		return clampi(slot, 1, TOTAL_SLOTS)
	return clampi(_slot_activo, 1, TOTAL_SLOTS)


static func _normalizar_skin_jugador(skin_id: String) -> String:
	return "boy" if skin_id.to_lower() == "boy" else "girl"
