extends Control

@onready var slider = $VolumeSliderContainer/VolumeSlider
@onready var label = $VolumeValueContainer/VolumeValue

var MASTER_BUS := AudioServer.get_bus_index("Master")

func _ready() -> void:
	var linear = db_to_linear(AudioServer.get_bus_volume_db(MASTER_BUS))
	update_ui(linear)

func _on_volume_slider_value_changed(value: float) -> void:
	update_ui(value / 100.0)

func update_ui(linear_value: float) -> void:
	var clamped = clamp(linear_value, 0, 1)
	AudioServer.set_bus_volume_db(MASTER_BUS, linear_to_db(clamped))

	slider.value = clamped * 100
	label.text = "%d%%" % round(clamped * 100)
