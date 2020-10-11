extends Node2D

signal bonus_points_city
signal bonus_points_ammo
signal award_bonus_city

const AMMO_POS = Vector2(420, 230)
const CITY_POS = Vector2(430, 290)
const BONUS_CITY_LEVEL = 10000

var is_paused = false

var wave_info = preload("res://WaveInfo.gd").new()
var ammo_texture = preload("res://assets/ammo.png")
var city_texture = preload("res://assets/city.png")

var ammo_sprites = []
var city_sprites = []

var cities_awarded = 0


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
	
func reset_score():
	$Score/Player1.text = "0"
	cities_awarded = 0
	
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
	
	$StartGame/PressStart.add_color_override("font_color", text_color)
	
	yield(get_tree().create_timer(3.0), "timeout")
	hide_wave_info()


func hide_wave_info():
	$StartWave/PlayerLabel.visible = false
	$StartWave/PlayerNumber.visible = false
	$StartWave/Multiplier.visible = false
	$StartWave/PointLabel.visible = false
	$StartWave/DefendLabel.visible = false
	$StartWave/CitiesLabel.visible = false
	$Bonus/BonusCity.visible = false

func show_start_message(new_wave):
	hide_wave_info()
	hide_bonus()
	var text_color = wave_info.get_defendcolor(new_wave)

	$Score/Player1.add_color_override("font_color", text_color)
	$StartGame/PressStart.visible = true
	$StartGame/PressStart.add_color_override("font_color", text_color)
	

func hide_start_message():
	$StartGame/PressStart.visible = false

func show_bonus(new_wave, ammo, cities, score):
	hide_start_message()
	hide_wave_info()
	var text_color = wave_info.get_defendcolor(new_wave)
	var high_color = wave_info.get_attackcolor(new_wave)

	$Bonus/BonusCity.visible = false
	$Bonus/BonusCity.add_color_override("font_color", text_color)

	$Bonus/BonusPoints.visible = true
	$Bonus/BonusPoints.add_color_override("font_color", text_color)
	
	$Bonus/Ammo.visible = true
	$Bonus/Ammo.text = "0"
	$Bonus/Ammo.add_color_override("font_color", high_color)

	$Bonus/Cities.visible = true
	$Bonus/Cities.text = "0"
	$Bonus/Cities.add_color_override("font_color", high_color)
	
	var ammo_total = 0
	var ammo_points = 5 * wave_info.get_multiplier(new_wave)
	for i in range(0, ammo):
		ammo_total += ammo_points
		$Whoosh.play()
		$Bonus/Ammo.text = str(ammo_total)
		emit_signal("bonus_points_ammo", 5)
		ammo_sprites[i].visible = true
		yield(get_tree().create_timer(0.1), "timeout")
		
	var city_total = 0
	var city_points = 100 * wave_info.get_multiplier(new_wave)
	for i in range(0, cities):
		city_sprites[i].visible = true
		city_total += city_points
		score += city_total
		emit_signal("bonus_points_city", city_points)
		$Whoosh.play()
		$Bonus/Cities.text = str(city_total)
		yield(get_tree().create_timer(0.4), "timeout")
		
	score = score + city_total + ammo_total
	var total_cities_earned = int(score / BONUS_CITY_LEVEL)
	
	var new_cities = 0
	for i in range(cities, 6):
		if total_cities_earned > cities_awarded:
			cities_awarded += 1
			new_cities += 1
			emit_signal("award_bonus_city")
	
	if new_cities > 0:
		show_bonus_city_message()
		
	if cities + new_cities <= 0:
		show_start_message(0)

func show_bonus_city_message():
	$Bonus/BonusCity.visible = true
	yield(get_tree().create_timer(1.4), "timeout")
	# TODO: play tune here
	$Bonus/BonusCity.visible = false
	
	
func init_sprites():
	ammo_sprites.resize(30)
	for i in range(0, 30):
		var ammo: Sprite = Sprite.new()
		ammo_sprites[i] = ammo
		ammo_sprites[i].texture = ammo_texture
		ammo_sprites[i].position = AMMO_POS + Vector2(15*i, 0)
		add_child(ammo_sprites[i])
		
	city_sprites.resize(6)
	for i in range(0, 6):
		var city: Sprite = Sprite.new()
		city_sprites[i] = city
		city_sprites[i].texture = city_texture
		city_sprites[i].scale = Vector2(0.4, 0.2)
		city_sprites[i].position = CITY_POS + Vector2(60*i, 0)
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
