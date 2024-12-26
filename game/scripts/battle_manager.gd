extends Node2D

var Player = preload("res://scenes/player.tscn")

@onready var ui = $UserInterface
@onready var players = $Players
@onready var camera = $Camera2D

var next_free_player_id = 0

func spawn_player(x: float, y: float) -> void:
	print("Spawning a player...")
	
	var player = Player.instantiate()
	
	player.global_position = Vector2(x, y)
	player.id = get_exclusive_player_id()
	
	player.update_player_count.connect(_update_player_count)
	
	players.add_child(player)
	
	print("Spawned player with id: %s" % player.id)

func _update_player_count() -> void:
	ui.update_player_count()
	
func get_exclusive_player_id() -> int:
	next_free_player_id += 1
	return next_free_player_id - 1

func start_game() -> void:
	spawn_player(252, 332)
	spawn_player(630, 520)
	spawn_player(867, 332)
	
	camera.setup_target()

func _ready() -> void:
	call_deferred("start_game")
