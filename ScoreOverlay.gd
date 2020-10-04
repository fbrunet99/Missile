extends Node2D

var wave_info = preload("res://WaveInfo.gd").new()

func _ready():
	show_start_message(1)
	hide_wave_info()

func update_score(score):
	$HUD/Score.text = str(score)
	
	
func show_wave_info(new_wave, multiplier):
	hide_start_message()
	var text_color = wave_info.get_defendcolor(new_wave)
	var high_color = wave_info.get_attackcolor(new_wave)

	$HUD/Multiplier.text = str(multiplier)
	$HUD/Multiplier.add_color_override("font_color", high_color)

	$HUD/PlayerLabel.visible = true
	$HUD/PlayerLabel.add_color_override("font_color", text_color)
	
	$HUD/PlayerNumber.visible = true
	$HUD/PlayerNumber.add_color_override("font_color", high_color)
	
	$HUD/Multiplier.visible = true
	$HUD/Multiplier.add_color_override("font_color", high_color)
	
	$HUD/PointLabel.visible = true
	$HUD/PointLabel.add_color_override("font_color", text_color)
	
	$HUD/DefendLabel.visible = true
	$HUD/DefendLabel.add_color_override("font_color", text_color)
	
	$HUD/CitiesLabel.visible = true
	$HUD/CitiesLabel.add_color_override("font_color", text_color)
	
	
	$HUD/Score.add_color_override("font_color", text_color)
	
	
	yield(get_tree().create_timer(3.0), "timeout")
	hide_wave_info()


func hide_wave_info():
	$HUD/PlayerLabel.visible = false
	$HUD/PlayerNumber.visible = false
	$HUD/Multiplier.visible = false
	$HUD/PointLabel.visible = false
	$HUD/DefendLabel.visible = false
	$HUD/CitiesLabel.visible = false

func show_start_message(new_wave):
	var text_color = wave_info.get_defendcolor(new_wave)

	$HUD/Score.add_color_override("font_color", text_color)
	$HUD/PressStart.visible = true
	$HUD/PressStart.add_color_override("font_color", text_color)
	

func hide_start_message():
	$HUD/PressStart.visible = false
