extends CanvasLayer


@onready var bus_index = AudioServer.get_bus_index("Master")
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Comentarios para entendernos
# hide () oculta el menu
# show () hace lo contrario

func _ready():
	hide() 
	
	%HSlider.value = AudioServer.get_bus_volume_db(bus_index)
	
 

func aparecer():
	show()
	


func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index, value)
	
	# Si el volumen es muy bajo, lo silenciamos del todo
	if value <= -29:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)

func _on_boton_cerrar_pressed():
	hide()
	
	


func _on_button_pressed() -> void:
	audio.play()
	



func _on_button_cerrar_pressed() -> void:
	hide()
	
