extends Node2D

var resolution: Dictionary

func _ready() -> void:
	SignalBus.update_display_boundary.connect(update)
	SignalBus.set_display_boundary_visible.connect(func(visible_): visible = visible_)

func _draw() -> void:
	if not resolution:
		return
	
	var topleft: Vector2 = resolution.offset + Vector2(4, 4)
	draw_line(topleft, topleft + Vector2(64, 0), Color.WHITE, 8)
	draw_line(topleft, topleft + Vector2(0, 64), Color.WHITE, 8)
	
	var topright: Vector2 = Vector2(
		resolution.offset.x + resolution.size.x - 4,
		resolution.offset.y + 4
	)
	draw_line(topright, topright - Vector2(64, 0), Color.WHITE, 8)
	draw_line(topright, topright + Vector2(0, 64), Color.WHITE, 8)
	
	var bottomleft: Vector2 = Vector2(
		resolution.offset.x + 4,
		resolution.offset.y + resolution.size.y - 4
	)
	draw_line(bottomleft, bottomleft + Vector2(64, 0), Color.WHITE, 8)
	draw_line(bottomleft, bottomleft - Vector2(0, 64), Color.WHITE, 8)
	
	var bottomright: Vector2 = resolution.offset + resolution.size - Vector2(4, 4)
	draw_line(bottomright, bottomright - Vector2(64, 0), Color.WHITE, 8)
	draw_line(bottomright, bottomright - Vector2(0, 64), Color.WHITE, 8)

func update(resolution_: Dictionary) -> void:
	resolution = resolution_
	queue_redraw()
