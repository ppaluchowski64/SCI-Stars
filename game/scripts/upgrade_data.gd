extends Node
class_name UpgradeData

static var names: Array = ["DAMAGE", "HEALTH", "SPECIAL"]
static var desc: Array = ["increase damage per projectile", "increase max health", "increase amount of godots", "decrease swinging time"]
static var textures: Array = [preload("res://graphics/UI/icons/damage.png"), preload("res://graphics/UI/icons/heart.png")]

# We don't talk about this
static var upgrade_data: Array = [
	[[names[0], desc[0], textures[0]], [names[1], desc[1], textures[1]]],
	[[names[0], desc[0], textures[0]], [names[1], desc[1], textures[1]], [names[2], desc[2], textures[0]]],
	[[names[0], desc[0], textures[0]], [names[1], desc[1], textures[1]], [names[2], desc[3], textures[0]]]
]
