extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	hide_wave_info()

func update_score(score):
	$HUD/Score.text = str(score)
	
	
func show_wave_info(multiplier):
	hide_start_message()
	$HUD/Multiplier.text = str(multiplier)
	
	$HUD/PlayerLabel.visible = true
	$HUD/PlayerNumber.visible = true
	$HUD/Multiplier.visible = true
	$HUD/PointLabel.visible = true
	$HUD/DefendLabel.visible = true
	$HUD/CitiesLabel.visible = true
	
	yield(get_tree().create_timer(3.0), "timeout")
	hide_wave_info()


func hide_wave_info():
	$HUD/PlayerLabel.visible = false
	$HUD/PlayerNumber.visible = false
	$HUD/Multiplier.visible = false
	$HUD/PointLabel.visible = false
	$HUD/DefendLabel.visible = false
	$HUD/CitiesLabel.visible = false

func show_start_message():
	$HUD/PressStart.visible = true

func hide_start_message():
	$HUD/PressStart.visible = false
