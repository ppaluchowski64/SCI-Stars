extends VBoxContainer

@onready var check_box: CheckBox = $FullscreenField/CheckBox
@onready var slider: HSlider = $ScaleField/HSlider

const ratios: Array = [[16, 9], [8, 5], [4, 3], [3, 2], [5, 3]]
var ratio_x: int = ratios[0][0]
var ratio_y: int = ratios[0][1]

var window_size: Vector2i
var window_scale: float = 1.5

func _ready() -> void:
	window_size = get_window().content_scale_size

func update_resolution() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	check_box.button_pressed = true
	
	var scale_x: int = floor(DisplayServer.screen_get_size().x / ratio_x)
	var scale_y: int = floor(DisplayServer.screen_get_size().y / ratio_y)
	
	var scale_value = min(scale_x, scale_y)
	
	window_size = Vector2i(ratio_x * scale_value, ratio_y * scale_value)
	get_window().content_scale_size = window_size / window_scale

func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		update_resolution()
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		get_window().content_scale_size = Vector2i(1152, 648)

func _on_option_button_item_selected(index: int) -> void:
	ratio_x = ratios[index][0]
	ratio_y = ratios[index][1]
	
	update_resolution()

func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		window_scale = slider.value
		
		update_resolution()
