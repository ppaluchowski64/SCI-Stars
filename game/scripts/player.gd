extends CharacterBody2D

@onready var sprite: Node = $AnimatedSprite2D

@export var speed: float = 25.0

var direction: Vector2
var animation: float

func move(delta: float) -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed * delta * 1000
	
	var h_move: String = ""
	var v_move: String = ""
	
	if direction.x > 0:
		h_move = "right"
	elif direction.x < 0:
		h_move = "left"
		
	if direction.y > 0:
		v_move = "down"
	elif direction.y < 0:
		v_move = "up"
	
	if v_move + h_move:
		sprite.play(v_move + h_move)
		animation += delta * speed * 0.2
		
		if animation > 4:
			animation -= 4
		
		sprite.frame = floor(animation)
	else:
		animation = 0
		sprite.frame = 1
	
	move_and_slide()

func _process(delta: float) -> void:
	move(delta)
