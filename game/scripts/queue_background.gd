extends Node2D

var animation: float = 0

func _process(delta: float) -> void:
	animation += delta * 50
	queue_redraw()

func _draw():
	var rng = RandomNumberGenerator.new()
	
	var rx: float = get_viewport_rect().size.x / 20
	var ry: float = get_viewport_rect().size.x / 200
	
	for oy in range(0, ry):
		for i in range(-rx, rx):
			rng.set_seed(i * (oy + 1))
			
			var ox: int = sin(i + animation * 0.2) * 10
			var osx: int = rng.randi_range(5, 10)
			
			var c: Color = Color.html("032f03")
			c.a = rng.randf_range(0.5, 1)
			
			if oy % 2:
				draw_rect(Rect2(Vector2(i * 30 + fmod(animation, rx * 50) - osx, -ox + oy * 200), Vector2(osx * 2, 50 + ox * 2)), c)
			else:
				draw_rect(Rect2(Vector2(i * 30 - fmod(animation, rx * 50) - osx + get_viewport_rect().size.x, -ox + oy * 200), Vector2(osx * 2, 50 + ox * 2)), c)
