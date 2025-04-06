extends Node

var money: float = 2000.0

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
	[Stat.new(200.0, 750.0, 150.0), Stat.new(200.0, 2600.0, 300.0), Stat.new(200.0, 2600.0, 300.0)]
]

var selected_character = Characters.ID.PABLO
