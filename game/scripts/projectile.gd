extends CharacterBody2D

var Explosion = preload("res://scenes/FX/explosion_fx.tscn")
var Field = preload("res://scenes/FX/damage_field_fx.tscn")

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hitbox: Area2D = $Hitbox
@onready var damage_timer: Timer = $DamageTimer

# Stats
var speed: float = 300.0
var distance: float = 300.0
var damage: float = 750.0
var super_charge: float = 0.2

var destroy_on_obstacles: bool = true
var destroy_on_hit: bool = true
var register_hits: bool = true
var hit_bodies: Array

var on_death: Callable
var spawn_immunity: float = 0.0
var ai: Callable = basic_ai

var sprite_rot: float = 0.0

var tween: Tween

var damage_ticks: int = 0

var spin_start: float = deg_to_rad(75)
var spin_end: float = deg_to_rad(-150)
var spin_time: float = 0.4
var spin_ease: bool = true

var sfx: int = 0

# Properties
var travelled: float = 0
var player_id: int
var parent: Node
var is_main_player: bool

func explosion_effect() -> void:
	var explosion = Explosion.instantiate()
	
	explosion.global_position = global_position
	
	if is_main_player:
		explosion.material.set_shader_parameter("is_visible", true)
	
	get_parent().call_deferred("add_child", explosion)

func field_ai(_delta: float) -> void:
	pass

func melee_ai(_delta: float) -> void:
	if not parent:
		queue_free()
		return
	
	global_position = parent.global_position
	global_position += Vector2(80, 0).rotated(global_rotation)

func basic_ai(delta: float) -> void:
	velocity = Vector2(1, 0).rotated(rotation) * speed
	
	if travelled >= distance:
		explosion_effect()
		destroy()
	
	travelled += speed * delta
	
	move_and_slide()
	
	sprite.global_rotation += sprite_rot * delta * 100

func _ready() -> void:
	if parent.is_main_player:
		sprite.material.set_shader_parameter("is_visible", true)
		is_main_player = true
	
	if ai == melee_ai:
		global_rotation += spin_start
		global_position += Vector2(80, 0).rotated(global_rotation)
		
		tween = create_tween()
		
		if spin_ease:
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_CIRC)
		
		if parent.character_id == Characters.ID.KATE:
			spin_time = PlayerData.character_stats[parent.character_id][2].value
		
		tween.tween_property(self, "global_rotation", global_rotation + spin_end, spin_time)
		tween.tween_callback(destroy)
	
	elif ai == field_ai:
		var field = Field.instantiate()
		
		field.global_position = global_position
		
		if is_main_player:
			field.material.set_shader_parameter("is_visible", true)
		
		get_parent().call_deferred("add_child", field)
		
		damage_timer.start()
	
	if spawn_immunity > 0:
		collision.disabled = true
	
	parent.attack_audio.stream = SoundManager.attack_sfx[sfx]
	parent.attack_audio.pitch_scale = randf_range(0.8, 1.2)
	parent.attack_audio.play()

func destroy() -> void:
	if on_death:
		on_death.call(self)
	
	queue_free()

func _process(delta: float) -> void:
	ai.call(delta)
	
	if travelled >= spawn_immunity:
		collision.set_deferred("disabled", false)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if ai == field_ai:
		return
	
	if body.is_in_group("player") and not body in hit_bodies:
		if body.id != player_id:
			if not body.is_immune:
				if parent:
					body.take_damage(damage, parent)
					parent.super_charge = min(parent.super_charge + super_charge, 1.0)
				else:
					body.take_damage(damage)
			
			explosion_effect()
			
			if destroy_on_hit:
				destroy()
			else:
				if register_hits:
					hit_bodies.append(body)
	
	elif body.is_in_group("powerpod") and not body in hit_bodies:
		if parent:
			body.take_damage(damage, parent)
		else:
			body.take_damage(damage)
		
		explosion_effect()
			
		if destroy_on_hit:
			destroy()
		else:
			if register_hits:
				hit_bodies.append(body)
	
	elif body.is_in_group("obstacle") and destroy_on_obstacles:
		explosion_effect()
		destroy()

func _on_damage_timer_timeout() -> void:
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			if body.id != player_id:
				if parent:
					body.take_damage(damage, parent)
					parent.super_charge = min(parent.super_charge + super_charge, 1.0)
				else:
					body.take_damage(damage)
		elif body.is_in_group("powerpod"):
			body.take_damage(damage)
	
	damage_ticks += 1
	
	if damage_ticks >= 8:
		destroy()
