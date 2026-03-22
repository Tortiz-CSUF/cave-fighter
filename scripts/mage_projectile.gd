### MageProjectile.gd
extends Area2D

## Projectile Properties
var speed := 200.0 
var damage := 0.5
var direction := 1.0

### Node Refs
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D



func _ready() -> void:
	anim.flip_h = direction < 0.0
	body_entered.connect(_on_body_entered)



func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
	

func setup(proj_direction: float, proj_damage: float, proj_speed: float, anim_name: String) -> void:
	direction = proj_direction
	damage = proj_damage
	speed = proj_speed
	call_deferred("_play_animation", anim_name)
	
	
func _play_animation(anim_name: String) -> void:
	anim.play(anim_name)
	anim.flip_h = direction < 0.0
	

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var hit_from_right := global_position.x > body.global_position.x
		body.take_damage(damage, hit_from_right)
	queue_free()
	
	
func _process(delta: float) -> void:
	if global_position.x < -100 or global_position.x > 1100:
		queue_free()
