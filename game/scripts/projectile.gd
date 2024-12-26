extends CharacterBody2D

# Stats
var speed: float = 50.0
var distance: float = 7000.0
var damage: float = 750.0

# Properties
var travelled: float = 0
var player_id: int

func _process(delta: float) -> void:
	velocity = Vector2(1, 0).rotated(rotation) * speed * delta * 1000
	
	if travelled >= distance:
		queue_free()
	
	travelled += speed
	
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.id != player_id:
			body.take_damage(damage)
			queue_free()
			
	elif body.is_in_group("obstacle"):
		queue_free()
