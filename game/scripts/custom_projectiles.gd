extends Node
class_name Projectiles

# You know what this is not that bad even

static var Projectile = preload("res://scenes/projectile.tscn")

enum ID {DEFAULT, BIG_PROJECTILE}

static func explosion_death(parent: Node):
	for i in range(4):
		var projectile = Projectiles.custom_projectile(ID.DEFAULT)
		
		projectile.player_id = parent.player_id
		projectile.global_position = parent.global_position
		projectile.global_rotation = parent.global_rotation + i * TAU / 4 + TAU / 8
		projectile.parent = parent.parent
		
		Engine.get_main_loop().root.call_deferred("add_child", projectile)

static func custom_projectile(id: ID) -> Node:
	var p = Projectile.instantiate()
	
	match id:
		ID.BIG_PROJECTILE:
			p.scale = Vector2(6, 6)
			p.on_death = explosion_death
			
			return p
	
	return p
