extends Node

@onready var obstacles: TileMapLayer

var cell_size = Vector2(24, 24)
var grid_size: int = 40

var astar: AStarGrid2D = AStarGrid2D.new()

#var debug_draw: bool = true

func generate_astar(new_astar: AStarGrid2D, tilemap: TileMapLayer) -> void:
	for x in range(-grid_size / 2, grid_size / 2):
		for y in range(-grid_size / 2, grid_size / 2):
			if tilemap.get_cell_source_id(Vector2i(x, y)) == 0:
				for ox in range(-2, 4):
					for oy in range(-2, 4):
						if not ox in [-2, 3] or not oy in [-2, 3]:
							new_astar.set_point_solid(Vector2i(x * 2 + ox, y * 2 + oy))
	
	for pos in Const.DISABLED_TILES:
		new_astar.set_point_solid(Vector2i(pos[0], pos[1]))

func setup() -> void:
	obstacles = get_tree().get_first_node_in_group("obstacle")
	
	astar.region = Rect2i(-grid_size, -grid_size, grid_size * 2, grid_size * 2)
	astar.cell_size = cell_size
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	
	astar.update()
	
	generate_astar(astar, obstacles)
