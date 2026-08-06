extends Node
class_name DisplayManager

# DisplayManager:
# every root scene should contain this node,
# exists to handle the discrepancy between regular scenes and those with
# an extended viewport (the ones that are made to draw on the black bars),
# as the time of writing, it's just LobbyWrapper

@export var extended_viewport: bool

static func get_actual_display_size() -> Vector2:
	var viewport: Viewport = Engine.get_main_loop().root.get_viewport()
	
	return (
		Vector2(PlayerData.window_resolution.size)
		if PlayerData.window_is_fullscreen
		else viewport.get_visible_rect().size
	)

func _ready() -> void:
	if not PlayerData.window_is_fullscreen:
		return
	
	if extended_viewport:
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
		SignalBus.call_deferred("emit_signal", "update_resolution", PlayerData.window_resolution)
	else:
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		get_window().content_scale_size = PlayerData.window_resolution.size
