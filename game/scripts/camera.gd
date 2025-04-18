extends Camera2D

@export var players: Node2D
@export var is_following: bool

var target: Node2D

func start_animation() -> void:
	var tween: Tween = create_tween()
	
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "global_position", target.global_position, 5.0)

func setup_target(id: int = 0) -> void:
	for player in players.get_children():
		if player.id == id:
			target = player
			return
			
	print("No player with id: %s" % id)

func _process(_delta: float) -> void:
	if target and is_following:
		var target_pos: Vector2 = target.global_position
		var w = get_viewport_rect().size.x / 2
		var h = get_viewport_rect().size.y / 2
		
		target_pos.x = clamp(target_pos.x, w - 1024 - Const.CAMERA_BORDER_MARGIN, 1024 - w + Const.CAMERA_BORDER_MARGIN)
		target_pos.y = clamp(target_pos.y, h - 1024 - Const.CAMERA_BORDER_MARGIN, 1024 - h + Const.CAMERA_BORDER_MARGIN)
		
		global_position = lerp(global_position, target_pos, 0.05)
	
	#global_position = Vector2.ZERO
	#zoom = Vector2(0.5, 0.5)
