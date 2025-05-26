extends Node2D

@onready var logo_sprite: Sprite2D = $LogoLayer/Control/Sprite2D
var logo_animation: float = 0

@onready var timer: Timer = $Timer

@onready var label_count: Label = $TextLayer/MarginContainer/LabelCount

var players: int = 1
var last_connected_players: int = 1

func _ready() -> void:
	if PlayerData.is_multiplayer_enabled:
		PlayerJoin.start_connection()
	else:
		timer.start(randf_range(0.1, 0.4))

func _process(delta: float) -> void:
	logo_animation = fmod(logo_animation + delta * 40, 100)
	logo_sprite.frame = int(logo_animation)
	
	if not last_connected_players == PlayerJoin.connected_players:
		players = PlayerJoin.connected_players
		last_connected_players = PlayerJoin.connected_players
		label_count.text = "Players found: " + str(players) + "/8"
	
	if PlayerJoin.is_instance_starting:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/battle.tscn")

func _on_timer_timeout() -> void:
	players += 1
	
	if players == 8:
		timer.start(1)
		label_count.text = "Players found: 8/8"
		return
	elif players == 9:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/battle.tscn")
	
	label_count.text = "Players found: " + str(players) + "/8"
	
	timer.start(randf_range(0.1, 0.4))
