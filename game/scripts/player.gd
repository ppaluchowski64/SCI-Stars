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

# I should probably disable this warning globally... later
@warning_ignore("unused_signal")
signal update_player_count

# Enums
enum {RIGHT, LEFT, DOWN, UP}

# Stats
var speed: float = 180.0
var max_health: float = 3000.0

# Properties
var dir_vec: Vector2
var dir_x: int
var dir_y: int
var animation: float
var health: float = max_health
var ammo: float = 3.0
var reload_speed: float = 0.75
var super_charge: float = 0.0

func rad_to_double_dir(angle: float) -> Array:
	if angle < 0:
		angle += TAU
	
	var dir_angle = int((angle / (TAU / 8)) + 0.5) % 8
	
	dir_x = [1, 1, 0, -1, -1, -1, 0, 1][dir_angle]
	dir_y = [0, 1, 1, 1, 0, -1, -1, -1][dir_angle]
	
	return [dir_x, dir_y]

func double_to_single_dir(x: int, y: int) -> int:
	return x + y * 3 + 4
	# left-up = 0
	# up = 1
	# right-up = 2
	# left = 3
	# idle = 4 (no animation for this one)
	# right = 5
	# left-down = 6
	# down = 7
	# right-down = 8

func update_ui() -> void:
	healthbar_fill.size.x = lerp(healthbar_fill.size.x, health / max_health * 56, Const.STATUS_BAR_SMOOTHNESS)
	ammobar_fill.size.x = lerp(ammobar_fill.size.x, ammo / 3 * 56, Const.STATUS_BAR_SMOOTHNESS)

func take_damage(damage: int) -> void:
	health -= damage
	
	if health <= 0:
		emit_signal("update_player_count")
		queue_free()
	
	healthbar_label.text = str(health)
	
	regen_cooldown.start(3)

func spawn_projectile(projectile_id: Projectiles.ID = Projectiles.ID.DEFAULT) -> void:
	var projectile = Projectiles.custom_projectile(projectile_id)
	
	projectile.player_id = id
	projectile.global_position = get_global_position()
	projectile.global_rotation = get_angle_to(get_global_mouse_position())
	projectile.parent = self
	
	get_tree().get_root().call_deferred("add_child", projectile)

func move() -> void:
	dir_vec = Input.get_vector("left", "right", "up", "down")
	velocity = dir_vec * speed
	
	if shoot_animation.time_left == 0:
		dir_x = sign(dir_vec.x)
		dir_y = sign(dir_vec.y)
	
	move_and_slide()

# This has to use delta FIX IT
func shoot(delta: float) -> void:
	if shoot_cooldown.time_left == 0:
		if Input.is_action_just_pressed("attack") and ammo >= 1:
			shoot_cooldown.start()
			shoot_animation.start()
			
			var angle = rad_to_double_dir(get_angle_to(get_global_mouse_position()))
			dir_x = angle[0]
			dir_y = angle[1]
			
			spawn_projectile()
			
			ammo -= 1
			
			if health < max_health:
				regen_cooldown.start(3)
		
		# It's >= instead of == just in case you broke the game and got it above 1
		# It's pretty much impossible but who knows 
		elif Input.is_action_just_pressed("super_attack") and super_charge >= 1:
			shoot_cooldown.start()
			shoot_animation.start()
			
			var angle = rad_to_double_dir(get_angle_to(get_global_mouse_position()))
			dir_x = angle[0]
			dir_y = angle[1]
			
			spawn_projectile(Projectiles.ID.BIG_PROJECTILE)
			
			super_charge = 0
			
		elif ammo < 3:
			ammo += reload_speed * delta
			ammo = min(ammo, 3)

func animate(delta: float) -> void:
	if dir_x or dir_y:
		sprite.play(str(double_to_single_dir(dir_x, dir_y)))
		
		animation += delta * speed * 0.02
		
		if animation > 4:
			animation = fmod(animation, 4)
		
		sprite.frame = floor(animation)
	else:
		animation = 0
		sprite.frame = 1

func _process(delta: float) -> void:
	if id == 0:
		move()
		shoot(delta)
	
	animate(delta)
	update_ui()

func _on_regen_cooldown_timeout() -> void:
	health += max_health * 15 / 100
	health = min(health, max_health)
	
	healthbar_label.text = str(health)
	
	if health < max_health:
		regen_cooldown.start(1)
