extends Area2D
class_name CheckpointActivador

signal checkpoint_alcanzado(posicion: Vector2, mensaje: String)

@export var mensaje_activacion: String = "Checkpoint activado."
@export var activar_una_sola_vez: bool = true
@export var ruta_textura_cartel: String = "res://Imagenes/Objetos/checkpoint_cartel_cc0.png"
@export var color_inactivo: Color = Color(0.88, 0.92, 0.96, 0.95)
@export var color_activo: Color = Color(1.0, 0.97, 0.9, 1.0)
@export var color_aura_inactiva: Color = Color(0.62, 0.84, 1.0, 0.08)
@export var color_aura_activa: Color = Color(1.0, 0.93, 0.66, 0.24)
@export var amplitud_balanceo_grados: float = 1.1
@export var velocidad_balanceo: float = 1.25

var _activado: bool = false
var _fase_animacion: float = 0.0
var _posicion_base_visual: Vector2 = Vector2.ZERO
var _escala_base_visual: Vector2 = Vector2.ONE
var _escala_base_aura: Vector2 = Vector2.ONE
static var _textura_aura_cache: Texture2D
static var _textura_cartel_cache: Texture2D
static var _stream_checkpoint_cache: AudioStreamWAV

@onready var punto_visible: Node2D = $"../PuntoVisible"
@onready var aura_checkpoint: Sprite2D = get_node_or_null("../AuraCheckpoint") as Sprite2D
@onready var audio_checkpoint: AudioStreamPlayer = get_node_or_null("../AudioCheckpoint") as AudioStreamPlayer


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_fase_animacion = rng.randf_range(0.0, TAU)
	if punto_visible != null:
		if punto_visible is Sprite2D and (punto_visible as Sprite2D).texture == null:
			(punto_visible as Sprite2D).texture = _obtener_textura_cartel()
		_posicion_base_visual = punto_visible.position
		_escala_base_visual = punto_visible.scale
	if aura_checkpoint != null:
		aura_checkpoint.texture = _obtener_textura_aura()
		_escala_base_aura = aura_checkpoint.scale
	if audio_checkpoint == null:
		audio_checkpoint = AudioStreamPlayer.new()
		audio_checkpoint.name = "AudioCheckpoint"
		get_parent().call_deferred("add_child", audio_checkpoint)
		await get_tree().process_frame
	if audio_checkpoint != null:
		audio_checkpoint.bus = &"Master"
		audio_checkpoint.volume_db = -8.0
		audio_checkpoint.stream = _obtener_stream_checkpoint()
	body_entered.connect(_on_body_entered)
	set_process(true)
	_actualizar_visual()


func esta_activado() -> bool:
	return _activado


func _process(_delta: float) -> void:
	var tiempo := Time.get_ticks_msec() * 0.001
	var onda := sin((tiempo * velocidad_balanceo) + _fase_animacion)
	var pulso := 1.0 + (sin((tiempo * 1.8) + (_fase_animacion * 0.65)) * 0.04)

	if punto_visible != null:
		punto_visible.rotation_degrees = onda * amplitud_balanceo_grados
		punto_visible.position = _posicion_base_visual + Vector2(0.0, onda * 0.75)
		punto_visible.scale = _escala_base_visual * (1.0 if _activado else pulso)

	if aura_checkpoint != null:
		var escala_aura := 1.0 + ((pulso - 1.0) * 0.6)
		aura_checkpoint.scale = _escala_base_aura * (1.08 if _activado else escala_aura)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("jugador"):
		return

	if _activado and activar_una_sola_vez:
		return

	_activado = true
	_actualizar_visual()
	_animar_activacion()
	_reproducir_sonido_activacion()
	emit_signal("checkpoint_alcanzado", get_parent().global_position, mensaje_activacion)


func _actualizar_visual() -> void:
	if punto_visible == null:
		return

	if punto_visible is CanvasItem:
		(punto_visible as CanvasItem).modulate = color_activo if _activado else color_inactivo

	if aura_checkpoint != null:
		aura_checkpoint.modulate = color_aura_activa if _activado else color_aura_inactiva


func _animar_activacion() -> void:
	if punto_visible == null:
		return

	var tween := create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(punto_visible, "scale", _escala_base_visual * 1.2, 0.14)
	tween.tween_property(punto_visible, "scale", _escala_base_visual, 0.2)

	if aura_checkpoint != null:
		var tween_aura := create_tween()
		tween_aura.set_ignore_time_scale(true)
		tween_aura.set_trans(Tween.TRANS_SINE)
		tween_aura.set_ease(Tween.EASE_OUT)
		tween_aura.tween_property(aura_checkpoint, "scale", _escala_base_aura * 1.45, 0.16)
		tween_aura.tween_property(aura_checkpoint, "scale", _escala_base_aura * 1.08, 0.22)


func _obtener_textura_aura() -> Texture2D:
	if _textura_aura_cache != null:
		return _textura_aura_cache

	_textura_aura_cache = _crear_textura_radial(72)
	return _textura_aura_cache


func _obtener_textura_cartel() -> Texture2D:
	if _textura_cartel_cache != null:
		return _textura_cartel_cache

	var textura_importada := load(ruta_textura_cartel) as Texture2D
	if textura_importada != null:
		_textura_cartel_cache = textura_importada
		return _textura_cartel_cache

	var imagen := Image.load_from_file(ProjectSettings.globalize_path(ruta_textura_cartel))
	if imagen == null or imagen.is_empty():
		return null

	_textura_cartel_cache = ImageTexture.create_from_image(imagen)
	return _textura_cartel_cache


func _reproducir_sonido_activacion() -> void:
	if audio_checkpoint == null or not audio_checkpoint.is_inside_tree():
		return

	audio_checkpoint.stop()
	audio_checkpoint.play()


func _obtener_stream_checkpoint() -> AudioStreamWAV:
	if _stream_checkpoint_cache != null:
		return _stream_checkpoint_cache

	var sample_rate := 22050
	var duracion := 0.42
	var total_samples := int(sample_rate * duracion)
	var data := PackedByteArray()
	data.resize(total_samples * 2)
	for i in range(total_samples):
		var t := float(i) / float(sample_rate)
		var envelope := exp(-5.8 * t)
		var nota_a := sin(TAU * 740.0 * t)
		var nota_b := sin(TAU * 1110.0 * t)
		var brillo := sin(TAU * 1480.0 * t) * 0.18
		var muestra := (nota_a * 0.68 + nota_b * 0.26 + brillo) * envelope * 0.72
		var valor := int(clampf(muestra, -1.0, 1.0) * 32767.0)
		data[i * 2] = valor & 0xFF
		data[(i * 2) + 1] = (valor >> 8) & 0xFF

	_stream_checkpoint_cache = AudioStreamWAV.new()
	_stream_checkpoint_cache.format = AudioStreamWAV.FORMAT_16_BITS
	_stream_checkpoint_cache.mix_rate = sample_rate
	_stream_checkpoint_cache.stereo = false
	_stream_checkpoint_cache.loop_mode = AudioStreamWAV.LOOP_DISABLED
	_stream_checkpoint_cache.data = data
	return _stream_checkpoint_cache


func _crear_textura_radial(size: int) -> Texture2D:
	var imagen := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var centro := Vector2(size * 0.5, size * 0.5)
	var radio := size * 0.5

	for y in range(size):
		for x in range(size):
			var distancia := Vector2(x, y).distance_to(centro) / radio
			var borde := clampf(1.0 - distancia, 0.0, 1.0)
			var alpha := pow(borde, 1.8)
			imagen.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))

	return ImageTexture.create_from_image(imagen)
