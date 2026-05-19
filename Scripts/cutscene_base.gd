extends CanvasLayer
class_name CutsceneBase

const FUENTE_PIXEL := preload("res://Fuentes/joystix monospace.otf")

const FRAMES_IDLE := [
	"res://Imagenes/Personaje/idle_00.png",
	"res://Imagenes/Personaje/idle_01.png",
	"res://Imagenes/Personaje/idle_02.png",
	"res://Imagenes/Personaje/idle_03.png",
]
const FRAMES_WALK := [
	"res://Imagenes/Personaje/walk_00.png",
	"res://Imagenes/Personaje/walk_01.png",
	"res://Imagenes/Personaje/walk_02.png",
	"res://Imagenes/Personaje/walk_03.png",
]
const FRAMES_RUN := [
	"res://Imagenes/Personaje/run_00.png",
	"res://Imagenes/Personaje/run_01.png",
	"res://Imagenes/Personaje/run_02.png",
	"res://Imagenes/Personaje/run_03.png",
]
const FRAMES_GAFAS := [
	"res://Imagenes/Objetos/gafas_00.png",
	"res://Imagenes/Objetos/gafas_01.png",
	"res://Imagenes/Objetos/gafas_02.png",
]
const FRAMES_SLIME := [
	"res://Imagenes/Enemigos/slime/slime_00.png",
	"res://Imagenes/Enemigos/slime/slime_01.png",
	"res://Imagenes/Enemigos/slime/slime_02.png",
	"res://Imagenes/Enemigos/slime/slime_03.png",
	"res://Imagenes/Enemigos/slime/slime_04.png",
]
const FRAMES_MURO := [
	"res://Imagenes/Enemigos/muro_verde/muro_verde_00.png",
	"res://Imagenes/Enemigos/muro_verde/muro_verde_01.png",
	"res://Imagenes/Enemigos/muro_verde/muro_verde_02.png",
	"res://Imagenes/Enemigos/muro_verde/muro_verde_03.png",
	"res://Imagenes/Enemigos/muro_verde/muro_verde_04.png",
	"res://Imagenes/Enemigos/muro_verde/muro_verde_05.png",
	"res://Imagenes/Enemigos/muro_verde/muro_verde_06.png",
	"res://Imagenes/Enemigos/muro_verde/muro_verde_07.png",
]
const TEXTURA_PUERTA_CERRADA := "res://Imagenes/Objetos/puerta_cerrada_final.png"
const TEXTURA_PUERTA_ABIERTA := "res://Imagenes/Objetos/puerta_abierta_final.png"
const TEXTURA_FONDO_MUNDO_1 := "res://Imagenes/Fondos/Mundo1/fondo_frontal.png"
const TEXTURA_FONDO_MUNDO_2 := "res://Imagenes/Fondos/MundoFinal/fondo_05_pilares.png"
const CREDITOS := [
	{"nombre": "Cafusa", "rol": "Programacion, sistemas y arquitectura POO"},
	{"nombre": "CristianFuentesSanchez", "rol": "Arte, mundo visual y direccion de UI"},
	{"nombre": "issa", "rol": "Diseno de niveles, puzzles y narrativa"},
	{"nombre": "ManuJei", "rol": "Gameplay, balance, pruebas e integracion"},
]

var _root: Control
var _overlay: ColorRect
var _panel: PanelContainer
var _titulo: Label
var _nota: Label
var _stage: Control
var _linea: ColorRect
var _animaciones_frame: Array[Dictionary] = []
var _tweens_loop: Array[Tween] = []


func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	_construir_ui()


func _process(delta: float) -> void:
	for animacion in _animaciones_frame:
		var nodo_var: Variant = animacion.get("nodo")
		if nodo_var == null or not is_instance_valid(nodo_var):
			continue

		var nodo := nodo_var as TextureRect
		var frames: Array = animacion.get("frames", [])
		if nodo == null or not is_instance_valid(nodo) or frames.is_empty():
			continue

		animacion["tiempo"] = float(animacion.get("tiempo", 0.0)) + delta
		var intervalo := 1.0 / maxf(float(animacion.get("fps", 8.0)), 0.1)
		if float(animacion["tiempo"]) < intervalo:
			continue

		animacion["tiempo"] = 0.0
		animacion["indice"] = (int(animacion.get("indice", 0)) + 1) % frames.size()
		nodo.texture = frames[int(animacion["indice"])]


func reproducir_intro_inicio() -> void:
	await _mostrar_cinematica(
		"ANTES DE CORRER",
		"En la escuela, las burlas pesan. Las gafas no son una marca: tambien son una forma de ver caminos.",
		"Escuela",
		5.0,
		Color(0.78, 0.92, 0.42, 1.0),
		Callable(self, "_montar_intro_escuela")
	)
	await _mostrar_cinematica(
		"CONTROLES",
		"Muevete, salta, interactua y usa las gafas. La ruta se aprende jugando.",
		"Guia rapida",
		9.0,
		Color(0.45, 0.82, 0.93, 1.0),
		Callable(self, "_montar_controles")
	)


func reproducir_transicion_mundo_2() -> void:
	await _mostrar_cinematica(
		"ENTRE MUNDOS",
		"Despues de la primera sombra, el pasillo se abre. Lo que viene ya no espera: persigue.",
		"Persecucion",
		5.0,
		Color(0.88, 0.42, 0.38, 1.0),
		Callable(self, "_montar_transicion_mundo_2")
	)


func reproducir_final_provisional() -> void:
	await _mostrar_cinematica(
		"REGRESO",
		"La mente aprendio a moldearse. El ruido no desaparece, pero hoy ya no decide por el.",
		"Llegada a casa",
		5.0,
		Color(0.76, 0.91, 0.56, 1.0),
		Callable(self, "_montar_final_casa")
	)


func reproducir_pantalla_final_creditos() -> void:
	await _mostrar_cinematica(
		"JUEGO FINALIZADO",
		"Enhorabuena. Cruzaste las sombras, ordenaste los ecos y encontraste una forma de volver a casa.",
		"Gracias por jugar",
		4.0,
		Color(0.86, 0.94, 0.43, 1.0),
		Callable(self, "_montar_enhorabuena")
	)
	await _mostrar_cinematica(
		"CREDITOS",
		"Deep Shadow - Proyecto final de Programacion Orientada a Objetos.",
		"Equipo",
		7.0,
		Color(0.50, 0.84, 0.90, 1.0),
		Callable(self, "_montar_creditos")
	)


func _construir_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	_overlay = ColorRect.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(_overlay)

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(centro)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(820, 430)
	_panel.modulate.a = 0.0
	_panel.scale = Vector2(0.98, 0.98)
	_panel.add_theme_stylebox_override("panel", _crear_estilo_panel())
	centro.add_child(_panel)

	var margen := MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 28)
	margen.add_theme_constant_override("margin_right", 28)
	margen.add_theme_constant_override("margin_top", 22)
	margen.add_theme_constant_override("margin_bottom", 22)
	_panel.add_child(margen)

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 10)
	margen.add_child(caja)

	_titulo = Label.new()
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_titulo.add_theme_font_override("font", FUENTE_PIXEL)
	_titulo.add_theme_font_size_override("font_size", 20)
	_titulo.add_theme_color_override("font_color", Color(0.88, 0.95, 0.50, 1.0))
	caja.add_child(_titulo)

	_linea = ColorRect.new()
	_linea.custom_minimum_size = Vector2(0, 3)
	_linea.color = Color(0.78, 0.92, 0.42, 1.0)
	caja.add_child(_linea)

	_stage = Control.new()
	_stage.custom_minimum_size = Vector2(760, 285)
	_stage.clip_contents = true
	caja.add_child(_stage)

	_nota = Label.new()
	_nota.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_nota.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_nota.add_theme_font_override("font", FUENTE_PIXEL)
	_nota.add_theme_font_size_override("font_size", 10)
	_nota.add_theme_color_override("font_color", Color(0.76, 0.84, 0.78, 1.0))
	caja.add_child(_nota)


func _crear_estilo_panel() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.050, 0.044, 0.066, 0.97)
	estilo.border_width_left = 2
	estilo.border_width_top = 2
	estilo.border_width_right = 2
	estilo.border_width_bottom = 2
	estilo.border_color = Color(0.70, 0.84, 0.38, 0.95)
	estilo.corner_radius_top_left = 10
	estilo.corner_radius_top_right = 10
	estilo.corner_radius_bottom_left = 10
	estilo.corner_radius_bottom_right = 10
	estilo.shadow_color = Color(0, 0, 0, 0.50)
	estilo.shadow_size = 18
	return estilo


func _mostrar_cinematica(titulo: String, texto: String, nota: String, duracion: float, acento: Color, montar: Callable) -> void:
	_detener_tweens_loop()
	_animaciones_frame.clear()
	_limpiar_hijos(_stage)
	_titulo.text = titulo
	_nota.text = "%s  |  %s" % [nota, texto]
	_linea.color = acento
	_linea.scale.x = 0.0
	_panel.modulate.a = 0.0
	_panel.scale = Vector2(0.98, 0.98)
	var color_overlay := _overlay.color
	color_overlay.a = 0.0
	_overlay.color = color_overlay

	montar.call()
	await get_tree().process_frame
	_panel.pivot_offset = _panel.size * 0.5

	var entrada := create_tween()
	entrada.set_ignore_time_scale(true)
	entrada.set_parallel(true)
	entrada.set_trans(Tween.TRANS_SINE)
	entrada.set_ease(Tween.EASE_OUT)
	entrada.tween_property(_overlay, "color:a", 0.88, 0.22)
	entrada.tween_property(_panel, "modulate:a", 1.0, 0.22)
	entrada.tween_property(_panel, "scale", Vector2.ONE, 0.24)
	entrada.tween_property(_linea, "scale:x", 1.0, 0.45)
	await entrada.finished

	await get_tree().create_timer(duracion, true, false, true).timeout

	var salida := create_tween()
	salida.set_ignore_time_scale(true)
	salida.set_parallel(true)
	salida.set_trans(Tween.TRANS_SINE)
	salida.set_ease(Tween.EASE_IN)
	salida.tween_property(_panel, "modulate:a", 0.0, 0.22)
	salida.tween_property(_panel, "scale", Vector2(1.02, 1.02), 0.22)
	salida.tween_property(_overlay, "color:a", 0.0, 0.26)
	await salida.finished
	_detener_tweens_loop()
	_animaciones_frame.clear()


func _montar_intro_escuela() -> void:
	_agregar_fondo_degradado(Color(0.09, 0.11, 0.15, 1.0), Color(0.18, 0.19, 0.21, 1.0))
	_agregar_rect(_stage, Vector2(0, 218), Vector2(760, 67), Color(0.16, 0.16, 0.18, 1.0), "PisoEscuela")
	for i in range(8):
		var x := 24 + i * 85
		_agregar_rect(_stage, Vector2(x, 46), Vector2(54, 158), Color(0.17, 0.25, 0.32, 1.0), "Locker")
		_agregar_rect(_stage, Vector2(x + 8, 70), Vector2(38, 5), Color(0.35, 0.50, 0.60, 1.0), "Rejilla")
		_agregar_rect(_stage, Vector2(x + 8, 112), Vector2(38, 5), Color(0.35, 0.50, 0.60, 0.75), "Rejilla2")

	var player := _crear_sprite_animado(_stage, FRAMES_WALK, Vector2(72, 144), Vector2(96, 120), 7.0, "JugadorWalk")
	player.modulate = Color(1, 1, 1, 1)
	var tween_player := create_tween()
	tween_player.set_ignore_time_scale(true)
	tween_player.set_trans(Tween.TRANS_SINE)
	tween_player.set_ease(Tween.EASE_IN_OUT)
	tween_player.tween_property(player, "position", Vector2(332, 144), 4.6)

	for i in range(3):
		var sombra := _crear_sprite_animado(_stage, FRAMES_SLIME, Vector2(430 + i * 88, 162), Vector2(78, 68), 5.0, "Sombra%d" % i)
		sombra.modulate = Color(0.02, 0.02, 0.03, 0.58)
		var tween_sombra := create_tween()
		_tweens_loop.append(tween_sombra)
		tween_sombra.set_ignore_time_scale(true)
		tween_sombra.set_loops()
		tween_sombra.tween_property(sombra, "position:y", sombra.position.y - 5.0, 0.45)
		tween_sombra.tween_property(sombra, "position:y", sombra.position.y, 0.45)

	_agregar_burbuja(Vector2(445, 62), "cuatro ojos", 0.86)
	_agregar_burbuja(Vector2(555, 91), "otra vez", 0.72)
	var gafas := _crear_sprite_animado(_stage, FRAMES_GAFAS, Vector2(346, 100), Vector2(48, 34), 7.0, "GafasBrillo")
	gafas.modulate = Color(0.95, 1.0, 0.55, 0.9)
	_animar_pulso(gafas, Vector2(1.0, 1.0), Vector2(1.18, 1.18), 0.65)
	_agregar_caption("No se trata de esconder las gafas. Se trata de aprender a mirar con ellas.")


func _montar_controles() -> void:
	_agregar_fondo_degradado(Color(0.06, 0.09, 0.11, 1.0), Color(0.12, 0.17, 0.17, 1.0))
	var titulo := _agregar_label(_stage, "GUIA RAPIDA", Vector2(0, 14), Vector2(760, 28), 14, Color(0.86, 0.94, 0.43, 1.0))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var cartas := [
		{"tecla": "A / D", "texto": "Moverte", "ayuda": "Tambien flechas", "tipo": "walk"},
		{"tecla": "ESPACIO", "texto": "Saltar", "ayuda": "Supera huecos", "tipo": "jump"},
		{"tecla": "SHIFT", "texto": "Sprint", "ayuda": "Corre en tramos largos", "tipo": "run"},
		{"tecla": "Q", "texto": "Gafas", "ayuda": "Revela rutas ocultas", "tipo": "gafas"},
		{"tecla": "E", "texto": "Interactuar", "ayuda": "Puertas, pistas y totems", "tipo": "door"},
		{"tecla": "P / ESC", "texto": "Pausa", "ayuda": "Menu y reinicio", "tipo": "pause"},
	]
	for i in range(cartas.size()):
		var columna := i % 3
		var fila := int(i / 3)
		_crear_tarjeta_control(Vector2(44 + columna * 232, 58 + fila * 100), Dictionary(cartas[i]), i)
	_agregar_caption("Tip: con las gafas activas aparecen rutas ocultas y el mundo se vuelve mas claro.")


func _montar_transicion_mundo_2() -> void:
	_agregar_fondo_textura(TEXTURA_FONDO_MUNDO_2, Color(0.55, 0.68, 0.75, 0.82))
	_agregar_rect(_stage, Vector2(0, 220), Vector2(760, 65), Color(0.11, 0.13, 0.15, 0.88), "Suelo")
	var puerta_cerrada := _crear_sprite_estatico(_stage, TEXTURA_PUERTA_CERRADA, Vector2(502, 72), Vector2(136, 172), "PuertaCerrada")
	var puerta_abierta := _crear_sprite_estatico(_stage, TEXTURA_PUERTA_ABIERTA, Vector2(502, 72), Vector2(136, 172), "PuertaAbierta")
	puerta_abierta.modulate.a = 0.0

	var player := _crear_sprite_animado(_stage, FRAMES_RUN, Vector2(52, 150), Vector2(88, 108), 10.0, "JugadorRun")
	var muro := _crear_sprite_animado(_stage, FRAMES_MURO, Vector2(-125, 42), Vector2(185, 222), 8.0, "MuroVerde")
	muro.modulate = Color(1, 1, 1, 0.92)

	var tween := create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(player, "position", Vector2(555, 150), 4.65)
	tween.tween_property(muro, "position", Vector2(70, 42), 4.65)
	tween.tween_property(puerta_cerrada, "modulate:a", 0.0, 1.3).set_delay(2.2)
	tween.tween_property(puerta_abierta, "modulate:a", 1.0, 1.3).set_delay(2.2)
	_agregar_burbuja(Vector2(285, 58), "no mires atras", 0.82)
	_agregar_caption("La caminata se rompe: el segundo mundo empieza corriendo.")


func _montar_final_casa() -> void:
	_agregar_fondo_degradado(Color(0.03, 0.05, 0.10, 1.0), Color(0.12, 0.09, 0.12, 1.0))
	for i in range(16):
		_agregar_rect(_stage, Vector2(20 + i * 48, 28 + (i % 3) * 13), Vector2(3, 3), Color(0.90, 0.86, 0.62, 0.8), "Estrella")
	_agregar_rect(_stage, Vector2(0, 218), Vector2(760, 67), Color(0.11, 0.10, 0.10, 1.0), "Calle")
	_agregar_rect(_stage, Vector2(500, 95), Vector2(150, 124), Color(0.34, 0.24, 0.20, 1.0), "Casa")
	_agregar_rect(_stage, Vector2(478, 72), Vector2(195, 36), Color(0.18, 0.08, 0.07, 1.0), "Techo")
	_agregar_rect(_stage, Vector2(555, 138), Vector2(36, 52), Color(0.18, 0.11, 0.08, 1.0), "PuertaCasa")
	var ventana := _agregar_rect(_stage, Vector2(605, 128), Vector2(28, 30), Color(1.0, 0.80, 0.42, 0.92), "Ventana")
	_animar_pulso(ventana, Vector2(1.0, 1.0), Vector2(1.08, 1.08), 0.9)

	var player := _crear_sprite_animado(_stage, FRAMES_WALK, Vector2(52, 152), Vector2(92, 112), 7.0, "JugadorCasa")
	var tween := create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(player, "position", Vector2(514, 152), 4.35)
	_agregar_burbuja(Vector2(307, 75), "pude volver", 0.82)
	_agregar_caption("Llegar a casa no borra todo, pero confirma que pudo seguir.")


func _montar_enhorabuena() -> void:
	_agregar_fondo_degradado(Color(0.04, 0.08, 0.10, 1.0), Color(0.12, 0.16, 0.14, 1.0))
	for i in range(10):
		var x := 42 + i * 72
		var y := 34 + (i % 2) * 42
		var estrella := _agregar_rect(_stage, Vector2(x, y), Vector2(10, 10), Color(0.86, 0.94, 0.43, 0.85), "Brillo")
		_animar_pulso(estrella, Vector2.ONE, Vector2(1.35, 1.35), 0.55 + float(i % 3) * 0.08)

	var marco := PanelContainer.new()
	marco.position = Vector2(108, 62)
	marco.size = Vector2(544, 150)
	marco.add_theme_stylebox_override("panel", _crear_estilo_tarjeta())
	_stage.add_child(marco)

	var titulo := _agregar_label(marco, "ENHORABUENA", Vector2(0, 24), Vector2(544, 34), 22, Color(0.86, 0.94, 0.43, 1.0))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var texto := _agregar_label(marco, "Completaste Deep Shadow.", Vector2(0, 76), Vector2(544, 28), 12, Color(0.93, 0.96, 0.82, 1.0))
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var subtexto := _agregar_label(marco, "El mundo no dejo de ser dificil, pero ya no camino solo entre sus sombras.", Vector2(54, 110), Vector2(436, 30), 8, Color(0.72, 0.86, 0.78, 1.0))
	subtexto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtexto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var player := _crear_sprite_animado(_stage, FRAMES_IDLE, Vector2(332, 186), Vector2(96, 94), 5.0, "JugadorFinal")
	_animar_pulso(player, Vector2.ONE, Vector2(1.04, 1.04), 0.9)


func _montar_creditos() -> void:
	_agregar_fondo_degradado(Color(0.035, 0.045, 0.060, 1.0), Color(0.08, 0.10, 0.12, 1.0))
	var encabezado := _agregar_label(_stage, "DEEP SHADOW", Vector2(0, 18), Vector2(760, 30), 17, Color(0.86, 0.94, 0.43, 1.0))
	encabezado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var subtitulo := _agregar_label(_stage, "Proyecto final - Programacion Orientada a Objetos", Vector2(0, 52), Vector2(760, 22), 8, Color(0.72, 0.86, 0.78, 1.0))
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	for i in range(CREDITOS.size()):
		var datos: Dictionary = Dictionary(CREDITOS[i])
		var y := 92 + i * 38
		var nombre := _agregar_label(_stage, String(datos["nombre"]), Vector2(72, y), Vector2(238, 24), 10, Color(0.92, 0.96, 0.82, 1.0))
		nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		var rol := _agregar_label(_stage, String(datos["rol"]), Vector2(328, y), Vector2(350, 30), 8, Color(0.62, 0.80, 0.80, 1.0))
		rol.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var punto := _agregar_rect(_stage, Vector2(314, y + 8), Vector2(6, 6), Color(0.86, 0.94, 0.43, 1.0), "PuntoCredito")
		_animar_pulso(punto, Vector2.ONE, Vector2(1.28, 1.28), 0.7 + i * 0.05)

	var cierre := _agregar_label(_stage, "Gracias por jugar.", Vector2(0, 252), Vector2(760, 24), 11, Color(0.86, 0.94, 0.43, 1.0))
	cierre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _crear_tarjeta_control(posicion: Vector2, datos: Dictionary, indice: int) -> void:
	var tarjeta := PanelContainer.new()
	tarjeta.position = posicion
	tarjeta.size = Vector2(210, 92)
	tarjeta.add_theme_stylebox_override("panel", _crear_estilo_tarjeta())
	_stage.add_child(tarjeta)

	var caja_tecla := _agregar_rect(tarjeta, Vector2(10, 8), Vector2(80, 26), Color(0.035, 0.045, 0.052, 0.92), "CajaTecla")
	caja_tecla.color = Color(0.035, 0.045, 0.052, 0.92)
	var tecla := _agregar_label(tarjeta, String(datos.get("tecla", "")), Vector2(10, 13), Vector2(80, 18), 9, Color(0.88, 0.94, 0.43, 1.0))
	tecla.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var texto := _agregar_label(tarjeta, String(datos.get("texto", "")), Vector2(98, 10), Vector2(96, 22), 9, Color(0.90, 0.96, 0.86, 1.0))
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var ayuda := _agregar_label(tarjeta, String(datos.get("ayuda", "")), Vector2(76, 42), Vector2(122, 38), 7, Color(0.66, 0.82, 0.78, 1.0))
	ayuda.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	match String(datos.get("tipo", "")):
		"walk":
			_crear_sprite_animado(tarjeta, FRAMES_WALK, Vector2(20, 42), Vector2(42, 38), 6.0, "IconWalk")
		"jump":
			var saltar := _crear_sprite_animado(tarjeta, FRAMES_IDLE, Vector2(22, 40), Vector2(40, 40), 4.0, "IconJump")
			_animar_salto(saltar)
		"run":
			_crear_sprite_animado(tarjeta, FRAMES_RUN, Vector2(18, 42), Vector2(46, 38), 10.0, "IconRun")
		"gafas":
			var gafas := _crear_sprite_animado(tarjeta, FRAMES_GAFAS, Vector2(18, 50), Vector2(48, 26), 7.0, "IconGafas")
			_animar_pulso(gafas, Vector2.ONE, Vector2(1.18, 1.18), 0.65)
		"door":
			_crear_sprite_estatico(tarjeta, TEXTURA_PUERTA_ABIERTA, Vector2(24, 36), Vector2(36, 48), "IconPuerta")
		_:
			_agregar_label(tarjeta, "||", Vector2(28, 44), Vector2(32, 28), 16, Color(0.88, 0.94, 0.43, 1.0))

	tarjeta.modulate.a = 0.0
	var tween := create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(tarjeta, "modulate:a", 1.0, 0.25).set_delay(0.18 * indice)


func _crear_estilo_tarjeta() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.10, 0.11, 0.93)
	estilo.border_width_left = 1
	estilo.border_width_top = 1
	estilo.border_width_right = 1
	estilo.border_width_bottom = 1
	estilo.border_color = Color(0.58, 0.72, 0.44, 0.78)
	estilo.corner_radius_top_left = 6
	estilo.corner_radius_top_right = 6
	estilo.corner_radius_bottom_left = 6
	estilo.corner_radius_bottom_right = 6
	return estilo


func _agregar_fondo_textura(ruta: String, tint: Color) -> TextureRect:
	var fondo := _crear_sprite_estatico(_stage, ruta, Vector2.ZERO, Vector2(760, 285), "FondoTextura")
	fondo.stretch_mode = TextureRect.STRETCH_SCALE
	fondo.modulate = tint
	return fondo


func _agregar_fondo_degradado(arriba: Color, abajo: Color) -> void:
	_agregar_rect(_stage, Vector2.ZERO, Vector2(760, 142), arriba, "FondoArriba")
	_agregar_rect(_stage, Vector2(0, 142), Vector2(760, 143), abajo, "FondoAbajo")


func _agregar_caption(texto: String) -> Label:
	var fondo := _agregar_rect(_stage, Vector2(34, 238), Vector2(692, 34), Color(0.02, 0.03, 0.035, 0.58), "CaptionFondo")
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var label := _agregar_label(_stage, texto, Vector2(48, 246), Vector2(664, 24), 9, Color(0.93, 0.96, 0.78, 1.0))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _agregar_burbuja(posicion: Vector2, texto: String, escala: float) -> void:
	var panel := PanelContainer.new()
	panel.position = posicion
	panel.size = Vector2(140, 38) * escala
	panel.add_theme_stylebox_override("panel", _crear_estilo_burbuja())
	_stage.add_child(panel)

	var label := _agregar_label(panel, texto, Vector2(8, 8) * escala, Vector2(124, 24) * escala, int(8 * escala), Color(0.08, 0.08, 0.09, 1.0))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.35).set_delay(0.65)


func _crear_estilo_burbuja() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.87, 0.94, 0.79, 0.96)
	estilo.border_width_left = 1
	estilo.border_width_top = 1
	estilo.border_width_right = 1
	estilo.border_width_bottom = 1
	estilo.border_color = Color(0.34, 0.42, 0.32, 0.9)
	estilo.corner_radius_top_left = 8
	estilo.corner_radius_top_right = 8
	estilo.corner_radius_bottom_left = 8
	estilo.corner_radius_bottom_right = 8
	return estilo


func _crear_sprite_animado(padre: Control, rutas: Array, posicion: Vector2, tamano: Vector2, fps: float, nombre: String) -> TextureRect:
	var frames := _cargar_frames(rutas)
	var sprite := _crear_texture_rect(padre, frames[0] if not frames.is_empty() else null, posicion, tamano, nombre)
	if frames.size() > 1:
		_animaciones_frame.append({
			"nodo": sprite,
			"frames": frames,
			"fps": fps,
			"indice": 0,
			"tiempo": 0.0,
		})
	return sprite


func _crear_sprite_estatico(padre: Control, ruta: String, posicion: Vector2, tamano: Vector2, nombre: String) -> TextureRect:
	return _crear_texture_rect(padre, load(ruta) as Texture2D, posicion, tamano, nombre)


func _crear_texture_rect(padre: Control, textura: Texture2D, posicion: Vector2, tamano: Vector2, nombre: String) -> TextureRect:
	var sprite := TextureRect.new()
	sprite.name = nombre
	sprite.texture = textura
	sprite.position = posicion
	sprite.size = tamano
	sprite.custom_minimum_size = tamano
	sprite.pivot_offset = tamano * 0.5
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	padre.add_child(sprite)
	return sprite


func _cargar_frames(rutas: Array) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	for ruta in rutas:
		var textura := load(String(ruta)) as Texture2D
		if textura != null:
			frames.append(textura)
	return frames


func _animar_pulso(nodo: Control, escala_base: Vector2, escala_objetivo: Vector2, duracion: float) -> void:
	nodo.scale = escala_base
	var tween := create_tween()
	_tweens_loop.append(tween)
	tween.set_ignore_time_scale(true)
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(nodo, "scale", escala_objetivo, duracion)
	tween.tween_property(nodo, "scale", escala_base, duracion)


func _animar_salto(nodo: Control) -> void:
	var y_base := nodo.position.y
	var tween := create_tween()
	_tweens_loop.append(tween)
	tween.set_ignore_time_scale(true)
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(nodo, "position:y", y_base - 13.0, 0.45)
	tween.tween_property(nodo, "position:y", y_base, 0.45)


func _agregar_label(padre: Control, texto: String, posicion: Vector2, tamano: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = texto
	label.position = posicion
	label.size = tamano
	label.add_theme_font_override("font", FUENTE_PIXEL)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	padre.add_child(label)
	return label


func _agregar_rect(padre: Control, posicion: Vector2, tamano: Vector2, color: Color, nombre: String) -> ColorRect:
	var rect := ColorRect.new()
	rect.name = nombre
	rect.position = posicion
	rect.size = tamano
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	padre.add_child(rect)
	return rect


func _limpiar_hijos(nodo: Node) -> void:
	_detener_tweens_loop()
	_animaciones_frame.clear()
	for child in nodo.get_children():
		nodo.remove_child(child)
		child.queue_free()


func _detener_tweens_loop() -> void:
	for tween in _tweens_loop:
		if tween != null and tween.is_valid():
			tween.kill()
	_tweens_loop.clear()
