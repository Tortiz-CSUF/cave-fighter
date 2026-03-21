### viking.gd
extends CharacterBody2D

## Movement Consts
const WALK_SPEED := 130.0
const RUN_SPEED := 220.0
const JUMP_VELOCITY : = -350.0
const GRAVITY := 800.0

## State Tracking
var health := 10.0
var is_dead := false
var is_hurt := false
var is_attacking := false
var can_double_jump := true
var facing_right := true
var game_started := false

## Node Refs
@onready var anim: AnimatableBody2D = $AnimatedSprite2D


func _ready() -> void:
	anim.play("idle")
	anim.animation_finished.conect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()



func _start_attack(attack_name: String) -> void:
	is_attacking = true
	velocity.x = 0
	_play_anim(attack_name)
	
	
func _update_animation(direction: float, is_running: bool) -> void:
	if not is_on_floor():
		if can_double_jump:
			_play_anim("jump")
		else:
			_play_anim("jump_high")	
	
	
	
	
	
	
	
func _play_anim(anim_name: String) -> void:
	if anim.animaation != anim_name:
		anim.play(anim_name
		
		)	
	
	
	
	
	
	
	
	
	
	
	
