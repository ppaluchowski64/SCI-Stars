extends CharacterBody2D

var Explosion = preload("res://scenes/explosion_fx.tscn")

# Stats
var speed: float = 300.0
var distance: float = 300.0
var damage: float = 750.0
var on_death: Callable
var spawn_immunity: float = 0.0

# Properties
var travelled: float = 0
var player_id: int
var parent: Node

func destroy() -> void:
	if on_death:
		on_death.call(self)
		
	var explosion = Explosion.instantiate()
	
	explosion.global_position = global_position
	
	get_parent().call_deferred("add_child", explosion)
	
	queue_free()

func _process(delta: float) -> void:
	velocity = Vector2(1, 0).rotated(rotation) * speed
	
	if travelled >= distance:
		destroy()
	
	travelled += speed * delta
	
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if travelled >= spawn_immunity:
		if body.is_in_group("player"):
			if body.id != player_id:
				body.take_damage(damage)
				parent.super_charge = min(parent.super_charge + 0.15, 1.0)
				destroy()
		
		elif body.is_in_group("powerpod"):
			body.take_damage(damage)
			destroy()
	
		elif body.is_in_group("obstacle"):
			destroy()
