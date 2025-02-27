extends Camera2D

@export var players: Node2D

var target: Node2D

func setup_target(id: int = 0) -> void:
	for player in players.get_children():
		if player.id == id:
			target = player
			return
			
	print("No player with id: %s" % id)

func _process(_delta: float) -> void:
	if target:
		var target_pos: Vector2 = target.global_position
		var w = get_viewport_rect().size.x / 2
		var h = get_viewport_rect().size.y / 2
		
		target_pos.x = clamp(target_pos.x, w - 1024, 1024 - w)
		target_pos.y = clamp(target_pos.y, h - 1024, 1024 - h)
		
		global_position = lerp(global_position, target_pos, 0.05)
