extends Node
class_name Characters

static var Player = preload("res://scenes/player.tscn")

static var character_names: Array = ["pablomajster", "jackflower"]
static var display_names: Array = ["Pablo Majster", "Jack Flower"]
static var spritesheets: Array
static var textures: Array

enum ID {PABLO, JACK}

static func setup() -> void:
	for n in character_names:
		spritesheets.append(load("res://data/%s.tres" % n))
		textures.append(load("res://graphics/characters/%s/player.png" % n))

static func custom_character(id: ID) -> Node:
	var p = Player.instantiate()
	
	p.max_health = PlayerData.character_stats[id][1].value
	p.get_node("AnimatedSprite2D").frames = spritesheets[id]
	
	return p
