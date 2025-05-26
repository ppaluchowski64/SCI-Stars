extends Node
class_name Projectiles

# You know what this is not that bad even

static var Projectile = preload("res://scenes/projectile.tscn")

enum ID {DEFAULT, BIG_PROJECTILE, FLOPPY, HAMMER, BOOK_THROW, BOOK_FIELD, GODOT}

static func book_death(parent: Node):
	var book = parent.parent.spawn_projectile(parent.global_rotation, ID.BOOK_FIELD)
	
	book.global_position = parent.global_position

static func explosion_death(parent: Node):
	for i in range(4):
		var projectile = Projectiles.custom_projectile(ID.DEFAULT)
		
		projectile.player_id = parent.player_id
		projectile.global_position = parent.global_position
		projectile.global_rotation = parent.global_rotation + i * TAU / 4 + TAU / 8
		
		projectile.super_charge *= 0.8
		
		if parent.parent:
			projectile.parent = parent.parent
			
		projectile.spawn_immunity = 7.5
		
		Engine.get_main_loop().root.call_deferred("add_child", projectile)

static func custom_projectile(id: ID) -> Node:
	var p = Projectile.instantiate()
	
	match id:
		ID.BIG_PROJECTILE:
			p.scale = Vector2(6, 6)
			p.on_death = explosion_death
			
			return p
		
		ID.FLOPPY:
			# pixel inconsistency goes crazy
			p.scale = Vector2(3, 3)
			p.speed = 250.0
			p.super_charge = 0.06
			p.sprite_rot = deg_to_rad(5.0)
			
			p.get_node("Sprite2D").region_rect = Rect2i(9, 1, 5, 6)
			
			return p
		
		ID.HAMMER:
			p.ai = p.melee_ai
			p.scale = Vector2(6, 6)
			p.destroy_on_obstacles = false
			p.destroy_on_hit = false
			
			p.get_node("Sprite2D").region_rect = Rect2i(15, 1, 14, 9)
			p.get_node("Hitbox/CollisionShape2D").shape = preload("res://data/kate_attack_shape.tres")
			
			p.sfx = 1
			
			return p
		
		ID.BOOK_THROW:
			p.damage = 0.0
			p.speed = 400.0
			p.on_death = book_death
			
			p.get_node("Sprite2D").region_rect = Rect2i(30, 1, 9, 8)
			p.get_node("Hitbox/CollisionShape2D").shape.radius = 7.0
			
			p.sfx = 4
			
			return p
		
		ID.BOOK_FIELD:
			p.damage = 500.0
			p.super_charge = 0.08
			p.ai = p.field_ai
			
			p.get_node("Sprite2D").region_rect = Rect2i(40, 1, 10, 13)
			p.get_node("Hitbox/CollisionShape2D").shape.radius = 31.0
			
			p.sfx = 3
			
			return p
		
		ID.GODOT:
			p.damage = 620.0
			p.super_charge = 0.07
			p.ai = p.melee_ai
			
			p.spin_start = deg_to_rad(0)
			p.spin_end = deg_to_rad(720)
			p.spin_time = 4.0
			p.spin_ease = false
			
			p.destroy_on_obstacles = false
			p.destroy_on_hit = false
			p.register_hits = false
			
			p.get_node("Sprite2D").region_rect = Rect2i(51, 1, 10, 11)
			p.get_node("Hitbox/CollisionShape2D").shape.radius = 7.3
			
			p.sfx = 2
			
			return p
	
	return p
