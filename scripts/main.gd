### Main.gd
extends Node2D

# Couintdown
var countdown_value := 3

# Node REfs
@onready var countdown_label: Label = $UI/CountdownLabel
@onready var countdown_timer: Timer = $CountdownTimer
@onready var viking: CharacterBody2D = $Viking
@onready var mage: CharacterBody2D = $Mage



func _ready() -> void:
	countdown_label.text = str(countdown_value)
	countdown_label.visible = true
	countdown_timer.timeout.connect(_oncountdown_timer_timeout)
	countdown_timer.start()


func _oncountdown_timer_timeout() -> void:
	countdown_value -= 1
	if countdown_value > 0:
		countdown_label.text = str(countdown_value)
	elif countdown_value == 0:
		countdown_label.text = "GO!"
	else:
		countdown_label.visible = false
		countdown_timer.stop()
		viking.game_started = true
		mage.game_started = true
	
	
	
	
	
	
