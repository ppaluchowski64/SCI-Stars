extends Node2D

var Player = preload("res://scenes/player.tscn")

@onready var ui = $UserInterface
@onready var players = $Players
@onready var camera = $Camera2D
@onready var end_screen = $EndScreen
@onready var end_screen_animation = $EndScreen/AnimationPlayer

var next_free_player_id = 0

func block_player_controls(value: bool):
	for player in players.get_children():
		player.block_controls = value

func spawn_player(x: float, y: float, character_id: Characters.ID, player_id: int = get_exclusive_player_id()) -> Node:
	print("Spawning a player...")
	
	var player = Characters.custom_character(character_id)
	
	player.global_position = Vector2(x, y)
	player.id = player_id
	
	player.update_player_count.connect(_update_player_count)
	
	players.add_child(player)
	
	print("Spawned player with id: %s" % player.id)
	
	return player

func _update_player_count() -> void:
	ui.update_player_count()
	
	if players.get_child_count() <= 2:
		end_game()
	
func get_exclusive_player_id() -> int:
	next_free_player_id += 1
	return next_free_player_id - 1

func start_game() -> void:
	var player_spawn_pos = [
		Vector2(0, -840), Vector2(840, 0), Vector2(0, 840), Vector2(-840, 0),
		Vector2(680, -680), Vector2(680, 680), Vector2(-680, 680), Vector2(-680, -680)
	]
	
	var main_player: Node
	var main_player_id: int = randi_range(0, 7)
	var i: int = 0
	
	for pos in player_spawn_pos:
		if i == main_player_id:
			main_player = spawn_player(pos.x, pos.y, PlayerData.selected_character, i)
		else:
			spawn_player(pos.x, pos.y, Characters.ID.values().pick_random(), i)
		
		i += 1
	
	# If you are reading this Pablo, use this if you can't get main_player anyhow else
	# camera.setup_target()
	
	main_player.is_main_player = true
	camera.target = main_player
	ui.main_player = main_player

func end_game() -> void:
	for player in players.get_children():
		player.block_controls = true
		
	end_screen.visible = true
	end_screen_animation.play("enter")

func _ready() -> void:
	call_deferred("start_game")

func _on_button_proceed_button_down() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/lobby.tscn")
