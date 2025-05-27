extends Node

var money: float = 500.0
var tokens: float = 100.0

var nickname: String = "Player"

var window_is_fullscreen: bool = false
var window_ratio_mode: int = 0
var window_scale: float = 1.5

var is_multiplayer_enabled: bool = false
var is_joystick_enabled: bool = false

var instance_id: int = 0
var player_id: int = 0

var online_player_stats: Dictionary

class Stat:
	var base_cost: float
	var delta_value: float
	var value: float
	var level: int
	
	@warning_ignore("shadowed_variable")
	func _init(base_cost, value, delta_value) -> void:
		self.base_cost = base_cost
		self.value = value
		self.delta_value = delta_value
		self.level = 1
	
	func to_dict() -> Dictionary:
		return {
			"base_cost": base_cost,
			"value": value,
			"delta_value": delta_value,
			"level": level
		}

	static func from_dict(d: Dictionary) -> Stat:
		var stat = Stat.new(d.get("base_cost", 0), d.get("value", 0), d.get("delta_value", 0))
		stat.level = d.get("level", 1)
		return stat

var character_stats: Array = [
	[Stat.new(200.0, 750.0, 150.0), Stat.new(200.0, 3000.0, 300.0)],
	[Stat.new(200.0, 250.0, 30.0), Stat.new(200.0, 3600.0, 300.0), Stat.new(500.0, 2, 1)],
	[Stat.new(200.0, 1200.0, 240.0), Stat.new(200.0, 4200.0, 300.0), Stat.new(500.0, 0.4, -0.01)]
]

var bot_stats: Array = character_stats.duplicate(true)

var selected_character = Characters.ID.PABLO
