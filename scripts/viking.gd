### viking.gd
extends CharacterBody2D

## Movement Consts
const WALK_SPEED := 130.0
const RUN_SPEED := 220.0
const JUMP_VELOCITY := -350.0
const GRAVITY := 800.0

## Attack Damage Vals
const ATTACK1_DAMAGE := 1.0
const ATTACK2_DAMAGE := 1.5

## State Tracking
var health := 10.0
var is_dead := false
var is_hurt := false
var is_attacking := false
var can_double_jump := true
var facing_right := true
var game_started := false
var current_attack_damage := 0.0


## Node Refs
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/AttackShape


func _ready() -> void:
	anim.play("idle")
	anim.animation_finished.connect(_on_animation_finished)
	attack_shape.disabled = true
	attack_area.body_entered.connect(_on_attack_body_entered)

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
		
	if Input.is_action_just_pressed("viking_jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			can_double_jump = true
		elif can_double_jump:
			velocity.y = JUMP_VELOCITY
			can_double_jump = false
			
	var direction := 0.0
	if Input.is_action_pressed("viking_left"):
		direction = -1.0
	elif  Input.is_action_pressed("viking_right"):
		direction = 1.0
		
	var is_running := Input.is_action_pressed("viking_run") and direction != 0.0
	var speed := RUN_SPEED if is_running else WALK_SPEED
	
	if direction != 0.0:
		velocity.x = direction * speed
		facing_right = direction > 0.0
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
		
	if Input.is_action_just_pressed("viking_attack1"):
		_start_attack("attack", ATTACK1_DAMAGE)
		return
	if Input.is_action_just_pressed("viking_attack2"):
		_start_attack("attack_extra", ATTACK2_DAMAGE)
		return
		
	move_and_slide()
	
	_update_animation(direction, is_running)
	_update_attack_hitbox_position()


func _start_attack(attack_name: String, damage: float) -> void:
	is_attacking = true
	current_attack_damage = damage
	velocity.x = 0
	attack_shape.disabled = false
	_update_attack_hitbox_position()
	_play_anim(attack_name)
	

func _update_attack_hitbox_position() -> void:
	if facing_right:
		attack_area.position.x = abs(attack_area.position.x)
	else:
		attack_area.position.x = -abs(attack_area.position.x)
	
	
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
		attack_shape.disabled = true
		_play_anim("idle")
		return


func _on_attack_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and is_attacking:
		var hit_from_right := global_position.x > body.global_position.x
		body.take_damage(current_attack_damage, hit_from_right)
	
			
		
func take_damage(amount: float, from_right: bool) -> void:
	if is_dead or is_hurt:
		return
	
	health -= amount
	if health <= 0:
		health = 0
		is_dead = true
		is_attacking = false
		is_hurt = false
		attack_shape.disabled = true
		anim.flip_h = from_right
		_play_anim("death")
	else:
		is_hurt = true
		is_attacking = false
		attack_shape.disabled = true
		anim.flip_h = not facing_right
		_play_anim("hurt")	
	
	
	
