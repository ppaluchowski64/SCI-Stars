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
		global_position = lerp(global_position, target.global_position, 0.05)
