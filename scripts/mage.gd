### mage.gd
extends CharacterBody2D

## Movement Consts
const WALK_SPEED := 130.0
const RUN_SPEED := 220.0
const JUMP_VELOCITY := -350.0
const GRAVITY := 800.0

## Projectile Scene
const PROJECTILE_SCENE := preload("res://scenes/mage_projectile.tscn")

## Projectile Stats
const ATTACK1_DAMAGE := 0.5
const ATTACK2_DAMAGE := 1.0
const ATTACK1_SPEED :=250.0
const ATTACK2_SPEED := 150.0

## State Tracking
var health := 10.0
var is_dead := false
var is_hurt := false
var is_attacking := false
var can_double_jump := true
var facing_right := false 		# mage starts on right side
var game_started := false
var pending_projectile := {}

## Node Refs
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	anim.play("idle")
	anim.animation_finished.connect(_on_animation_finished)
	anim.frame_changed.connect(_on_frame_changed)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if is_hurt: 
		velocity.y += GRAVITY * delta
		move_and_slide()
		return
	if not game_started:
		velocity.y += GRAVITY * delta
		velocity.x = 0
		move_and_slide()
		_play_anim("idle")
		return
		
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		can_double_jump = true
		
	if is_attacking:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		velocity.x = 0
		move_and_slide()
		return
		
	if Input.is_action_just_pressed("mage_jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			can_double_jump = true
		elif can_double_jump:
			velocity.y = JUMP_VELOCITY
			can_double_jump = false
			
	var direction := 0.0
	if Input.is_action_pressed("mage_left"):
		direction = -1.0
	elif  Input.is_action_pressed("mage_right"):
		direction = 1.0
		
	var is_running := Input.is_action_pressed("mage_run") and direction != 0.0
	var speed := RUN_SPEED if is_running else WALK_SPEED
	
	if direction != 0.0:
		velocity.x = direction * speed
		facing_right = direction > 0.0
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
		
	if Input.is_action_just_pressed("mage_attack1"):
		_start_attack("attack", ATTACK1_DAMAGE, ATTACK1_SPEED, "fire")
		return
	if Input.is_action_just_pressed("mage_attack2"):
		_start_attack("attack_extra", ATTACK2_DAMAGE, ATTACK2_SPEED, "fire_extra")
		return
		
	move_and_slide()
	
	_update_animation(direction, is_running)



func _start_attack(attack_anim: String, damage: float, proj_speed: float, proj_anim: String) -> void:
	is_attacking = true
	velocity.x = 0
	pending_projectile = {
		"damage": damage,
		"speed": proj_speed,
		"anim": proj_anim,
		"spawned": false
	}
	
	_play_anim(attack_anim)
	

func _on_frame_changed() -> void:
	if is_attacking and pending_projectile.size() > 0 and not pending_projectile["spawned"]:
		if anim.frame >= 2:
			_spawn_projectile()
			pending_projectile["spawned"] = true
	

func _spawn_projectile() -> void:
	var proj = PROJECTILE_SCENE.instantiate()
	var dir := 1.0 if facing_right else -1.0
	var spawn_offset := Vector2(50.0 * dir, 0.0)
	proj.global_position = global_position + spawn_offset
	proj.setup(dir, pending_projectile["damage"], pending_projectile["speed"], pending_projectile["anim"])
	get_tree().current_scene.add_child(proj)
	
	

func _update_animation(direction: float, is_running: bool) -> void:
	if not is_on_floor():
		if can_double_jump:
			_play_anim("jump")
		else:
			_play_anim("jump_high")	
		anim.flip_h = not facing_right
	elif direction != 0.0:
		if is_running:
			_play_anim("run")
		else: 
			_play_anim("walk")		
		anim.flip_h = not facing_right
	else:
		_play_anim("idle")
		anim.flip_h = false
		

func _play_anim(anim_name: String) -> void:
	if anim.animation != anim_name:
		anim.play(anim_name)
		

func _on_animation_finished() -> void:
	if is_dead:
		return
		
	if is_hurt:
		is_hurt = false
		_play_anim("idle")
		return
	if is_attacking:
		is_attacking = false
		pending_projectile = {}
		_play_anim("idle")
		return
		
		
func take_damage(amount: float, from_right: bool) -> void:
	if is_dead or is_hurt:
		return
	
	health -= amount
	if health <= 0:
		health = 0
		is_dead = true
		is_attacking = false
		is_hurt = false
		anim.flip_h = from_right
		_play_anim("death")
	else:
		is_hurt = true
		is_attacking = false
		anim.flip_h = not facing_right
		_play_anim("hurt")	
	
	
	
