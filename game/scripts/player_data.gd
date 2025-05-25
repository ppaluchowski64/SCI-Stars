extends Node

var money: float = 500.0
var tokens: float = 100.0

var is_joystick_enabled: bool = false

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

var character_stats: Array = [
	[Stat.new(200.0, 750.0, 150.0), Stat.new(200.0, 3000.0, 300.0)],
	[Stat.new(200.0, 250.0, 30.0), Stat.new(200.0, 3600.0, 300.0), Stat.new(500.0, 2, 1)],
	[Stat.new(200.0, 1200.0, 240.0), Stat.new(200.0, 4200.0, 300.0), Stat.new(500.0, 0.4, -0.01)]
]

var selected_character = Characters.ID.PABLO
