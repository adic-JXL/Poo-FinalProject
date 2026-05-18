extends "res://Scripts/interactivo_base.gd"
class_name PuertaTeletransporte
static var _stream_apertura_cache: AudioStreamWAV

signal teletransporte_realizado(jugador: Node2D, destino: Node2D)

@export_node_path("Area2D") var puerta_destino: NodePath
@export_file("*.tscn") var ruta_escena_destino: String = ""
@export var transporte_habilitado: bool = false
@export var teletransporta_al_tocar: bool = true
@export var permite_interaccion: bool = false
@export var duracion_animacion_entrada: float = 0.24
@export var offset_animacion_entrada: Vector2 = Vector2(0, 10)
@export var color_inactiva: Color = Color(1, 1, 1, 1)
@export var color_activa: Color = Color(1, 1, 1, 1)
@export var textura_cerrada: Texture2D
@export var textura_abierta: Texture2D
@export var duracion_animacion_apertura: float = 0.34
@export var factor_compresion_apertura: float = 0.92
@export var factor_expansion_apertura: float = 1.07

var _puerta_destino_ref: Node = null
var _escala_base_sprite: Vector2 = Vector2.ONE
var _tween_apertura: Tween = null
var _teletransporte_en_curso: bool = false

@onready var sprite: Sprite2D = $Puerta
@onready var marker_salida: Marker2D = $Marker2D
@onready var audio_apertura: AudioStreamPlayer2D = get_node_or_null("AudioApertura") as AudioStreamPlayer2D


func _ready() -> void:
	super()
	body_entered.connect(_on_body_entered_teletransporte)
	if sprite != null:
		_escala_base_sprite = sprite.scale
	_configurar_audio()
	_actualizar_visual()


func obtener_puerta_destino() -> Node:
	if _puerta_destino_ref != null and is_instance_valid(_puerta_destino_ref):
		return _puerta_destino_ref

	if puerta_destino.is_empty():
		return null

	return get_node_or_null(puerta_destino)


func configurar_destino(destino: Node) -> void:
	_puerta_destino_ref = destino
	if destino != null and is_inside_tree():
		puerta_destino = get_path_to(destino)


func obtener_punto_salida() -> Vector2:
	return marker_salida.global_position


func establecer_transporte_habilitado(activo: bool) -> void:
	transporte_habilitado = activo
	_actualizar_visual()
	if transporte_habilitado:
		call_deferred("_intentar_teletransportar_cuerpos_superpuestos")
	else:
		_teletransporte_en_curso = false


func reproducir_animacion_apertura() -> void:
	if sprite == null:
		_actualizar_visual()
		return

	if _tween_apertura != null and _tween_apertura.is_valid():
		_tween_apertura.kill()

	if textura_cerrada != null:
		sprite.texture = textura_cerrada
	sprite.modulate = Color(1, 1, 1, 1)
	sprite.scale = _escala_base_sprite
	_reproducir_sonido_apertura()
	_tween_apertura = create_tween()
	_tween_apertura.set_ignore_time_scale(true)
	_tween_apertura.set_trans(Tween.TRANS_CUBIC)
	_tween_apertura.set_ease(Tween.EASE_IN_OUT)
	_tween_apertura.tween_property(sprite, "scale", _escala_base_sprite * factor_compresion_apertura, duracion_animacion_apertura * 0.22)
	_tween_apertura.tween_callback(_aplicar_estado_abierto_visual)
	_tween_apertura.tween_property(sprite, "scale", _escala_base_sprite * factor_expansion_apertura, duracion_animacion_apertura * 0.42)
	_tween_apertura.tween_property(sprite, "scale", _escala_base_sprite, duracion_animacion_apertura * 0.36)


func _aplicar_estado_abierto_visual() -> void:
	_actualizar_visual()


func puede_interactuar() -> bool:
	return permite_interaccion and transporte_habilitado


func puede_teletransportar() -> bool:
	var destino := obtener_puerta_destino()
	var tiene_destino_local := destino != null and destino.has_method("obtener_punto_salida")
	var tiene_escena_destino := not ruta_escena_destino.is_empty()
	return transporte_habilitado and teletransporta_al_tocar and (tiene_destino_local or tiene_escena_destino)


func _on_body_entered_teletransporte(body: Node) -> void:
	if _teletransporte_en_curso:
		return

	if not body.is_in_group("jugador"):
		return

	if body.has_meta("puerta_ignorada"):
		var puerta_ignorada := int(body.get_meta("puerta_ignorada"))
		if puerta_ignorada == get_instance_id():
			body.remove_meta("puerta_ignorada")
			return

	if not puede_teletransportar():
		return

	call_deferred("_teletransportar_jugador", body)


func _teletransportar_jugador(body: Node) -> void:
	var jugador := body as Node2D
	var destino := obtener_puerta_destino()
	if jugador == null:
		_teletransporte_en_curso = false
		return

	if ruta_escena_destino.is_empty() and destino == null:
		_teletransporte_en_curso = false
		return

	if _teletransporte_en_curso:
		return

	_teletransporte_en_curso = true

	if jugador.has_method("animar_entrada_puerta"):
		await jugador.animar_entrada_puerta(global_position + offset_animacion_entrada, duracion_animacion_entrada)

	if not ruta_escena_destino.is_empty():
		emit_signal("teletransporte_realizado", jugador, null)
		get_tree().change_scene_to_file(ruta_escena_destino)
		return

	jugador.set_meta("puerta_ignorada", destino.get_instance_id())
	jugador.global_position = destino.obtener_punto_salida()
	if jugador is CharacterBody2D:
		(jugador as CharacterBody2D).velocity = Vector2.ZERO

	if jugador.has_method("finalizar_animacion_puerta"):
		jugador.finalizar_animacion_puerta()

	emit_signal("teletransporte_realizado", jugador, destino)
	call_deferred("_liberar_teletransporte")


func teletransportar_jugador(jugador: Node2D) -> void:
	if not puede_teletransportar():
		return

	_teletransportar_jugador(jugador)


func _intentar_teletransportar_cuerpos_superpuestos() -> void:
	if _teletransporte_en_curso or not puede_teletransportar() or not monitoring:
		return

	for body in get_overlapping_bodies():
		if body != null and body.is_in_group("jugador"):
			call_deferred("_teletransportar_jugador", body)
			return


func _liberar_teletransporte() -> void:
	_teletransporte_en_curso = false


func _actualizar_visual() -> void:
	if sprite == null:
		return

	if transporte_habilitado and textura_abierta != null:
		sprite.texture = textura_abierta
	elif not transporte_habilitado and textura_cerrada != null:
		sprite.texture = textura_cerrada
	elif textura_cerrada != null:
		sprite.texture = textura_cerrada

	sprite.modulate = color_activa if transporte_habilitado else color_inactiva


func _configurar_audio() -> void:
	if audio_apertura == null:
		return

	audio_apertura.bus = &"Master"
	audio_apertura.volume_db = -6.8
	audio_apertura.max_distance = 900.0
	audio_apertura.attenuation = 1.15
	audio_apertura.stream = _obtener_stream_apertura()


func _reproducir_sonido_apertura() -> void:
	if audio_apertura == null:
		return

	audio_apertura.pitch_scale = randf_range(0.97, 1.03)
	audio_apertura.stop()
	audio_apertura.play()


func _obtener_stream_apertura() -> AudioStreamWAV:
	if _stream_apertura_cache != null:
		return _stream_apertura_cache

	var sample_rate := 22050
	var duracion := 0.48
	var total_samples := int(sample_rate * duracion)
	var data := PackedByteArray()
	data.resize(total_samples * 2)
	for i in range(total_samples):
		var t := float(i) / float(sample_rate)
		var envelope := exp(-4.2 * t)
		var grave := sin(TAU * 86.0 * t) * 0.34
		var crujido := sin(TAU * 202.0 * t + sin(TAU * 13.0 * t) * 0.45) * 0.18
		var brillo := sin(TAU * 520.0 * t) * 0.06
		var muestra := (grave + crujido + brillo) * envelope * 0.88
		var valor := int(clampf(muestra, -1.0, 1.0) * 32767.0)
		data[i * 2] = valor & 0xFF
		data[(i * 2) + 1] = (valor >> 8) & 0xFF

	_stream_apertura_cache = AudioStreamWAV.new()
	_stream_apertura_cache.format = AudioStreamWAV.FORMAT_16_BITS
	_stream_apertura_cache.mix_rate = sample_rate
	_stream_apertura_cache.stereo = false
	_stream_apertura_cache.loop_mode = AudioStreamWAV.LOOP_DISABLED
	_stream_apertura_cache.data = data
	return _stream_apertura_cache
