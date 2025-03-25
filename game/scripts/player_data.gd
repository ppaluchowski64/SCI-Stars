extends Node

var money: float = 2000.0

class Stat:
	var base_cost: float
	var level: int
	
	func _init(base_cost) -> void:
		self.base_cost = base_cost
		self.level = 1

var character_stats: Array = [[Stat.new(200.0)]]
