extends Node2D

@onready var lobby_viewport_container: SubViewportContainer = $SubViewportContainer
@onready var lobby_viewport: SubViewport = $SubViewportContainer/LobbyViewport

func _ready() -> void:
	SignalBus.update_resolution.connect(update_resolution)

func update_resolution(resolution: Dictionary) -> void:
	if not resolution:
		return
	
	lobby_viewport.size = resolution.size
	lobby_viewport_container.position = resolution.offset
