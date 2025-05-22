extends Node2D

@export var player: Node2D
@onready var move_timer: Timer = $MoveTimer
@onready var shoot_timer: Timer = $ShootTimer

var astar: AStarGrid2D
var current_path: PackedVector2Array
var path_index: int = 0

var moving: bool = false
var ignore_enemy_frames: float = 600

var font = SystemFont.new()

func update(delta: float) -> void:
	global_position = Vector2.ZERO
	
	var closest_enemy_dist: float = INF
	var closest_enemy: Node2D
	
	for enemy in get_tree().get_nodes_in_group("player"):
		if enemy.id != player.id:
			var dist: float = player.global_position.distance_to(enemy.global_position)
			
			if dist < closest_enemy_dist:
				closest_enemy_dist = dist
				closest_enemy = enemy
	
	if closest_enemy_dist <= 300:
		if ignore_enemy_frames <= 0:
			var angle: float = player.get_angle_to(closest_enemy.global_position)
			var dir: Array = player.rad_to_double_dir(angle)
			
			player.sprite.play(str(player.double_to_single_dir(dir[0], dir[1])))
			
			if player.shoot_animation.time_left == 0:
				player.dir_x = 0
				player.deir_y = 0
			
			if shoot_timer.is_stopped():
				player.projectile_func.call(angle)
				player.shoot_animation.start()
				
				player.dir_x = dir[0]
				player.dir_y = dir[1]
				
				shoot_timer.start(randf_range(1.2, 1.5) * 0.75 / player.reload_speed)
			
			return
		else:
			ignore_enemy_frames -= delta * 1000
	else:
		ignore_enemy_frames = 600
	
	if not moving or path_index >= current_path.size():
		player.dir_x = 0
		player.dir_y = 0
		
		if move_timer.is_stopped():
			# funi formula
			move_timer.start((randf_range(0, 1) ** 2) * 2 + 1)
		
		return
	
	var target_pos = current_path[path_index]
	var dir = (target_pos - player.global_position).normalized()
	
	player.dir_x = sign(dir[0])
	player.dir_y = sign(dir[1])
	
	var dist = player.speed
	
	player.velocity = dir * dist
	player.move_and_slide()
	
	if player.global_position.distance_to(target_pos) <= dist * delta:
		player.global_position = target_pos
		path_index += 1
		
		if path_index >= current_path.size():
			moving = false

func set_target(target: Vector2i) -> void:
	var start = (player.global_position / AStarAI.cell_size).floor()
	var start_astar = Vector2i(start)
	
	current_path = astar.get_point_path(start_astar, target)
	
	path_index = 0
	moving = current_path.size() > 1

func _ready() -> void:
	global_position = Vector2.ZERO
	astar = AStarAI.astar

"""func _draw() -> void:
	if AStarAI.debug_draw:
		if player.id == 0:
			for x in range(astar.region.position.x, astar.region.end.x):
				for y in range(astar.region.position.y, astar.region.end.y):
					var cell_pos = Vector2(x, y)
					var world_pos = cell_pos * AStarAI.cell_size
					var rect = Rect2(world_pos, AStarAI.cell_size)
					var is_solid = astar.is_point_solid(cell_pos)
					
					if is_solid:
						draw_rect(rect, Color.RED, false)
						draw_string(font, world_pos, str(cell_pos.x), 0, -1, 8)
						draw_string(font, world_pos + Vector2(0, 10), str(cell_pos.y), 0, -1, 8)
					else:
						draw_rect(rect, Color.YELLOW, false)
	
		for point in current_path:
			draw_circle(point, 3, Color.GREEN)"""

func _on_move_timer_timeout() -> void:
	var target: Vector2i
	
	while not target or AStarAI.astar.is_point_solid(target):
		target = Vector2i(randi_range(-40, 39), randi_range(-40, 39))
	
	set_target(target)
	#queue_redraw()
