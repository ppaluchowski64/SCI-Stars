extends Control

@onready var music_slider = $MusicSlider/VolumeSliderM
@onready var music_label = $MusicValue/VolumeValue

@onready var sfx_slider = $SFXSlider/VolumeSliderS
@onready var sfx_label = $SFXValue/VolumeValue

var music_bus = AudioServer.get_bus_index("Music")
var sfx_bus = AudioServer.get_bus_index("SFX")

func _ready() -> void:
	music_slider.value = 100
	sfx_slider.value = 100

func _on_volume_slider_m_value_changed(value: float) -> void:
	var clamped = clamp(value / 100.0, 0, 1)
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(clamped))
	
	music_label.text = "%d%%" % round(clamped * 100)

func _on_volume_slider_s_value_changed(value: float) -> void:
	var clamped = clamp(value / 100.0, 0, 1)
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(clamped))
	
	sfx_label.text = "%d%%" % round(clamped * 100)
