### Main.gd
extends Node2D

# Couintdown
var countdown_value := 3
var game_over := false


# Node REfs
@onready var countdown_label: Label = $UI/CountdownLabel
@onready var countdown_timer: Timer = $CountdownTimer
@onready var viking: CharacterBody2D = $Viking
@onready var mage: CharacterBody2D = $Mage
@onready var viking_health_bar: ProgressBar = $UI/HealthUI/VikingHealthBar/VikingProgressBar
@onready var mage_health_bar: ProgressBar = $UI/HealthUI/MageHealthBar/ProgressBar
@onready var results_screen: ColorRect = $UI/ResultsScreen
@onready var winner_label: Label = $UI/ResultsScreen/ResultsContainer/WinnerLabel
@onready var loser_laberl: Label = $UI/ResultsScreen/ResultsContainer/LoserLabel
@onready var restart_button: Button = $UI/ResultsScreen/ResultsContainer/RestartButton
@onready var quit_button: Button = $UI/ResultsScreen/ResultsContainer/QuitButton


func _ready() -> void:
	countdown_label.text = str(countdown_value)
	countdown_label.visible = true
	countdown_timer.timeout.connect(_oncountdown_timer_timeout)
	countdown_timer.start()
	
	results_screen.visilbe = false
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	viking.get_node("AnimatedSprite2D").animation_finished.connect(_on_viking_anim_finished)
	mage.get_node("AnimatedSprite2D").animation_finished.connect(_on_mage_anim_finished)


func _process(delta: float) -> void:
	viking_health_bar.value = viking.health
	mage_health_bar.value = mage.health

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


func _on_viking_anim_finished() -> void:
	pass
	
	
func _on_mage_anim_finished() -> void:
	pass
	
	
func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	
func _on_quit_pressed() -> void:
	get_tree().quit()	
	
	
	
