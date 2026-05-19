extends Node2D

const SistemaGuardadoClass = preload("res://Scripts/sistema_guardado.gd")
const CUTSCENE_BASE_SCRIPT := preload("res://Scripts/cutscene_base.gd")
const PERSONAJE_SCENE := preload("res://Escenas/Personaje.tscn")
const HUD_SCENE := preload("res://Escenas/HUD.tscn")
const MENU_PAUSA_SCENE := preload("res://Escenas/MenuPausa.tscn")
const MURO_CARNE_SCENE := preload("res://Escenas/MuroCarne.tscn")
const TOTEM_JEFE_SCENE := preload("res://Escenas/TotemJefe.tscn")
const PLATAFORMA_GAFAS_SCENE := preload("res://Escenas/plataforma_gafas.tscn")
const FONDO_MUNDO_FINAL_SCRIPT := preload("res://Scripts/fondo_mundo_final.gd")
const AMBIENTE_MUNDO_2_SCRIPT := preload("res://Scripts/ambiente_mundo_2.gd")
const CHECKPOINT_SCRIPT := preload("res://Scripts/checkpoint_activador.gd")
const INTERACTIVO_BASE_SCRIPT := preload("res://Scripts/interactivo_base.gd")
const DISTORSION_SHADER := preload("res://Shaders/vigneta_distorsion.gdshader")
const FUENTE_PIXEL := preload("res://Fuentes/joystix monospace.otf")
const TEXTURA_CARTEL := preload("res://Imagenes/Objetos/checkpoint_cartel_cc0.png")
const MENU_SCENE := "res://Escenas/Menu.tscn"
const SCENE_PATH := "res://Escenas/Mundo2.tscn"
const ESCALA_TIEMPO_PAUSA := 0.000001
const FACTOR_LENTITUD_GAFAS_MURO := 0.9
const INTERVALO_PENSAMIENTOS := 20.0
const PENSAMIENTOS_OSCUROS := [
	"Si tropiezo otra vez, va a sonar igual que sus risas.",
	"Corro, pero el ruido no deja de perseguirme.",
	"Ni escapando siento que me quieren dejar en paz.",
	"Si me alcanza, vuelvo a ser el chiste de siempre.",
	"Cada salto se siente como intentar salir de sus burlas.",
]
const PENSAMIENTOS_GAFAS := [
	"Con las gafas puestas, el camino deja de esconderse.",
	"Si puedo verlo claro, tambien puedo seguir.",
	"No todo lo que me persigue decide quien soy.",
]

@export_group("Flujo")
@export var altura_caida_respawn: float = 760.0
@export var offset_camara: Vector2 = Vector2(0, -64)
@export var posicion_spawn_defecto: Vector2 = Vector2(144, 520)
@export var mensaje_llegada: String = "Mundo 2. Corre: el muro no se detendra, pero las gafas revelan la ruta."
@export var mensaje_respawn: String = "Has vuelto al inicio del mundo 2."
@export var mensaje_fallo_muro: String = "El muro te alcanzo. Respira y vuelve a correr."
@export var duracion_restablecer_mensaje_llegada: float = 2.45
@export var duracion_intro_entrada_puerta: float = 0.46
@export var desplazamiento_salida_puerta: Vector2 = Vector2(72, 0)
@export var espera_inicio_persecucion: float = 0.5

@export_group("Jugador")
@export var jugador_velocidad_base: float = 100.0
@export var jugador_fuerza_salto: float = 300.0
@export var jugador_aceleracion: float = 1000.0

@export_group("Camara")
@export var zoom_base_mundo: Vector2 = Vector2(1.9, 1.9)
@export var zoom_con_gafas: Vector2 = Vector2(1.6, 1.6)
@export var suavizado_camara: float = 6.0
@export var adelanto_camara_muro: float = 316.0
@export var adelanto_camara_jugador: float = 48.0
@export var amplitud_temblor_camara: Vector2 = Vector2(4.5, 2.2)
@export var frecuencia_temblor_camara: float = 8.5
@export var distancia_temblor_maxima: float = 520.0

@export_group("Muro")
@export var posicion_inicial_muro: Vector2 = Vector2(-136, 326)
@export var velocidad_muro: float = 72.0
@export var distancia_retroceso_muro_checkpoint: float = 448.0

@export_group("Progresion")
@export var limite_escape_muro_x: float = 11072.0
@export var umbral_escape_jugador_x: float = 11136.0
@export var mensaje_escape_muro_1: String = "Por fin pude escapar de sus molestos insultos."
@export var mensaje_escape_muro_2: String = "Parecian un muro gigante que me destrozaba la mente."
@export var mensaje_puzzle_puerta: String = "Las grietas repiten un orden. Las gafas pueden leerlo."
@export var mensaje_puzzle_final: String = "Estos ecos solo se ordenan si miras con las gafas."

@export_group("Distorsion")
@export var alpha_distorsion_base: float = 0.72
@export var alpha_distorsion_gafas: float = 0.0
@export var duracion_transicion_gafas: float = 0.22
@export var vignette_radius_base: float = 0.56
@export var vignette_softness_base: float = 0.28
@export var blur_strength_base: float = 2.2
@export var edge_darkness_base: float = 0.6
@export var tint_strength_base: float = 0.18
@export var edge_desaturation_base: float = 0.22
@export var aberration_strength_base: float = 1.2
@export var pulse_strength_base: float = 0.02
@export var pulse_speed_base: float = 0.8

@export_group("Sonido")
@export var distancia_peligro_maxima_muro: float = 620.0

var jugador: Jugador = null
var hud: HUD = null
var menu_pausa: MenuPausa = null
var muro_carne: MuroCarne = null
var punto_respawn: Marker2D = null
var camara_1: Camera2D = null
var camara_2: Camera2D = null
var area_camara_1: Area2D = null
var area_camara_2: Area2D = null
var puerta_entrada_mundo_1: Node2D = null
var puerta_puzzle: PuertaBloqueada = null
var puerta_area_final: PuertaBloqueada = null
var salida_entrada_mundo_1: Marker2D = null
var fondo_mundo_final: Node2D = null
var ambiente_mundo_2: AudioStreamPlayer = null
var distorsion_overlay: ColorRect = null
var distorsion_material: ShaderMaterial = null
var _camara_actual: Camera2D = null
var _posicion_respawn_actual: Vector2 = Vector2.ZERO
var _posicion_muro_respawn_actual: Vector2 = Vector2.ZERO
var _pausa_activa: bool = false
var _respawn_activo: bool = false
var _estado_gafas_aplicado: bool = false
var _tween_zoom: Tween
var _tween_alpha_distorsion: Tween
var _temporizador_pensamientos: Timer = null
var _indice_pensamiento: int = 0
var _indice_pensamiento_gafas: int = 0
var _token_restablecer_mensaje: int = 0
var _datos_transicion_entrada: Dictionary = {}
var _intro_persecucion_activa: bool = false
var _checkpoint_activo: bool = false
var _descripcion_checkpoint_actual: String = "Inicio del mundo 2"
var _escape_muro_completado: bool = false
var _pensamientos_escape_mostrados: bool = false
var _puzzle_puerta_completado: bool = false
var _puzzle_final_completado: bool = false
var _progreso_puzzle_puerta: int = 0
var _progreso_puzzle_final: int = 0
var _checkpoints_mundo_2: Array[CheckpointActivador] = []
var _interactivos_mundo_2: Array[InteractivoBase] = []
var _totems_puerta: Array[TotemJefe] = []
var _totems_finales: Array[TotemJefe] = []
var _orden_puzzle_puerta: Array[int] = []
var _orden_puzzle_final: Array[int] = []
var _cartel_pista_puerta: InteractivoBase = null
var _cartel_pista_final: InteractivoBase = null
var _popup_pista_puzzle: PanelContainer = null
var _tween_popup_pista: Tween = null
var _cierre_final_mostrado: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_datos_transicion_entrada = SistemaGuardadoClass.consumir_transicion_pendiente()
	_rng.randomize()
	_asegurar_estructura_base()
	_resolver_nodos()
	_configurar_jugador_base()
	_configurar_puertas_decorativas()
	_configurar_interactivos_mundo_2()
	_configurar_checkpoints_mundo_2()
	_generar_ordenes_puzzle_mundo_2()
	_configurar_menu_pausa()
	_configurar_distorsion_visual()
	_configurar_jugador()
	_configurar_muro()
	_configurar_camaras()
	_configurar_pensamientos()
	_cargar_guardado_mundo_2()
	_configurar_hud()
	_aplicar_estado_progresion_mundo_2(true)
	_aplicar_estado_gafas(jugador.gafas_activas(), true)
	_sincronizar_camara_con_jugador(true, 0.0)
	_actualizar_presion_ambiente()
	if _debe_reproducir_entrada_desde_mundo_1():
		_intro_persecucion_activa = true
		call_deferred("_reproducir_intro_entrada_mundo_1")
		return
	_guardar_progreso()


func _process(delta: float) -> void:
	if _pausa_activa or _respawn_activo or _intro_persecucion_activa or jugador == null or not is_instance_valid(jugador):
		return

	_actualizar_estado_escape_muro()
	_actualizar_camara_por_posicion()
	_sincronizar_camara_con_jugador(false, delta)
	_actualizar_presion_ambiente()

	if jugador.global_position.y > altura_caida_respawn:
		call_deferred("_reiniciar_carrera", false, mensaje_respawn)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pausa"):
		alternar_pausa()
		get_viewport().set_input_as_handled()
		return

	if _pausa_activa or _respawn_activo or _intro_persecucion_activa:
		return

	if event.is_action_pressed("reiniciar"):
		reiniciar_nivel()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("interactuar"):
		_procesar_interaccion_mundo_2()
		get_viewport().set_input_as_handled()


func alternar_pausa() -> void:
	if _respawn_activo:
		return

	if _pausa_activa:
		cerrar_menu_pausa()
		return

	abrir_menu_pausa()


func abrir_menu_pausa() -> void:
	if _pausa_activa or menu_pausa == null or jugador == null:
		return

	_pausa_activa = true
	jugador.velocity = Vector2.ZERO
	jugador.establecer_control_habilitado(false)
	if muro_carne != null:
		muro_carne.establecer_congelado(true)
	_actualizar_escala_tiempo()
	menu_pausa.establecer_modo_carrera(true)
	menu_pausa.abrir(_checkpoint_activo, _descripcion_checkpoint_actual)


func cerrar_menu_pausa() -> void:
	if not _pausa_activa:
		return

	_pausa_activa = false
	if jugador != null:
		jugador.establecer_control_habilitado(true)
	if muro_carne != null:
		muro_carne.establecer_congelado(false)
	_actualizar_escala_tiempo()
	if menu_pausa != null:
		menu_pausa.cerrar()


func reiniciar_nivel() -> void:
	call_deferred("_reiniciar_carrera", false, mensaje_respawn)


func volver_al_menu() -> void:
	cerrar_menu_pausa()
	_restaurar_tiempo_normal()
	get_tree().change_scene_to_file(MENU_SCENE)


func _asegurar_estructura_base() -> void:
	if get_node_or_null("FondoMundoFinal") == null:
		var fondo_instancia: Node2D = FONDO_MUNDO_FINAL_SCRIPT.new()
		fondo_instancia.name = "FondoMundoFinal"
		add_child(fondo_instancia)
		move_child(fondo_instancia, 0)

	if get_node_or_null("SpawnJugador") == null:
		var spawn := Marker2D.new()
		spawn.name = "SpawnJugador"
		spawn.position = posicion_spawn_defecto
		add_child(spawn)

	if get_node_or_null("SalidaEntradaMundo1") == null:
		var puerta_inicio := get_node_or_null("PuertaBloqueada") as Node2D
		if puerta_inicio != null:
			var salida := Marker2D.new()
			salida.name = "SalidaEntradaMundo1"
			salida.position = puerta_inicio.position + desplazamiento_salida_puerta
			add_child(salida)

	var player_root := get_node_or_null("Player") as Node2D
	if player_root == null:
		player_root = Node2D.new()
		player_root.name = "Player"
		add_child(player_root)

	if player_root.get_node_or_null("Jugador") == null:
		var jugador_instancia := PERSONAJE_SCENE.instantiate()
		jugador_instancia.name = "Jugador"
		player_root.add_child(jugador_instancia)

	var canvas := get_node_or_null("Canvas") as CanvasLayer
	if canvas == null:
		canvas = CanvasLayer.new()
		canvas.name = "Canvas"
		add_child(canvas)

	if canvas.get_node_or_null("DistorsionOverlay") == null:
		var overlay := ColorRect.new()
		overlay.name = "DistorsionOverlay"
		overlay.anchor_left = 0.0
		overlay.anchor_top = 0.0
		overlay.anchor_right = 1.0
		overlay.anchor_bottom = 1.0
		overlay.offset_left = 0.0
		overlay.offset_top = 0.0
		overlay.offset_right = 0.0
		overlay.offset_bottom = 0.0
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.color = Color(0.4, 0.72, 0.88, alpha_distorsion_base)
		var material := ShaderMaterial.new()
		material.shader = DISTORSION_SHADER
		material.resource_local_to_scene = true
		overlay.material = material
		canvas.add_child(overlay)
		canvas.move_child(overlay, 0)

	if canvas.get_node_or_null("HUD") == null:
		var hud_instancia := HUD_SCENE.instantiate()
		hud_instancia.name = "HUD"
		canvas.add_child(hud_instancia)

	if canvas.get_node_or_null("MenuPausa") == null:
		var menu_instancia := MENU_PAUSA_SCENE.instantiate()
		menu_instancia.name = "MenuPausa"
		canvas.add_child(menu_instancia)

	if get_node_or_null("MuroCarne") == null:
		var muro_instancia := MURO_CARNE_SCENE.instantiate()
		muro_instancia.name = "MuroCarne"
		add_child(muro_instancia)

	if get_node_or_null("AmbienteMundo2") == null:
		var ambiente_instancia: AudioStreamPlayer = AMBIENTE_MUNDO_2_SCRIPT.new()
		ambiente_instancia.name = "AmbienteMundo2"
		add_child(ambiente_instancia)

	_asegurar_objetos_mundo_2()


func _asegurar_objetos_mundo_2() -> void:
	var objetos := get_node_or_null("ObjetosMundo2") as Node2D
	if objetos == null:
		objetos = Node2D.new()
		objetos.name = "ObjetosMundo2"
		add_child(objetos)

	_asegurar_checkpoint_mundo_2(objetos, "CheckpointCarrera1", Vector2(2368, 520), "Checkpoint activado. El muro no se ha quedado atras todavia.")
	_asegurar_checkpoint_mundo_2(objetos, "CheckpointCarrera2", Vector2(6208, 520), "Checkpoint activado. Sigue corriendo, no dejes que el ruido te alcance.")
	_asegurar_checkpoint_mundo_2(objetos, "CheckpointCarrera3", Vector2(9728, 520), "Checkpoint activado. Ya casi sales del tramo mas opresivo.")
	_asegurar_checkpoint_mundo_2(objetos, "CheckpointCarrera4", Vector2(12608, 520), "Checkpoint activado. La sala final ya no va a borrarte del mapa.")

	var puzzle_puerta := get_node_or_null("ObjetosMundo2/PuzzlePuerta") as Node2D
	if puzzle_puerta == null:
		puzzle_puerta = Node2D.new()
		puzzle_puerta.name = "PuzzlePuerta"
		objetos.add_child(puzzle_puerta)

	_asegurar_totem_puzzle(puzzle_puerta, "Totem1", Vector2(11248, 616), 1)
	_asegurar_totem_puzzle(puzzle_puerta, "Totem2", Vector2(11408, 616), 2)
	_asegurar_totem_puzzle(puzzle_puerta, "Totem3", Vector2(11568, 616), 3)
	_asegurar_cartel_pista(
		puzzle_puerta,
		"CartelPista",
		Vector2(11672, 620),
		"Presiona E para leer la grieta con las gafas."
	)

	var puzzle_final := get_node_or_null("ObjetosMundo2/PuzzleFinal") as Node2D
	if puzzle_final == null:
		puzzle_final = Node2D.new()
		puzzle_final.name = "PuzzleFinal"
		objetos.add_child(puzzle_final)

	_asegurar_totem_puzzle(puzzle_final, "Totem1", Vector2(12688, 616), 1)
	_asegurar_totem_puzzle(puzzle_final, "Totem2", Vector2(13040, 616), 2)
	_asegurar_totem_puzzle(puzzle_final, "Totem3", Vector2(13392, 616), 3)
	_asegurar_totem_puzzle(puzzle_final, "Totem4", Vector2(13744, 616), 4)

	_asegurar_plataforma_pista(puzzle_final, "PlataformaPista1", Vector2(13072, 448))
	_asegurar_plataforma_pista(puzzle_final, "PlataformaPista2", Vector2(13232, 416))
	_asegurar_plataforma_pista(puzzle_final, "PlataformaPista3", Vector2(13392, 384))
	_asegurar_cartel_pista(
		puzzle_final,
		"CartelPista",
		Vector2(13320, 620),
		"Presiona E para leer el eco del muro con las gafas."
	)


func _asegurar_checkpoint_mundo_2(objetos: Node2D, nombre: String, posicion: Vector2, mensaje: String) -> void:
	var checkpoint := get_node_or_null("ObjetosMundo2/%s" % nombre) as Node2D
	var recien_creado := false
	if checkpoint == null:
		checkpoint = Marker2D.new()
		checkpoint.name = nombre
		objetos.add_child(checkpoint)
		recien_creado = true
	if recien_creado or checkpoint.position == Vector2.ZERO:
		checkpoint.position = posicion

	var punto_visible := checkpoint.get_node_or_null("PuntoVisible") as Sprite2D
	if punto_visible == null:
		punto_visible = Sprite2D.new()
		punto_visible.name = "PuntoVisible"
		checkpoint.add_child(punto_visible)
	punto_visible.texture = TEXTURA_CARTEL
	punto_visible.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	punto_visible.position = Vector2(0, -18)
	punto_visible.scale = Vector2(0.78, 0.78)

	var aura := checkpoint.get_node_or_null("AuraCheckpoint") as Sprite2D
	if aura == null:
		aura = Sprite2D.new()
		aura.name = "AuraCheckpoint"
		checkpoint.add_child(aura)
	aura.position = Vector2(0, -20)
	aura.scale = Vector2(0.78, 0.78)

	var activador := checkpoint.get_node_or_null("Activador") as CheckpointActivador
	if activador == null:
		var area := Area2D.new()
		area.set_script(CHECKPOINT_SCRIPT)
		activador = area as CheckpointActivador
		activador.name = "Activador"
		checkpoint.add_child(activador)
	var shape := activador.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape == null:
		shape = CollisionShape2D.new()
		shape.name = "CollisionShape2D"
		activador.add_child(shape)
	var rect := RectangleShape2D.new()
	rect.size = Vector2(64, 88)
	shape.shape = rect
	shape.position = Vector2(0, -18)
	activador.mensaje_activacion = mensaje


func _asegurar_totem_puzzle(padre: Node2D, nombre: String, posicion: Vector2, numero: int) -> void:
	var totem := padre.get_node_or_null(nombre) as TotemJefe
	if totem == null:
		totem = TOTEM_JEFE_SCENE.instantiate() as TotemJefe
		totem.name = nombre
		padre.add_child(totem)
	totem.position = posicion
	totem.mensaje_interaccion = "Presiona E para enfocar el sello %d con las gafas." % numero
	totem.color_inactivo = Color(0.29, 0.78, 0.92, 0.92)
	totem.color_activo = Color(0.98, 0.91, 0.44, 1.0)
	_asegurar_etiqueta_totem(totem, numero)


func _asegurar_etiqueta_totem(totem: TotemJefe, numero: int) -> void:
	var label := totem.get_node_or_null("NumeroLabel") as Label
	if label == null:
		label = Label.new()
		label.name = "NumeroLabel"
		totem.add_child(label)
	label.text = str(numero)
	label.position = Vector2(-7, -38)
	label.add_theme_font_override("font", FUENTE_PIXEL)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.84, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.08, 0.08, 0.09, 0.92))
	label.add_theme_constant_override("outline_size", 2)


func _asegurar_plataforma_pista(padre: Node2D, nombre: String, posicion: Vector2) -> void:
	var plataforma := padre.get_node_or_null(nombre) as PlataformaGafas
	if plataforma == null:
		plataforma = PLATAFORMA_GAFAS_SCENE.instantiate() as PlataformaGafas
		plataforma.name = nombre
		padre.add_child(plataforma)
	plataforma.position = posicion


func _asegurar_cartel_pista(padre: Node2D, nombre: String, posicion: Vector2, mensaje_interaccion: String) -> void:
	var cartel := padre.get_node_or_null(nombre) as InteractivoBase
	if cartel == null:
		var area := Area2D.new()
		area.set_script(INTERACTIVO_BASE_SCRIPT)
		cartel = area as InteractivoBase
		cartel.name = nombre
		padre.add_child(cartel)
	cartel.position = posicion
	cartel.mensaje_interaccion = mensaje_interaccion

	var sprite := cartel.get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		cartel.add_child(sprite)
	sprite.texture = TEXTURA_CARTEL
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2(0, -16)
	sprite.scale = Vector2(0.82, 0.82)
	sprite.modulate = Color(0.86, 0.95, 1.0, 0.96)

	var label := cartel.get_node_or_null("HintLabel") as Label
	if label == null:
		label = Label.new()
		label.name = "HintLabel"
		cartel.add_child(label)
	label.text = "?"
	label.position = Vector2(-6, -32)
	label.add_theme_font_override("font", FUENTE_PIXEL)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.82, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.08, 0.08, 0.09, 0.92))
	label.add_theme_constant_override("outline_size", 2)

	var shape := cartel.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape == null:
		shape = CollisionShape2D.new()
		shape.name = "CollisionShape2D"
		cartel.add_child(shape)
	var rect := RectangleShape2D.new()
	rect.size = Vector2(60, 92)
	shape.shape = rect
	shape.position = Vector2(0, -18)


func _resolver_nodos() -> void:
	jugador = get_node_or_null("Player/Jugador") as Jugador
	hud = get_node_or_null("Canvas/HUD") as HUD
	menu_pausa = get_node_or_null("Canvas/MenuPausa") as MenuPausa
	muro_carne = get_node_or_null("MuroCarne") as MuroCarne
	punto_respawn = get_node_or_null("SpawnJugador") as Marker2D
	camara_1 = get_node_or_null("Camera2D") as Camera2D
	camara_2 = get_node_or_null("Camera2D2") as Camera2D
	area_camara_1 = get_node_or_null("Area2D") as Area2D
	area_camara_2 = get_node_or_null("Area2D2") as Area2D
	puerta_entrada_mundo_1 = get_node_or_null("PuertaBloqueada") as Node2D
	puerta_puzzle = get_node_or_null("PuertaBloqueada2") as PuertaBloqueada
	puerta_area_final = get_node_or_null("PuertaBloqueada3") as PuertaBloqueada
	salida_entrada_mundo_1 = get_node_or_null("SalidaEntradaMundo1") as Marker2D
	fondo_mundo_final = get_node_or_null("FondoMundoFinal") as Node2D
	ambiente_mundo_2 = get_node_or_null("AmbienteMundo2") as AudioStreamPlayer
	distorsion_overlay = get_node_or_null("Canvas/DistorsionOverlay") as ColorRect
	distorsion_material = distorsion_overlay.material as ShaderMaterial if distorsion_overlay != null else null
	_checkpoints_mundo_2.clear()
	for nombre_checkpoint in ["CheckpointCarrera1", "CheckpointCarrera2", "CheckpointCarrera3", "CheckpointCarrera4"]:
		var checkpoint := get_node_or_null("ObjetosMundo2/%s/Activador" % nombre_checkpoint) as CheckpointActivador
		if checkpoint != null:
			_checkpoints_mundo_2.append(checkpoint)
	_interactivos_mundo_2.clear()
	_totems_puerta.clear()
	_totems_finales.clear()
	for indice in range(1, 4):
		var totem_puerta := get_node_or_null("ObjetosMundo2/PuzzlePuerta/Totem%d" % indice) as TotemJefe
		if totem_puerta != null:
			_totems_puerta.append(totem_puerta)
	for indice in range(1, 5):
		var totem_final := get_node_or_null("ObjetosMundo2/PuzzleFinal/Totem%d" % indice) as TotemJefe
		if totem_final != null:
			_totems_finales.append(totem_final)
	_cartel_pista_puerta = get_node_or_null("ObjetosMundo2/PuzzlePuerta/CartelPista") as InteractivoBase
	_cartel_pista_final = get_node_or_null("ObjetosMundo2/PuzzleFinal/CartelPista") as InteractivoBase
	if punto_respawn != null and punto_respawn.position == Vector2.ZERO:
		punto_respawn.position = posicion_spawn_defecto


func _configurar_jugador_base() -> void:
	if jugador == null:
		return

	jugador.velocidad_base = jugador_velocidad_base
	jugador.fuerza_salto = jugador_fuerza_salto
	jugador.aceleracion = jugador_aceleracion


func _configurar_puertas_decorativas() -> void:
	for child in get_children():
		if child == null or not String(child.name).begins_with("PuertaBloqueada"):
			continue
		if child is Area2D:
			(child as Area2D).monitoring = true
			(child as Area2D).monitorable = true

	if puerta_entrada_mundo_1 != null and puerta_entrada_mundo_1 is PuertaBloqueada:
		var puerta_inicio := puerta_entrada_mundo_1 as PuertaBloqueada
		puerta_inicio.teletransporta_al_tocar = false
		puerta_inicio.permite_interaccion = false

	if puerta_puzzle != null and puerta_area_final != null:
		puerta_puzzle.configurar_destino(puerta_area_final)
		puerta_puzzle.teletransporta_al_tocar = false
		puerta_puzzle.permite_interaccion = true
		puerta_puzzle.mensaje_interaccion = "Presiona E para cruzar la puerta."
		puerta_area_final.configurar_destino(null)
		puerta_area_final.teletransporta_al_tocar = false
		puerta_area_final.permite_interaccion = true
		puerta_area_final.mensaje_interaccion = "Presiona E para salir cuando ordenes los ecos."


func _configurar_interactivos_mundo_2() -> void:
	if puerta_puzzle != null:
		_configurar_interactivo_mundo_2(puerta_puzzle, _on_puerta_puzzle_interaccion_solicitada)
		_interactivos_mundo_2.append(puerta_puzzle)
	if puerta_area_final != null:
		_configurar_interactivo_mundo_2(puerta_area_final, _on_puerta_final_interaccion_solicitada)
		_interactivos_mundo_2.append(puerta_area_final)

	for interactivo in [_cartel_pista_puerta, _cartel_pista_final]:
		if interactivo == null:
			continue
		_configurar_interactivo_mundo_2(interactivo, _on_cartel_pista_interaccion_solicitada.bind(interactivo))
		_interactivos_mundo_2.append(interactivo)

	for indice in range(_totems_puerta.size()):
		var totem_puerta := _totems_puerta[indice]
		if totem_puerta == null:
			continue
		_configurar_interactivo_mundo_2(totem_puerta, _on_totem_puerta_interaccion_solicitada.bind(indice))
		_interactivos_mundo_2.append(totem_puerta)

	for indice in range(_totems_finales.size()):
		var totem_final := _totems_finales[indice]
		if totem_final == null:
			continue
		_configurar_interactivo_mundo_2(totem_final, _on_totem_final_interaccion_solicitada.bind(indice))
		_interactivos_mundo_2.append(totem_final)


func _configurar_interactivo_mundo_2(interactivo: InteractivoBase, callback: Callable) -> void:
	if interactivo == null:
		return

	if not interactivo.interaccion_solicitada.is_connected(callback):
		interactivo.interaccion_solicitada.connect(callback)
	if not interactivo.rango_interaccion_cambiado.is_connected(_on_rango_interaccion_mundo_2_cambiado):
		interactivo.rango_interaccion_cambiado.connect(_on_rango_interaccion_mundo_2_cambiado)


func _configurar_checkpoints_mundo_2() -> void:
	var nombres_checkpoint := [
		"Primer tramo",
		"Mitad del pasillo",
		"Ultimo empujon",
		"Zona segura",
	]
	for indice in range(_checkpoints_mundo_2.size()):
		var activador := _checkpoints_mundo_2[indice]
		if activador == null:
			continue
		var descripcion: String = nombres_checkpoint[indice] if indice < nombres_checkpoint.size() else "Checkpoint"
		if not activador.checkpoint_alcanzado.is_connected(_on_checkpoint_mundo_2_alcanzado.bind(descripcion)):
			activador.checkpoint_alcanzado.connect(_on_checkpoint_mundo_2_alcanzado.bind(descripcion))


func _generar_ordenes_puzzle_mundo_2() -> void:
	_orden_puzzle_puerta = [0, 1, 2]
	_orden_puzzle_final = [0, 1, 2, 3]
	_orden_puzzle_puerta.shuffle()
	_orden_puzzle_final.shuffle()


func _configurar_menu_pausa() -> void:
	if menu_pausa == null:
		return

	menu_pausa.hide()
	if not menu_pausa.continuar_solicitado.is_connected(cerrar_menu_pausa):
		menu_pausa.continuar_solicitado.connect(cerrar_menu_pausa)
	if not menu_pausa.reiniciar_solicitado.is_connected(reiniciar_nivel):
		menu_pausa.reiniciar_solicitado.connect(reiniciar_nivel)
	if not menu_pausa.volver_menu_solicitado.is_connected(volver_al_menu):
		menu_pausa.volver_menu_solicitado.connect(volver_al_menu)
	menu_pausa.establecer_modo_carrera(true)


func _configurar_distorsion_visual() -> void:
	if distorsion_overlay == null:
		return

	if distorsion_overlay.material is ShaderMaterial:
		distorsion_material = (distorsion_overlay.material as ShaderMaterial).duplicate()
		distorsion_material.resource_local_to_scene = true
		distorsion_overlay.material = distorsion_material

	distorsion_overlay.show()
	var color_base := distorsion_overlay.color
	color_base = Color(0.4, 0.72, 0.88, _obtener_alpha_distorsion_objetivo(false))
	distorsion_overlay.color = color_base
	_aplicar_perfil_distorsion(true)


func _configurar_jugador() -> void:
	if jugador == null:
		return

	if not jugador.gafas_actualizadas.is_connected(_on_jugador_gafas_actualizadas):
		jugador.gafas_actualizadas.connect(_on_jugador_gafas_actualizadas)


func _configurar_muro() -> void:
	if muro_carne == null:
		return

	muro_carne.velocidad_base = velocidad_muro
	muro_carne.adelanto_camara = adelanto_camara_muro
	muro_carne.configurar_objetivo(jugador)
	muro_carne.reiniciar(posicion_inicial_muro)
	if not muro_carne.jugador_alcanzado.is_connected(_on_muro_carne_jugador_alcanzado):
		muro_carne.jugador_alcanzado.connect(_on_muro_carne_jugador_alcanzado)


func _configurar_camaras() -> void:
	if area_camara_1 != null and not area_camara_1.body_entered.is_connected(_on_area_camara_1_body_entered):
		area_camara_1.body_entered.connect(_on_area_camara_1_body_entered)

	if area_camara_2 != null and not area_camara_2.body_entered.is_connected(_on_area_camara_2_body_entered):
		area_camara_2.body_entered.connect(_on_area_camara_2_body_entered)

	for camara in [camara_1, camara_2]:
		if camara == null:
			continue
		camara.enabled = false
		camara.zoom = zoom_base_mundo
		camara.position_smoothing_enabled = false

	_actualizar_camara_por_posicion()


func _configurar_pensamientos() -> void:
	if _temporizador_pensamientos != null:
		return

	_temporizador_pensamientos = Timer.new()
	_temporizador_pensamientos.wait_time = INTERVALO_PENSAMIENTOS
	_temporizador_pensamientos.one_shot = false
	_temporizador_pensamientos.ignore_time_scale = true
	_temporizador_pensamientos.timeout.connect(_on_temporizador_pensamientos_timeout)
	add_child(_temporizador_pensamientos)
	_temporizador_pensamientos.start()


func _configurar_hud() -> void:
	if hud == null or jugador == null:
		return

	hud.show()
	hud.configurar_jugador(jugador)
	hud.actualizar_llave(false)
	hud.actualizar_checkpoint(_checkpoint_activo)
	hud.mostrar_mensaje(_obtener_mensaje_base_hud())


func _cargar_guardado_mundo_2() -> void:
	var datos_guardado := SistemaGuardadoClass.cargar_datos()
	_posicion_respawn_actual = punto_respawn.global_position if punto_respawn != null else posicion_spawn_defecto
	_posicion_muro_respawn_actual = posicion_inicial_muro
	var posicion_jugador_objetivo := _posicion_respawn_actual
	var posicion_muro_objetivo := posicion_inicial_muro

	if not _debe_reproducir_entrada_desde_mundo_1() and String(datos_guardado.get("escena_actual", SCENE_PATH)) == SCENE_PATH:
		var datos_mundo_2: Dictionary = Dictionary(datos_guardado.get("mundo_2", {}))
		if not datos_mundo_2.is_empty():
			_posicion_respawn_actual = _parsear_vector2(datos_mundo_2.get("posicion_respawn", _posicion_respawn_actual), _posicion_respawn_actual)
			posicion_jugador_objetivo = _parsear_vector2(datos_mundo_2.get("posicion_jugador", _posicion_respawn_actual), _posicion_respawn_actual)
			posicion_muro_objetivo = _parsear_vector2(datos_mundo_2.get("posicion_muro", posicion_inicial_muro), posicion_inicial_muro)
			_posicion_muro_respawn_actual = _parsear_vector2(datos_mundo_2.get("posicion_muro_respawn", _calcular_posicion_muro_checkpoint(_posicion_respawn_actual)), _calcular_posicion_muro_checkpoint(_posicion_respawn_actual))
			_checkpoint_activo = bool(datos_mundo_2.get("checkpoint_activo", false))
			_descripcion_checkpoint_actual = String(datos_mundo_2.get("checkpoint_descripcion", _descripcion_checkpoint_actual))
			_escape_muro_completado = bool(datos_mundo_2.get("escape_muro_completado", false))
			_puzzle_puerta_completado = bool(datos_mundo_2.get("puzzle_puerta_completado", false))
			_puzzle_final_completado = bool(datos_mundo_2.get("puzzle_final_completado", false))

	if _escape_muro_completado:
		var checkpoint_final := get_node_or_null("ObjetosMundo2/CheckpointCarrera4") as Node2D
		var posicion_segura := checkpoint_final.global_position if checkpoint_final != null else Vector2(12608, 520)
		_checkpoint_activo = true
		if _descripcion_checkpoint_actual == "Inicio del mundo 2":
			_descripcion_checkpoint_actual = "Zona segura"
		if _posicion_respawn_actual.x < umbral_escape_jugador_x:
			_posicion_respawn_actual = posicion_segura
		if posicion_jugador_objetivo.x < umbral_escape_jugador_x:
			posicion_jugador_objetivo = _posicion_respawn_actual
		posicion_muro_objetivo = Vector2(limite_escape_muro_x, posicion_inicial_muro.y)
		_posicion_muro_respawn_actual = _calcular_posicion_muro_checkpoint(_posicion_respawn_actual)

	if punto_respawn != null:
		punto_respawn.global_position = _posicion_respawn_actual
		_posicion_respawn_actual = punto_respawn.global_position

	if jugador != null and jugador.has_method("restaurar_para_respawn"):
		jugador.restaurar_para_respawn(posicion_jugador_objetivo)

	if muro_carne != null:
		muro_carne.reiniciar(posicion_muro_objetivo)


func _guardar_progreso() -> void:
	if _intro_persecucion_activa or jugador == null or not is_instance_valid(jugador):
		return

	if punto_respawn == null:
		_posicion_respawn_actual = posicion_spawn_defecto
	else:
		_posicion_respawn_actual = punto_respawn.global_position

	var datos_mundo_2 := {
		"posicion_respawn": _posicion_respawn_actual,
		"posicion_jugador": jugador.global_position,
		"posicion_muro": muro_carne.global_position if muro_carne != null else posicion_inicial_muro,
		"posicion_muro_respawn": _posicion_muro_respawn_actual,
		"checkpoint_activo": _checkpoint_activo,
		"checkpoint_descripcion": _descripcion_checkpoint_actual,
		"escape_muro_completado": _escape_muro_completado,
		"puzzle_puerta_completado": _puzzle_puerta_completado,
		"puzzle_final_completado": _puzzle_final_completado,
	}
	SistemaGuardadoClass.guardar_estado_mundo_2(datos_mundo_2)


func _reiniciar_carrera(con_animacion_muerte: bool, mensaje: String) -> void:
	if _respawn_activo or jugador == null:
		return

	_respawn_activo = true
	_token_restablecer_mensaje += 1
	var token_actual := _token_restablecer_mensaje

	if _pausa_activa:
		cerrar_menu_pausa()
	_restaurar_tiempo_normal()

	if muro_carne != null:
		muro_carne.establecer_congelado(true)
		muro_carne.establecer_activo(false)

	jugador.velocity = Vector2.ZERO
	jugador.establecer_control_habilitado(false)

	if con_animacion_muerte and jugador.has_method("reproducir_muerte"):
		await jugador.reproducir_muerte()

	jugador.restaurar_para_respawn(_posicion_respawn_actual)
	_aplicar_estado_gafas(false, true)

	if muro_carne != null:
		muro_carne.reiniciar(_posicion_muro_respawn_actual)
		muro_carne.establecer_multiplicador_velocidad(1.0)
	_aplicar_estado_progresion_mundo_2(true)

	_actualizar_camara_por_posicion()
	_sincronizar_camara_con_jugador(true, 0.0)
	_actualizar_presion_ambiente()
	jugador.establecer_control_habilitado(true)
	_guardar_progreso()
	if hud != null:
		hud.mostrar_mensaje(mensaje)

	if mensaje == mensaje_fallo_muro:
		_reiniciar_ciclo_pensamientos()
		_programar_restablecer_mensaje_llegada(token_actual)

	_respawn_activo = false


func _actualizar_camara_por_posicion() -> void:
	if jugador == null:
		return

	var camara_objetivo := camara_1
	if _debe_usar_camara_2(jugador.global_position) and camara_2 != null:
		camara_objetivo = camara_2
	elif _debe_usar_camara_1(jugador.global_position) and camara_1 != null:
		camara_objetivo = camara_1
	elif camara_2 != null and camara_1 == null:
		camara_objetivo = camara_2

	_activar_camara(camara_objetivo)


func _activar_camara(camara_objetivo: Camera2D) -> void:
	if camara_objetivo == null:
		return

	if _camara_actual == camara_objetivo and camara_objetivo.enabled:
		return

	for camara in [camara_1, camara_2]:
		if camara == null:
			continue
		camara.enabled = camara == camara_objetivo

	_camara_actual = camara_objetivo
	_camara_actual.make_current()


func _sincronizar_camara_con_jugador(forzar: bool = false, delta: float = 0.0) -> void:
	if _camara_actual == null or jugador == null:
		return

	var objetivo_x := jugador.global_position.x + adelanto_camara_jugador
	if muro_carne != null and not _escape_muro_completado:
		objetivo_x = maxf(objetivo_x, muro_carne.obtener_x_impulso_camara())

	var objetivo := Vector2(objetivo_x, jugador.global_position.y + offset_camara.y)
	objetivo += _obtener_offset_temblor_camara()
	if forzar or delta <= 0.0:
		_camara_actual.global_position = objetivo
		return

	var peso := clampf(delta * suavizado_camara, 0.0, 1.0)
	_camara_actual.global_position = _camara_actual.global_position.lerp(objetivo, peso)


func _on_area_camara_1_body_entered(body: Node) -> void:
	if body != null and body.is_in_group("jugador"):
		_activar_camara(camara_1)


func _on_area_camara_2_body_entered(body: Node) -> void:
	if body != null and body.is_in_group("jugador"):
		_asegurar_respawn_seguro_final()
		_activar_camara(camara_2)
		if hud != null and not _puzzle_final_completado:
			hud.mostrar_mensaje(mensaje_puzzle_final)


func _on_jugador_gafas_actualizadas(activa: bool, _duracion_restante: float, _cooldown_restante: float, _cooldown_actual: float, _siguiente_cooldown: float) -> void:
	if activa == _estado_gafas_aplicado:
		_aplicar_alpha_distorsion_actual(false)
		_aplicar_perfil_distorsion(false)
		return

	_aplicar_estado_gafas(activa)
	if activa:
		if hud != null and hud.has_method("mostrar_mensaje"):
			hud.mostrar_mensaje("Las gafas revelan plataformas y te dan un instante de claridad.")
		_mostrar_pensamiento_gafas()


func _aplicar_estado_gafas(activa: bool, instantaneo: bool = false) -> void:
	_estado_gafas_aplicado = activa
	if muro_carne != null:
		muro_carne.establecer_multiplicador_velocidad(FACTOR_LENTITUD_GAFAS_MURO if activa else 1.0)

	for plataforma in get_tree().get_nodes_in_group("plataforma_gafas"):
		if plataforma != null and plataforma.has_method("establecer_revelada"):
			plataforma.establecer_revelada(activa)

	if ambiente_mundo_2 != null and ambiente_mundo_2.has_method("establecer_claridad_gafas"):
		ambiente_mundo_2.establecer_claridad_gafas(activa)

	_animar_transicion_gafas(activa, instantaneo)


func _animar_transicion_gafas(activa: bool, instantaneo: bool) -> void:
	var zoom_objetivo := zoom_con_gafas if activa else zoom_base_mundo
	var alpha_objetivo := _obtener_alpha_distorsion_objetivo(activa)
	if _tween_zoom != null and _tween_zoom.is_valid():
		_tween_zoom.kill()
	if _tween_alpha_distorsion != null and _tween_alpha_distorsion.is_valid():
		_tween_alpha_distorsion.kill()

	if instantaneo:
		_aplicar_zoom_camaras(zoom_objetivo)
		_aplicar_perfil_distorsion(true)
		_aplicar_alpha_distorsion_actual(true)
		return

	_tween_zoom = create_tween()
	_tween_zoom.set_parallel(true)
	_tween_zoom.set_ignore_time_scale(true)
	_tween_zoom.set_trans(Tween.TRANS_SINE)
	_tween_zoom.set_ease(Tween.EASE_IN_OUT)
	for camara in [camara_1, camara_2]:
		if camara != null:
			_tween_zoom.tween_property(camara, "zoom", zoom_objetivo, duracion_transicion_gafas)

	if distorsion_overlay != null:
		var color_objetivo := distorsion_overlay.color
		color_objetivo.a = alpha_objetivo
		_tween_zoom.tween_property(distorsion_overlay, "color", color_objetivo, duracion_transicion_gafas)

	_aplicar_perfil_distorsion(false)


func _aplicar_zoom_camaras(zoom_objetivo: Vector2) -> void:
	for camara in [camara_1, camara_2]:
		if camara != null:
			camara.zoom = zoom_objetivo


func _procesar_interaccion_mundo_2() -> void:
	for interactivo in _interactivos_mundo_2:
		if interactivo != null and interactivo.esta_en_rango():
			interactivo.interactuar()
			return


func _on_rango_interaccion_mundo_2_cambiado(activo: bool, mensaje: String) -> void:
	if hud == null or _pausa_activa or _respawn_activo or _intro_persecucion_activa:
		return

	if activo:
		hud.mostrar_mensaje(mensaje)
		return

	_restaurar_mensaje_hud()


func _on_checkpoint_mundo_2_alcanzado(posicion: Vector2, mensaje: String, descripcion: String) -> void:
	_checkpoint_activo = true
	_descripcion_checkpoint_actual = descripcion
	_posicion_respawn_actual = posicion
	if punto_respawn != null:
		punto_respawn.global_position = posicion
	_actualizar_resguardo_muro_checkpoint(posicion, true)
	if hud != null:
		hud.actualizar_checkpoint(true)
		hud.mostrar_mensaje(mensaje)
	_guardar_progreso()


func _asegurar_respawn_seguro_final() -> void:
	var checkpoint_final := get_node_or_null("ObjetosMundo2/CheckpointCarrera4") as Node2D
	if checkpoint_final == null:
		return

	var posicion_segura := checkpoint_final.global_position
	if _posicion_respawn_actual.is_equal_approx(posicion_segura) and _descripcion_checkpoint_actual == "Zona segura":
		return

	_checkpoint_activo = true
	_descripcion_checkpoint_actual = "Zona segura"
	_posicion_respawn_actual = posicion_segura
	if punto_respawn != null:
		punto_respawn.global_position = posicion_segura
	_actualizar_resguardo_muro_checkpoint(posicion_segura, false)
	if hud != null:
		hud.actualizar_checkpoint(true)
	_guardar_progreso()


func _on_cartel_pista_interaccion_solicitada(cartel: InteractivoBase) -> void:
	if hud == null:
		return

	if jugador == null or not jugador.gafas_activas():
		hud.mostrar_mensaje("Sin las gafas, las grietas solo parecen ruido roto.")
		return

	if cartel == _cartel_pista_puerta:
		hud.mostrar_mensaje("La grieta repite: %s." % _formatear_orden_para_pista(_orden_puzzle_puerta))
		hud.mostrar_pensamiento("Si lo veo claro, puedo romper el patron.", true)
		return

	if cartel == _cartel_pista_final:
		_mostrar_popup_pista_puzzle(
			"Eco del muro",
			"Orden visible con las gafas:\n%s" % _formatear_orden_para_pista(_orden_puzzle_final)
		)
		hud.mostrar_pensamiento("El orden tambien puede aparecer dentro del ruido.", true)


func _on_totem_puerta_interaccion_solicitada(indice_totem: int) -> void:
	if hud == null or _puzzle_puerta_completado:
		return

	if jugador == null or not jugador.gafas_activas():
		hud.mostrar_mensaje("Los sellos de la puerta solo reaccionan con las gafas activas.")
		return

	if indice_totem < 0 or indice_totem >= _totems_puerta.size():
		return

	var totem := _totems_puerta[indice_totem]
	if totem == null or totem.esta_activado():
		return

	var esperado := _orden_puzzle_puerta[_progreso_puzzle_puerta]
	if indice_totem != esperado:
		hud.mostrar_mensaje("Las burlas se mezclaron otra vez. Empieza de nuevo la secuencia.")
		_reiniciar_totems(_totems_puerta)
		_progreso_puzzle_puerta = 0
		return

	totem.activar()
	_progreso_puzzle_puerta += 1
	if _progreso_puzzle_puerta >= _orden_puzzle_puerta.size():
		_completar_puzzle_puerta()
		return

	hud.mostrar_mensaje("Sello correcto %d/%d." % [_progreso_puzzle_puerta, _orden_puzzle_puerta.size()])


func _on_puerta_puzzle_interaccion_solicitada() -> void:
	if puerta_puzzle == null or jugador == null or hud == null:
		return

	if not _puzzle_puerta_completado or not puerta_puzzle.esta_abierta():
		hud.mostrar_mensaje("La puerta sigue sellada. Primero debes romper el patron correcto.")
		return

	puerta_puzzle.teletransportar_jugador(jugador)


func _on_puerta_final_interaccion_solicitada() -> void:
	if puerta_area_final == null or jugador == null or hud == null:
		return

	if not _puzzle_final_completado or not puerta_area_final.esta_abierta():
		hud.mostrar_mensaje("La salida sigue cerrada. Ordena los ecos del muro antes de cruzar.")
		return

	call_deferred("_cruzar_puerta_final_mundo_2")


func _on_totem_final_interaccion_solicitada(indice_totem: int) -> void:
	if hud == null or _puzzle_final_completado:
		return

	if jugador == null or not jugador.gafas_activas():
		hud.mostrar_mensaje("Solo con las gafas puedes enfocar estos ecos.")
		return

	if indice_totem < 0 or indice_totem >= _totems_finales.size():
		return

	var totem := _totems_finales[indice_totem]
	if totem == null or totem.esta_activado():
		return

	var esperado := _orden_puzzle_final[_progreso_puzzle_final]
	if indice_totem != esperado:
		hud.mostrar_mensaje("El eco se rompio. Debes reconstruir el orden desde cero.")
		_reiniciar_totems(_totems_finales)
		_progreso_puzzle_final = 0
		return

	totem.activar()
	_progreso_puzzle_final += 1
	if _progreso_puzzle_final >= _orden_puzzle_final.size():
		_completar_puzzle_final()
		return

	hud.mostrar_mensaje("Eco correcto %d/%d." % [_progreso_puzzle_final, _orden_puzzle_final.size()])


func _completar_puzzle_puerta() -> void:
	_puzzle_puerta_completado = true
	_aplicar_estado_puertas_puzzle(false)
	if hud != null:
		hud.mostrar_mensaje("La puerta reconocio el patron. Ya puedes cruzarla.")
		hud.mostrar_pensamiento("No todas sus voces pueden seguir cerrandome el paso.", true)
	_guardar_progreso()


func _completar_puzzle_final() -> void:
	_puzzle_final_completado = true
	_aplicar_estado_puertas_puzzle(false)
	if hud != null:
		hud.mostrar_mensaje("Los ecos quedaron ordenados. La puerta final ya puede abrirse.")
		hud.mostrar_pensamiento("Hasta el ruido mas cruel termina cediendo cuando lo ordeno.", true)
	_guardar_progreso()


func _mostrar_popup_pista_puzzle(titulo: String, cuerpo: String) -> void:
	if _popup_pista_puzzle == null or not is_instance_valid(_popup_pista_puzzle):
		_popup_pista_puzzle = _crear_popup_pista_puzzle()
	if _popup_pista_puzzle == null:
		return

	var titulo_label := _popup_pista_puzzle.get_node_or_null("Margin/VBox/Titulo") as Label
	var cuerpo_label := _popup_pista_puzzle.get_node_or_null("Margin/VBox/Cuerpo") as Label
	if titulo_label != null:
		titulo_label.text = titulo.to_upper()
	if cuerpo_label != null:
		cuerpo_label.text = cuerpo

	if _tween_popup_pista != null and _tween_popup_pista.is_valid():
		_tween_popup_pista.kill()

	_popup_pista_puzzle.visible = true
	_popup_pista_puzzle.modulate.a = 0.0
	_popup_pista_puzzle.scale = Vector2(0.94, 0.94)
	_popup_pista_puzzle.pivot_offset = _popup_pista_puzzle.size * 0.5
	_tween_popup_pista = create_tween()
	_tween_popup_pista.set_ignore_time_scale(true)
	_tween_popup_pista.set_trans(Tween.TRANS_BACK)
	_tween_popup_pista.set_ease(Tween.EASE_OUT)
	_tween_popup_pista.tween_property(_popup_pista_puzzle, "modulate:a", 1.0, 0.18)
	_tween_popup_pista.parallel().tween_property(_popup_pista_puzzle, "scale", Vector2.ONE, 0.22)
	_tween_popup_pista.tween_interval(4.2)
	_tween_popup_pista.set_trans(Tween.TRANS_SINE)
	_tween_popup_pista.set_ease(Tween.EASE_IN)
	_tween_popup_pista.tween_property(_popup_pista_puzzle, "modulate:a", 0.0, 0.24)
	_tween_popup_pista.tween_callback(_popup_pista_puzzle.hide)


func _crear_popup_pista_puzzle() -> PanelContainer:
	var canvas := get_node_or_null("Canvas") as CanvasLayer
	if canvas == null:
		return null

	var popup := PanelContainer.new()
	popup.name = "PopupPistaPuzzle"
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.visible = false
	popup.custom_minimum_size = Vector2(430, 126)
	popup.anchor_left = 0.5
	popup.anchor_top = 0.5
	popup.anchor_right = 0.5
	popup.anchor_bottom = 0.5
	popup.offset_left = -215.0
	popup.offset_top = -96.0
	popup.offset_right = 215.0
	popup.offset_bottom = 30.0
	popup.add_theme_stylebox_override("panel", _crear_estilo_popup_pista())
	canvas.add_child(popup)
	canvas.move_child(popup, canvas.get_child_count() - 1)

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 16)
	popup.add_child(margin)

	var caja := VBoxContainer.new()
	caja.name = "VBox"
	caja.add_theme_constant_override("separation", 8)
	margin.add_child(caja)

	var titulo := Label.new()
	titulo.name = "Titulo"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_override("font", FUENTE_PIXEL)
	titulo.add_theme_font_size_override("font_size", 11)
	titulo.add_theme_color_override("font_color", Color(0.82, 0.94, 0.46, 1.0))
	caja.add_child(titulo)

	var cuerpo := Label.new()
	cuerpo.name = "Cuerpo"
	cuerpo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cuerpo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cuerpo.add_theme_font_override("font", FUENTE_PIXEL)
	cuerpo.add_theme_font_size_override("font_size", 10)
	cuerpo.add_theme_color_override("font_color", Color(0.90, 0.98, 0.92, 1.0))
	caja.add_child(cuerpo)
	return popup


func _crear_estilo_popup_pista() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.045, 0.055, 0.065, 0.94)
	estilo.border_width_left = 2
	estilo.border_width_top = 2
	estilo.border_width_right = 2
	estilo.border_width_bottom = 2
	estilo.border_color = Color(0.68, 0.86, 0.46, 0.92)
	estilo.corner_radius_top_left = 10
	estilo.corner_radius_top_right = 10
	estilo.corner_radius_bottom_left = 10
	estilo.corner_radius_bottom_right = 10
	estilo.shadow_color = Color(0.0, 0.0, 0.0, 0.36)
	estilo.shadow_size = 12
	return estilo


func _reproducir_cierre_provisional_mundo_2() -> void:
	if _cierre_final_mostrado or jugador == null or not is_instance_valid(jugador):
		return

	_cierre_final_mostrado = true
	jugador.establecer_control_habilitado(false)
	if muro_carne != null:
		muro_carne.establecer_congelado(true)

	var cutscene := CUTSCENE_BASE_SCRIPT.new()
	add_child(cutscene)
	await cutscene.reproducir_final_provisional()
	cutscene.queue_free()

	if jugador != null and is_instance_valid(jugador):
		jugador.establecer_control_habilitado(true)
	if muro_carne != null and not _escape_muro_completado:
		muro_carne.establecer_congelado(false)


func _cruzar_puerta_final_mundo_2() -> void:
	if _cierre_final_mostrado or jugador == null or not is_instance_valid(jugador):
		return

	_intro_persecucion_activa = true
	jugador.establecer_control_habilitado(false)
	if muro_carne != null:
		muro_carne.establecer_congelado(true)
		muro_carne.establecer_activo(false)

	if puerta_area_final != null and jugador.has_method("animar_entrada_puerta"):
		await jugador.animar_entrada_puerta(puerta_area_final.global_position + Vector2(0, 10), 0.34)

	await _reproducir_cierre_provisional_mundo_2()

	if jugador != null and is_instance_valid(jugador):
		jugador.finalizar_animacion_puerta()
		jugador.establecer_control_habilitado(true)
	_intro_persecucion_activa = false
	_guardar_progreso()


func _reiniciar_totems(totems: Array[TotemJefe]) -> void:
	for totem in totems:
		if totem != null and totem.has_method("reiniciar_totem"):
			totem.reiniciar_totem()


func _marcar_totems_completados(totems: Array[TotemJefe]) -> void:
	for totem in totems:
		if totem != null and not totem.esta_activado():
			totem.activar()


func _aplicar_estado_puertas_puzzle(silencioso: bool) -> void:
	if puerta_puzzle != null and _puzzle_puerta_completado:
		puerta_puzzle.abrir(silencioso)
	if puerta_area_final != null and _puzzle_final_completado:
		puerta_area_final.abrir(silencioso)


func _aplicar_estado_escape_muro() -> void:
	if muro_carne == null:
		return

	if _escape_muro_completado:
		muro_carne.global_position.x = limite_escape_muro_x
		muro_carne.establecer_congelado(true)
		muro_carne.establecer_activo(false)
		return

	muro_carne.global_position.x = minf(muro_carne.global_position.x, limite_escape_muro_x)
	muro_carne.establecer_activo(true)
	muro_carne.establecer_congelado(false)
	muro_carne.establecer_multiplicador_velocidad(FACTOR_LENTITUD_GAFAS_MURO if jugador != null and jugador.gafas_activas() else 1.0)


func _aplicar_estado_progresion_mundo_2(silencioso: bool) -> void:
	if _puzzle_puerta_completado:
		_progreso_puzzle_puerta = _orden_puzzle_puerta.size()
		_marcar_totems_completados(_totems_puerta)
	else:
		_progreso_puzzle_puerta = 0
		_reiniciar_totems(_totems_puerta)

	if _puzzle_final_completado:
		_progreso_puzzle_final = _orden_puzzle_final.size()
		_marcar_totems_completados(_totems_finales)
	else:
		_progreso_puzzle_final = 0
		_reiniciar_totems(_totems_finales)

	_aplicar_estado_puertas_puzzle(silencioso)
	_aplicar_estado_escape_muro()


func _actualizar_estado_escape_muro() -> void:
	if _escape_muro_completado or jugador == null:
		return

	if muro_carne != null and muro_carne.global_position.x >= limite_escape_muro_x:
		muro_carne.global_position.x = limite_escape_muro_x

	if jugador.global_position.x < umbral_escape_jugador_x:
		return

	_escape_muro_completado = true
	_aplicar_estado_escape_muro()
	if hud != null:
		hud.mostrar_mensaje(mensaje_puzzle_puerta)
	_mostrar_pensamientos_escape()
	_guardar_progreso()


func _mostrar_pensamientos_escape() -> void:
	if _pensamientos_escape_mostrados or hud == null or not hud.has_method("mostrar_pensamiento"):
		return

	_pensamientos_escape_mostrados = true
	_mostrar_pensamientos_escape_async()


func _mostrar_pensamientos_escape_async() -> void:
	hud.mostrar_pensamiento(mensaje_escape_muro_1)
	await get_tree().create_timer(4.6, true, false, true).timeout
	if hud == null or not is_instance_valid(hud) or not _escape_muro_completado:
		return
	hud.mostrar_pensamiento(mensaje_escape_muro_2)


func _formatear_orden_para_pista(orden: Array[int]) -> String:
	var partes: Array[String] = []
	for indice in orden:
		partes.append(str(int(indice) + 1))
	return " - ".join(partes)


func _obtener_mensaje_base_hud() -> String:
	if _puzzle_final_completado:
		return "Los ecos del muro ya no dominan esta sala."
	if _puzzle_puerta_completado:
		return "La puerta esta abierta. Cruza y sigue la nueva pista."
	if _escape_muro_completado:
		return mensaje_puzzle_puerta
	return mensaje_llegada


func _restaurar_mensaje_hud() -> void:
	if hud == null:
		return
	hud.mostrar_mensaje(_obtener_mensaje_base_hud())


func _on_muro_carne_jugador_alcanzado() -> void:
	if _escape_muro_completado:
		return
	call_deferred("_reiniciar_carrera", true, mensaje_fallo_muro)


func _debe_reproducir_entrada_desde_mundo_1() -> bool:
	return String(_datos_transicion_entrada.get("escena_destino", "")) == SCENE_PATH and String(_datos_transicion_entrada.get("id_entrada", "")) == "entrada_mundo_1"


func _reproducir_intro_entrada_mundo_1() -> void:
	if jugador == null:
		_guardar_progreso()
		return

	_intro_persecucion_activa = true
	if hud != null:
		hud.mostrar_mensaje("No mires atras. Solo corre.")
		if hud.has_method("mostrar_pensamiento"):
			hud.mostrar_pensamiento("Otra puerta, otro pasillo. No te detengas.", false)

	if muro_carne != null:
		muro_carne.establecer_congelado(true)
		muro_carne.establecer_activo(false)
		muro_carne.reiniciar(posicion_inicial_muro - Vector2(124, 0))

	jugador.establecer_control_habilitado(false)
	var destino := salida_entrada_mundo_1.global_position if salida_entrada_mundo_1 != null else posicion_spawn_defecto
	var origen := (puerta_entrada_mundo_1.global_position + Vector2(0, 8)) if puerta_entrada_mundo_1 != null else destino
	_posicion_respawn_actual = destino
	jugador.restaurar_para_respawn(destino)
	jugador.establecer_control_habilitado(false)
	if puerta_entrada_mundo_1 != null and puerta_entrada_mundo_1.has_method("abrir"):
		puerta_entrada_mundo_1.abrir()

	var overlay := _crear_overlay_intro()
	await jugador.animar_salida_puerta(origen, destino, duracion_intro_entrada_puerta)
	jugador.establecer_control_habilitado(false)
	_actualizar_camara_por_posicion()
	_sincronizar_camara_con_jugador(true, 0.0)

	var tween := create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(overlay, "color:a", 0.0, 0.75)
	await tween.finished
	overlay.queue_free()
	var cutscene := CUTSCENE_BASE_SCRIPT.new()
	add_child(cutscene)
	await cutscene.reproducir_transicion_mundo_2()
	cutscene.queue_free()
	await get_tree().create_timer(espera_inicio_persecucion, true, false, true).timeout

	if muro_carne != null:
		var tween_muro := create_tween()
		tween_muro.set_ignore_time_scale(true)
		tween_muro.set_trans(Tween.TRANS_CUBIC)
		tween_muro.set_ease(Tween.EASE_OUT)
		tween_muro.tween_property(muro_carne, "global_position", posicion_inicial_muro, 0.55)
		await tween_muro.finished
		muro_carne.establecer_activo(true)
		muro_carne.establecer_congelado(false)
		muro_carne.establecer_multiplicador_velocidad(FACTOR_LENTITUD_GAFAS_MURO if jugador.gafas_activas() else 1.0)

	jugador.establecer_control_habilitado(true)
	_intro_persecucion_activa = false
	_actualizar_presion_ambiente()
	_guardar_progreso()


func _crear_overlay_intro() -> ColorRect:
	var overlay := ColorRect.new()
	overlay.anchor_left = 0.0
	overlay.anchor_top = 0.0
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.offset_left = 0.0
	overlay.offset_top = 0.0
	overlay.offset_right = 0.0
	overlay.offset_bottom = 0.0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.color = Color(0.01, 0.02, 0.03, 0.62)
	$Canvas.add_child(overlay)
	$Canvas.move_child(overlay, $Canvas.get_child_count() - 1)
	return overlay


func _configurar_peligro_ambiente(valor: float) -> void:
	if ambiente_mundo_2 != null and ambiente_mundo_2.has_method("establecer_presion"):
		ambiente_mundo_2.establecer_presion(valor)


func _actualizar_presion_ambiente() -> void:
	if ambiente_mundo_2 == null or jugador == null or muro_carne == null:
		return

	if _escape_muro_completado:
		_configurar_peligro_ambiente(0.0)
		return

	var distancia := maxf(jugador.global_position.x - muro_carne.global_position.x, 0.0)
	var presion := 1.0 - clampf((distancia - 128.0) / maxf(distancia_peligro_maxima_muro, 64.0), 0.0, 1.0)
	_configurar_peligro_ambiente(presion)


func _on_temporizador_pensamientos_timeout() -> void:
	if _pausa_activa or _respawn_activo or hud == null or not hud.has_method("mostrar_pensamiento"):
		return

	hud.mostrar_pensamiento(_obtener_pensamiento_siguiente())


func _obtener_pensamiento_siguiente() -> String:
	if PENSAMIENTOS_OSCUROS.is_empty():
		return ""

	var mensaje: String = PENSAMIENTOS_OSCUROS[_indice_pensamiento % PENSAMIENTOS_OSCUROS.size()]
	_indice_pensamiento += 1
	return mensaje


func _mostrar_pensamiento_gafas() -> void:
	if PENSAMIENTOS_GAFAS.is_empty() or hud == null or not hud.has_method("mostrar_pensamiento"):
		return

	var mensaje: String = PENSAMIENTOS_GAFAS[_indice_pensamiento_gafas % PENSAMIENTOS_GAFAS.size()]
	_indice_pensamiento_gafas += 1
	hud.mostrar_pensamiento(mensaje, true)
	if _temporizador_pensamientos != null:
		_temporizador_pensamientos.start(INTERVALO_PENSAMIENTOS)


func _reiniciar_ciclo_pensamientos() -> void:
	_indice_pensamiento = 0
	if _temporizador_pensamientos != null:
		_temporizador_pensamientos.start(INTERVALO_PENSAMIENTOS)


func _programar_restablecer_mensaje_llegada(token_actual: int) -> void:
	_restablecer_mensaje_llegada_async(token_actual)


func _restablecer_mensaje_llegada_async(token_actual: int) -> void:
	await get_tree().create_timer(duracion_restablecer_mensaje_llegada).timeout
	if token_actual != _token_restablecer_mensaje:
		return
	if hud == null or not is_instance_valid(hud):
		return
	_restaurar_mensaje_hud()


func _obtener_alpha_distorsion_objetivo(gafas_activas: bool) -> float:
	return alpha_distorsion_gafas if gafas_activas else alpha_distorsion_base


func _aplicar_perfil_distorsion(_instantaneo: bool) -> void:
	if distorsion_material == null:
		return

	distorsion_material.set_shader_parameter("center", Vector2(0.5, 0.5))
	distorsion_material.set_shader_parameter("vignette_radius", vignette_radius_base)
	distorsion_material.set_shader_parameter("vignette_softness", vignette_softness_base)
	distorsion_material.set_shader_parameter("blur_strength", blur_strength_base)
	distorsion_material.set_shader_parameter("edge_darkness", edge_darkness_base)
	distorsion_material.set_shader_parameter("tint_strength", tint_strength_base)
	distorsion_material.set_shader_parameter("edge_desaturation", edge_desaturation_base)
	distorsion_material.set_shader_parameter("aberration_strength", aberration_strength_base)
	distorsion_material.set_shader_parameter("pulse_strength", pulse_strength_base)
	distorsion_material.set_shader_parameter("pulse_speed", pulse_speed_base)


func _aplicar_alpha_distorsion_actual(instantaneo: bool) -> void:
	if distorsion_overlay == null:
		return

	var alpha_objetivo := _obtener_alpha_distorsion_objetivo(_estado_gafas_aplicado)
	if _tween_alpha_distorsion != null and _tween_alpha_distorsion.is_valid():
		_tween_alpha_distorsion.kill()

	if instantaneo:
		var color_actual := distorsion_overlay.color
		color_actual.a = alpha_objetivo
		distorsion_overlay.color = color_actual
		return

	var color_objetivo := distorsion_overlay.color
	color_objetivo.a = alpha_objetivo
	_tween_alpha_distorsion = create_tween()
	_tween_alpha_distorsion.set_trans(Tween.TRANS_SINE)
	_tween_alpha_distorsion.set_ease(Tween.EASE_IN_OUT)
	_tween_alpha_distorsion.set_ignore_time_scale(true)
	_tween_alpha_distorsion.tween_property(distorsion_overlay, "color", color_objetivo, duracion_transicion_gafas)


func _actualizar_escala_tiempo() -> void:
	Engine.time_scale = ESCALA_TIEMPO_PAUSA if _pausa_activa else 1.0


func _restaurar_tiempo_normal() -> void:
	Engine.time_scale = 1.0


func _area_contiene_posicion(area: Area2D, posicion_global: Vector2) -> bool:
	if area == null:
		return false

	for child in area.get_children():
		if child is CollisionShape2D and _shape_contiene_posicion(child as CollisionShape2D, posicion_global):
			return true

	return false


func _debe_usar_camara_1(posicion_global: Vector2) -> bool:
	if camara_1 == null:
		return false
	if _area_contiene_posicion(area_camara_1, posicion_global):
		return true
	return posicion_global.x <= float(camara_1.limit_right) + 24.0


func _debe_usar_camara_2(posicion_global: Vector2) -> bool:
	if camara_2 == null:
		return false
	if _area_contiene_posicion(area_camara_2, posicion_global):
		return true
	return posicion_global.x >= float(camara_2.limit_left) - 24.0


func _actualizar_resguardo_muro_checkpoint(posicion_checkpoint: Vector2, aplicar_inmediatamente: bool) -> void:
	_posicion_muro_respawn_actual = _calcular_posicion_muro_checkpoint(posicion_checkpoint)
	if not aplicar_inmediatamente or muro_carne == null or _escape_muro_completado:
		return

	muro_carne.reiniciar(_posicion_muro_respawn_actual)
	muro_carne.establecer_multiplicador_velocidad(FACTOR_LENTITUD_GAFAS_MURO if jugador != null and jugador.gafas_activas() else 1.0)


func _calcular_posicion_muro_checkpoint(posicion_checkpoint: Vector2) -> Vector2:
	if _escape_muro_completado:
		return Vector2(limite_escape_muro_x, posicion_inicial_muro.y)

	var objetivo_x := maxf(posicion_inicial_muro.x, posicion_checkpoint.x - distancia_retroceso_muro_checkpoint)
	objetivo_x = minf(objetivo_x, limite_escape_muro_x - 96.0)
	return Vector2(objetivo_x, posicion_inicial_muro.y)


func _obtener_offset_temblor_camara() -> Vector2:
	if _escape_muro_completado or muro_carne == null or jugador == null:
		return Vector2.ZERO

	var distancia := jugador.global_position.x - muro_carne.global_position.x
	if distancia <= 0.0:
		return Vector2.ZERO

	var intensidad := 1.0 - clampf(distancia / maxf(distancia_temblor_maxima, 1.0), 0.0, 1.0)
	intensidad *= _obtener_factor_temblor_configurado()
	if intensidad <= 0.01:
		return Vector2.ZERO

	var tiempo := Time.get_ticks_msec() * 0.001 * frecuencia_temblor_camara
	return Vector2(
		sin(tiempo * 1.13) * amplitud_temblor_camara.x * intensidad,
		cos(tiempo * 1.67) * amplitud_temblor_camara.y * intensidad
	)


func _obtener_factor_temblor_configurado() -> float:
	var menu_opciones := get_node_or_null("/root/MenuOpciones")
	if menu_opciones != null and menu_opciones.has_method("obtener_factor_temblor_camara"):
		return float(menu_opciones.call("obtener_factor_temblor_camara"))
	return 1.0


func _shape_contiene_posicion(shape_node: CollisionShape2D, posicion_global: Vector2) -> bool:
	if shape_node == null or shape_node.shape == null or shape_node.disabled:
		return false

	var posicion_local := shape_node.global_transform.affine_inverse() * posicion_global
	if shape_node.shape is RectangleShape2D:
		var rectangulo := shape_node.shape as RectangleShape2D
		var mitad := rectangulo.size * 0.5
		return absf(posicion_local.x) <= mitad.x and absf(posicion_local.y) <= mitad.y

	if shape_node.shape is CircleShape2D:
		var circulo := shape_node.shape as CircleShape2D
		return posicion_local.length() <= circulo.radius

	return false


func _parsear_vector2(valor: Variant, fallback: Vector2) -> Vector2:
	if valor is Vector2:
		return valor
	if valor is Array and valor.size() >= 2:
		return Vector2(float(valor[0]), float(valor[1]))
	return fallback


func _exit_tree() -> void:
	_guardar_progreso()
	_restaurar_tiempo_normal()
