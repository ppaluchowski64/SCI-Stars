extends CharacterBody2D

var Projectile = preload("res://scenes/projectile.tscn")

@onready var sprite: Node = $AnimatedSprite2D

@onready var regen_cooldown: Node = $RegenCooldown
@onready var shoot_cooldown: Node = $ShootCooldown
@onready var shoot_animation: Node = $ShootAnimation

@onready var healthbar_fill: Node = $Healthbar/ColorRect
@onready var healthbar_label: Node = $Healthbar/Label

@onready var ammobar_fill: Node = $Ammobar/ColorRect

@export var id: int

# Stats
var speed: float = 25.0
var max_health: float = 3000.0

# Properties
var dir_vec: Vector2
var direction: String
var animation: float
var health: float = max_health
var ammo: float = 3
var reload_speed: float = 0.005

func update_health():
	healthbar_fill.size.x = health / max_health * 56
	healthbar_label.text = str(health)

func take_damage(damage: int):
	health -= damage
	
	if health <= 0:
		queue_free()
	
	update_health()
	
	regen_cooldown.start(3)

func spawn_projectile():
	var projectile = Projectile.instantiate()
	
	projectile.player_id = id
	projectile.global_position = get_global_position()
	
	if "right" in direction:
		projectile.dir_vec.x = 1
	elif "left" in direction:
		projectile.dir_vec.x = -1
		
	if "down" in direction:
		projectile.dir_vec.y = 1
	elif "up" in direction:
		projectile.dir_vec.y = -1
		
	projectile.dir_vec = projectile.dir_vec.normalized()
	
	get_tree().get_root().call_deferred("add_child", projectile)
	
func move(delta: float) -> void:
	dir_vec = Input.get_vector("left", "right", "up", "down")
	velocity = dir_vec * speed * delta * 1000
	
	if shoot_animation.time_left == 0:
		var h_move: String = ""
		var v_move: String = ""
		
		if dir_vec.x > 0:
			h_move = "right"
		elif dir_vec.x < 0:
			h_move = "left"
			
		if dir_vec.y > 0:
			v_move = "down"
		elif dir_vec.y < 0:
			v_move = "up"
		
		direction = v_move + h_move
	
	move_and_slide()

func shoot():
	if shoot_cooldown.time_left == 0:
		if Input.is_action_just_pressed("shoot") and ammo >= 1:
			shoot_cooldown.start()
			shoot_animation.start()
			
			var mouse_pos = get_viewport().get_mouse_position()
			var angle = atan2(mouse_pos.y - global_position.y, mouse_pos.x - global_position.x)
			
			if angle < 0:
				angle += TAU
			
			var directions = ["right", "downright", "down", "downleft", "left", "upleft", "up", "upright"]
			direction = directions[int((angle + PI / 8) / (PI / 4)) % 8]
			
			spawn_projectile()
			
			ammo -= 1
			ammobar_fill.size.x = ammo / 3 * 56
			
			if health < max_health:
				regen_cooldown.start(3)
			
		elif ammo < 3:
			ammo += reload_speed
			ammo = min(ammo, 3)
			ammobar_fill.size.x = ammo / 3 * 56

func animate(delta: float):
	if direction:
		sprite.play(direction)
		animation += delta * speed * 0.2
		
		if animation > 4:
			animation = fmod(animation, 4)
		
		sprite.frame = floor(animation)
	else:
		animation = 0
		sprite.frame = 1

func _process(delta: float) -> void:
	if id == 0:
		move(delta)
		shoot()
	
	animate(delta)

func _on_regen_cooldown_timeout() -> void:
	health += max_health * 15 / 100
	health = min(health, max_health)
	
	update_health()
	
	if health < max_health:
		regen_cooldown.start(1)
