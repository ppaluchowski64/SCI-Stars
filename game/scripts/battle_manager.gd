extends Node2D

var Player = preload("res://scenes/player.tscn")

@onready var ui = $UserInterface
@onready var players = $Players
@onready var camera = $Camera2D

var next_free_player_id = 0

func spawn_player(x: float, y: float) -> Node:
	print("Spawning a player...")
	
	var player = Player.instantiate()
	
	player.global_position = Vector2(x, y)
	player.id = get_exclusive_player_id()
	
	player.update_player_count.connect(_update_player_count)
	
	players.add_child(player)
	
	print("Spawned player with id: %s" % player.id)
	
	return player

func _update_player_count() -> void:
	ui.update_player_count()
	
	if players.get_child_count() <= 2:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/endscreen.tscn")
	
func get_exclusive_player_id() -> int:
	next_free_player_id += 1
	return next_free_player_id - 1

func start_game() -> void:
	var main_player = spawn_player(0, 0)
	
	spawn_player(630, 520)
	spawn_player(867, 332)
	
	# If you are reading this Pablo, use this if you can't get main_player anyhow else
	# camera.setup_target()
	
	camera.target = main_player
	ui.main_player = main_player

func _ready() -> void:
	call_deferred("start_game")
