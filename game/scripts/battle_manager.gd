extends Node2D

var Player = preload("res://scenes/player.tscn")

@onready var ui = $UserInterface
@onready var players = $Players
@onready var camera = $Camera2D

@onready var end_screen = $EndScreen
@onready var end_screen_animation = $EndScreen/AnimationPlayer

@onready var end_screen_rank_label = $EndScreen/ColorRect/Rank/Label
@onready var end_screen_kills_label = $EndScreen/ColorRect/Kills/Label
@onready var end_screen_bonus_label = $EndScreen/ColorRect/Bonus/Label
@onready var end_screen_tokens_label = $EndScreen/ColorRect/Tokens/Label

@onready var audio_listener: AudioListener2D = $Camera2D/AudioListener2D

var main_player: Node
var player_count: int = 8
var next_free_player_id = 0
var game_ended: bool = false

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
	player_count -= 1
	
	ui.update_player_count(player_count)
	
	if not game_ended:
		if player_count <= 1 or main_player.is_dead:
			game_ended = true
			end_game()
	
func get_exclusive_player_id() -> int:
	next_free_player_id += 1
	return next_free_player_id - 1

func start_game() -> void:
	if PlayerData.is_multiplayer_enabled:
		Engine.max_fps = 60
	else:
		Engine.max_fps = 0
	
	AStarAI.setup()
	
	var player_spawn_pos = [
		Vector2(0, -840), Vector2(840, 0), Vector2(0, 840), Vector2(-840, 0),
		Vector2(680, -680), Vector2(680, 680), Vector2(-680, 680), Vector2(-680, -680)
	]
	
	var main_player_id: int = PlayerData.player_id
	var i: int = 0
	
	for pos in player_spawn_pos:
		var p: CharacterBody2D
		
		if i == main_player_id:
			p = spawn_player(pos.x, pos.y, PlayerData.selected_character, i)
			main_player = p
			main_player.is_main_player = true
		else:
			if PlayerData.is_multiplayer_enabled:
				p = spawn_player(pos.x, pos.y, PlayerData.online_player_stats[str(i)]["character"], i)
				
				print(PlayerData.online_player_stats[str(i)]["nickname"])
				p.nickname_label.text = PlayerData.online_player_stats[str(i)]["nickname"]
			else:
				p = spawn_player(pos.x, pos.y, Characters.ID.values().pick_random(), i)
			
			p.ammobar.visible = false
			p.nickname_label.visible = true
	
		if PlayerData.is_multiplayer_enabled:
			var upgrade_dicts: Array = PlayerData.online_player_stats[str(i)]["upgrades"]
			var stats: Array = []

			for stat_dict in upgrade_dicts:
				if stat_dict is Dictionary:
					stats.append(PlayerData.Stat.from_dict(stat_dict))
				else:
					push_error("Received invalid stat dictionary")
			
			p.stats = stats.duplicate(true)
		else:
			p.setup_ai()
		
		p.setup_stats()
		
		i += 1
	
	# If you are reading this Pablo, use this if you can't get main_player anyhow else
	# camera.setup_target()
	
	camera.target = main_player
	ui.main_player = main_player
	
	if PlayerData.is_multiplayer_enabled:
		RemoteInputHandler.main_player = main_player
		RemoteInputHandler.start_connection()

func end_game() -> void:
	main_player.block_controls = true
	
	ui.move_joystick.set_process_input(false)
	ui.attack_joystick.set_process_input(false)
	
	var rank = player_count + 1 if main_player.is_dead else 1
	var kills = main_player.kills
	var bonus = 1.2 if rank <= 3 else 1.0
	
	var tokens = floori(((9 - rank) * 4 + kills * 8) * bonus)
	
	PlayerData.tokens += tokens
	
	end_screen_rank_label.text = "Rank: " + str(rank)
	end_screen_kills_label.text = "Kills: " + str(kills)
	end_screen_bonus_label.text = "Top placement\nbonus: " + str(roundi((bonus - 1) * 100)) + "%"
	end_screen_tokens_label.text = "Total plugs:\n" + str(tokens)
	
	end_screen.visible = true
	end_screen_animation.play("enter")

func _ready() -> void:
	SoundManager.load_buttons()
	call_deferred("start_game")

func _on_button_proceed_button_down() -> void:
	PlayerJoin.tcp.disconnect_from_host()
	RemoteInputHandler.connected = false
	get_tree().call_deferred("change_scene_to_file", "res://scenes/lobby.tscn")
