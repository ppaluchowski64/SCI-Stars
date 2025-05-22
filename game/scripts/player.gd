extends CharacterBody2D

var Projectile = preload("res://scenes/projectile.tscn")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var regen_cooldown: Timer = $RegenCooldown
@onready var shoot_cooldown: Timer = $ShootCooldown
@onready var shoot_animation: Timer = $ShootAnimation
@onready var immunity_timer: Timer = $ImmunityTimer

@onready var healthbar_fill: ColorRect = $Healthbar/ColorRect
@onready var healthbar_label: Label = $Healthbar/LabelParent/Label

@onready var ammobar: Node2D = $Ammobar
@onready var ammobar_fill: ColorRect = $Ammobar/ColorRect

@onready var nickname_label: Label = $NicknameLabel/Label

@onready var walk_particles: CPUParticles2D = $WalkParticles

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

var kills: int = 0

var ai: Node

var projectile_id: Projectiles.ID = Projectiles.ID.DEFAULT
var projectile_func: Callable = spawn_projectile
var projectile_super_id: Projectiles.ID = Projectiles.ID.BIG_PROJECTILE

var character_id: Characters.ID = Characters.ID.PABLO

# Other
var block_controls: bool = true
var is_main_player: bool = false
var is_dead: bool = false
var is_immune: bool = false

var damage_multiplier: float = 1.0

func setup_ai() -> void:
	var AI = preload("res://scenes/player_ai.tscn")
	
	ai = AI.instantiate()
	ai.player = self
	
	add_child(ai)

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
	
	if is_main_player:
		update_hp_bar()

func update_hp_bar() -> void:
	var health_ratio = float(health) / max_health
	var hue_value = lerp(0.0, 120.0, health_ratio)
	
	var new_color = Color.from_hsv(hue_value / 360.0, 0.60, 0.90)  
	healthbar_fill.color = new_color

func take_damage(damage: int, hitter: Node = null) -> void:
	health -= damage
	
	if health <= 0 and not is_dead:
		is_dead = true
		
		if hitter:
			if is_main_player:
				get_tree().get_first_node_in_group("camera").target = hitter
			
			hitter.kills += 1
		
		emit_signal("update_player_count")
		queue_free()
	
	healthbar_label.text = str(int(health))
	
	regen_cooldown.start(3)

func spawn_projectile(angle: float = get_angle_to(get_global_mouse_position()), _projectile_id = projectile_id) -> void:
	var projectile = Projectiles.custom_projectile(_projectile_id)
	
	projectile.player_id = id
	projectile.global_position = get_global_position()
	projectile.global_rotation = angle
	projectile.parent = self
	
	var base_damage = PlayerData.character_stats[character_id][0].value
	projectile.damage = base_damage * damage_multiplier
	
	get_tree().get_root().call_deferred("add_child", projectile)

func spawn_projectile_spreadshot(angle: float = get_angle_to(get_global_mouse_position()), count: int = 5) -> void:
	var data: Array = [
		[0,   0],
		[20,  0.05],
		[-10, 0.025],
		[10,  0.1],
		[-20, 0.075]
	]
	
	for i in range(count):
		await get_tree().create_timer(data[i][1]).timeout
		spawn_projectile(angle + deg_to_rad(data[i][0]))

func move() -> void:
	if not block_controls:
		dir_vec = Input.get_vector("left", "right", "up", "down")
	else:
		dir_vec = Vector2.ZERO
	
	velocity = dir_vec * speed
	
	if shoot_animation.time_left == 0:
		dir_x = sign(dir_vec.x)
		dir_y = sign(dir_vec.y)
	
	move_and_slide()

# This has to use delta FIX IT
func shoot(delta: float) -> void:
	if shoot_cooldown.time_left == 0:
		if Input.is_action_just_pressed("attack") and ammo >= 1 and not block_controls:
			shoot_cooldown.start()
			shoot_animation.start()
			
			var angle = rad_to_double_dir(get_angle_to(get_global_mouse_position()))
			dir_x = angle[0]
			dir_y = angle[1]
			
			projectile_func.call()
			
			ammo -= 1
			
			if health < max_health:
				regen_cooldown.start(3)
		
		# It's >= instead of == just in case you broke the game and got it above 1
		# It's pretty much impossible but who knows 
		elif Input.is_action_just_pressed("super_attack") and super_charge >= 1 and not block_controls:
			shoot_cooldown.start()
			shoot_animation.start()
			
			var angle = rad_to_double_dir(get_angle_to(get_global_mouse_position()))
			dir_x = angle[0]
			dir_y = angle[1]
			
			spawn_projectile(get_angle_to(get_global_mouse_position()), Projectiles.ID.BIG_PROJECTILE)
			
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
		
		walk_particles.emitting = true
	else:
		animation = 0
		sprite.frame = 1
		
		walk_particles.emitting = false

func _ready() -> void:
	health = max_health
	healthbar_label.text = str(int(health))
	
	sprite.animation = "7"
	sprite.frame = 1
	
	nickname_label.text = "Player" + str(id)

func _process(delta: float) -> void:
	if is_main_player:
		move()
		shoot(delta)
		
		# DEBUG PURPOSES
		if Input.is_action_just_pressed("debug_1"):
			take_damage(9999, get_parent().get_children().pick_random())
		elif Input.is_action_just_pressed("debug_2"):
			for player in get_parent().get_children():
				if player != self:
					player.take_damage(9999)
	else:
		if not block_controls and ai:
			ai.update(delta)
			pass
	
	animate(delta)
	update_ui()

func _on_regen_cooldown_timeout() -> void:
	health += max_health * 15 / 100
	health = min(health, max_health)
	
	healthbar_label.text = str(int(health))
	
	if health < max_health:
		regen_cooldown.start(1)

func _on_immunity_timer_timeout() -> void:
	is_immune = false
	
	for node in get_children():
		if node.is_in_group("shield_fx"):
			node.queue_free()
