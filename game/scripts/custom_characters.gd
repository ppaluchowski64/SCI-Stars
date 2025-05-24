extends Node
class_name Characters

static var Player = preload("res://scenes/player.tscn")

static var character_names: Array = ["pablomajster", "jackflower", "kate"]
static var display_names: Array = ["Pablo Majster", "Jack Flower", "Kate"]
static var character_descriptions: Array = [
	"Student of SCI, a tech geek who knows everything about networking and Linux. He fires a small data bolt straight ahead. His super is a fork bomb that splits into 4 smaller packets.",
	"Principal of SCI, he prefers old tools and uses Godot like it’s still the 90s. He shoots five floppy disks in a wide spread. His super summons orbiting godot icons that deal damage and protect a little.",
	"Teacher of SCI, a strict Polish educator with a heavy hammer. Hits hard with a close-range swing. Her super summons a magic book which creates a damage field around it."
]

static var spritesheets: Array
static var textures: Array

enum ID {PABLO, JACK, KATE}

const CHARACTER_COUNT = 3

static func setup() -> void:
	for n in character_names:
		spritesheets.append(load("res://data/%s.tres" % n))
		textures.append(load("res://graphics/characters/%s/player.png" % n))

static func custom_character(id: ID) -> Node:
	var p = Player.instantiate()
	
	p.max_health = PlayerData.character_stats[id][1].value
	p.get_node("AnimatedSprite2D").frames = spritesheets[id]
	
	p.character_id = id
	
	if id == ID.JACK:
		p.projectile_id = Projectiles.ID.FLOPPY
		p.projectile_super_id = Projectiles.ID.GODOT
		p.projectile_func = p.spawn_projectile_spreadshot_await
		p.reload_speed = 0.58
		
		p.get_node("ShootCooldown").wait_time = 0.65
		
		p.speed = 165.0
	
	elif id == ID.KATE:
		p.projectile_id = Projectiles.ID.HAMMER
		p.projectile_super_id = Projectiles.ID.BOOK_THROW
		p.reload_speed = 1.0
		
		p.speed = 195.0
		
		p.ai_type = p.MELEE
	
	return p
