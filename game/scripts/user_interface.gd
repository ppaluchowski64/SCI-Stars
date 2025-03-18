extends CanvasLayer

@onready var player_count = $PlayerCount
@export var players: Node2D

@onready var superbar_fill = $MarginContainer/SuperBar/Mask/ColorRect

var main_player: Node

func update_player_count() -> void:
	player_count.text = "Players left: %s" % (players.get_child_count() - 1)

func _process(_delta: float) -> void:
	if main_player:
		var size = clamp(main_player.super_charge * 224.0, 0.0, 224.0)
		superbar_fill.size.x = lerp(superbar_fill.size.x, size, 0.2)
