extends Node2D

var is_paused = false

var wave_info = preload("res://WaveInfo.gd").new()
var ammo_texture = preload("res://assets/ammo.png")
var city_texture = preload("res://assets/city.png")

const ammo_pos = Vector2(420, 230)
const city_pos = Vector2(430, 290)

var ammo_sprites = []
var city_sprites = []

func _ready():
	$Pause/PauseLabel.visible = false
	init_sprites()
	show_score()
	show_start_message(1)
	hide_wave_info()

func _process(delta):
	if Input.is_action_just_pressed("ui_pause"):
		_on_pause_button_pressed()



func update_score(score):
	$Score/Player1.text = str(score)
	
func show_score():
	$Score/Player1.visible = true
	
func show_wave_info(new_wave, multiplier):
	hide_start_message()
	hide_bonus()
	var text_color = wave_info.get_defendcolor(new_wave)
	var high_color = wave_info.get_attackcolor(new_wave)

	$StartWave/Multiplier.text = str(multiplier)
	$StartWave/Multiplier.add_color_override("font_color", high_color)

	$StartWave/PlayerLabel.visible = true
	$StartWave/PlayerLabel.add_color_override("font_color", text_color)
	
	$StartWave/PlayerNumber.visible = true
	$StartWave/PlayerNumber.add_color_override("font_color", high_color)
	
	$StartWave/Multiplier.visible = true
	$StartWave/Multiplier.add_color_override("font_color", high_color)
	
	$StartWave/PointLabel.visible = true
	$StartWave/PointLabel.add_color_override("font_color", text_color)
	
	$StartWave/DefendLabel.visible = true
	$StartWave/DefendLabel.add_color_override("font_color", text_color)
	
	$StartWave/CitiesLabel.visible = true
	$StartWave/CitiesLabel.add_color_override("font_color", text_color)
	

	$Score/Player1.add_color_override("font_color", text_color)
	
	
	yield(get_tree().create_timer(3.0), "timeout")
	hide_wave_info()


func hide_wave_info():
	$StartWave/PlayerLabel.visible = false
	$StartWave/PlayerNumber.visible = false
	$StartWave/Multiplier.visible = false
	$StartWave/PointLabel.visible = false
	$StartWave/DefendLabel.visible = false
	$StartWave/CitiesLabel.visible = false

func show_start_message(new_wave):
	hide_wave_info()
	hide_bonus()
	var text_color = wave_info.get_defendcolor(new_wave)

	$Score/Player1.add_color_override("font_color", text_color)
	$StartGame/PressStart.visible = true
	$StartGame/PressStart.add_color_override("font_color", text_color)
	

func hide_start_message():
	$StartGame/PressStart.visible = false

func show_bonus(new_wave, ammo, cities):
	hide_start_message()
	hide_wave_info()
	var text_color = wave_info.get_defendcolor(new_wave)
	var high_color = wave_info.get_attackcolor(new_wave)

	$Bonus/BonusPoints.visible = true
	$Bonus/BonusPoints.add_color_override("font_color", text_color)
	
	$Bonus/Ammo.visible = true
	$Bonus/Ammo.text = "0"
	$Bonus/Ammo.add_color_override("font_color", high_color)

	$Bonus/Cities.visible = true
	$Bonus/Cities.text = "0"
	$Bonus/Cities.add_color_override("font_color", high_color)
	
	var ammo_total = 0
	for i in range(0, ammo):
		ammo_total += 5 * wave_info.get_multiplier(new_wave)
		$Whoosh.play()
		$Bonus/Ammo.text = str(ammo_total)
		ammo_sprites[i].visible = true
		
		yield(get_tree().create_timer(0.1), "timeout")
		
	var city_total = 0
	for i in range(0, cities):
		city_sprites[i].visible = true
		city_total += 100 * wave_info.get_multiplier(new_wave)
		$Whoosh.play()
		$Bonus/Cities.text = str(city_total)
		yield(get_tree().create_timer(0.4), "timeout")

func init_sprites():
	ammo_sprites.resize(30)
	for i in range(0, 30):
		var ammo: Sprite = Sprite.new()
		ammo_sprites[i] = ammo
		ammo_sprites[i].texture = ammo_texture
		ammo_sprites[i].position = ammo_pos + Vector2(15*i, 0)
		add_child(ammo_sprites[i])
		
	city_sprites.resize(6)
	for i in range(0, 6):
		var city: Sprite = Sprite.new()
		city_sprites[i] = city
		city_sprites[i].texture = city_texture
		city_sprites[i].scale = Vector2(0.4, 0.2)
		city_sprites[i].position = city_pos + Vector2(60*i, 0)
		add_child(city_sprites[i])


func hide_bonus():
	$Bonus/BonusPoints.visible = false
	$Bonus/Ammo.visible = false
	$Bonus/Cities.visible = false
	for i in range(0,30):
		ammo_sprites[i].visible = false
	for i in range(0,6):
		city_sprites[i].visible = false
	
func _on_pause_button_pressed():
	is_paused = !is_paused
	get_tree().paused = is_paused
	$Pause/PauseLabel.visible = is_paused
