extends CanvasLayer

@onready var player_count = $PlayerCount
@export var players: Node2D

func update_player_count() -> void:
	player_count.text = "Players left: %s" % (players.get_child_count() - 1)
