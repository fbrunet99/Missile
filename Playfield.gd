# Playfield Scene
extends Node2D

const Missile = preload("res://Missile.tscn")
const Bomber = preload("res://Bomber.tscn")
const ICBM = preload("res://ICBM.tscn")

var rng = RandomNumberGenerator.new()

const ICBM_POINTS = 25
const BOMBER_POINTS = 100
const BASE_AMMO = 10
const DELTA_ID = 2
const ALPHA_ID = 1
const OMEGA_ID = 3
const GROUND_LEFT = Vector2(0, 560)
const GROUND_RIGHT = Vector2(1200, 560)

var ground_color = Color(150, 150, 0)
var end_loc = Vector2(500, 100)
var delta_loc = Vector2(500, 535)
var alpha_loc = Vector2(100, 535)
var omega_loc = Vector2(900, 535)
var defend_color
var attack_color

var bomber_instance = null
var bomber_loc = Vector2(0,0)
var bomber_on = false

var city_count = 6
var ground_targets

var wave_info = preload("res://WaveInfo.gd").new()
var wave_on = false
var icbm_dir = {}
var wave_number = 0
var icbm_remain
var icbm_exist
var bomber_remain
var ammo_remain
var icbm_speed
var score = 0
var game_over = true


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	ground_targets = [ alpha_loc, delta_loc, omega_loc, 
		Vector2($City1.position.x - 20, $City1.position.y), 
		$City2.position, 
		$City3.position, 
		$City4.position, 
		Vector2($City5.position.x + 30, $City5.position.y), 
		Vector2($City6.position.x + 50, $City6.position.y)]
	
	initialize_screen()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_pause"):
		_on_pause_button_pressed()

	if Input.is_action_just_pressed("ui_reset"):
		get_tree().change_scene("res://Playfield.tscn")

	if Input.is_action_just_pressed("ui_start") and game_over:
		start_game()

	if !wave_on:
		return

	update_icbms()

	if Input.is_action_just_pressed("ui_alpha"):
		launch_missile(ALPHA_ID, alpha_loc, 10)
	if Input.is_action_just_pressed("ui_delta"):
		launch_missile(DELTA_ID, delta_loc, 15)
	if Input.is_action_just_pressed("ui_omega"):
		launch_missile(OMEGA_ID, omega_loc, 10)
	
	update_bomber()
	update_wave()

	if Input.is_action_just_pressed("ui_down"):
		wave_number += 1
		start_wave()
	

func _input(event):
	if event is InputEventMouseMotion:
		var cur_position = event.position
		var min_height = GROUND_LEFT.y - 80
		if cur_position.y > min_height:
			cur_position.y = min_height
		$Cursor.position = cur_position
		if get_tree().paused:
			get_tree().paused = false
		
func _on_pause_button_pressed():
	var is_paused = get_tree().paused
	print("Pause set, current value is ", is_paused)
	#get_tree().paused = !is_paused
	
func start_game():
	game_over = false
	start_wave();

func end_game():
	game_over = true

func start_wave():
	$ScoreOverlay.show_wave_info(wave_number, wave_info.get_multiplier(wave_number))
	ground_color = wave_info.get_basecolor(wave_number)
	defend_color = wave_info.get_defendcolor(wave_number)
	attack_color = wave_info.get_attackcolor(wave_number)
	icbm_speed = wave_info.get_attachspeed(wave_number)
	restore_cities()
	restore_bases()
	yield(get_tree().create_timer(5.0), "timeout")
	wave_on = true
	bomber_remain = wave_info.get_bombercount(wave_number)
	icbm_remain  = wave_info.get_icbmcount(wave_number)
	icbm_exist = icbm_remain
	
	print("starting wave ", wave_number)
	

func update_wave():
	if icbm_remain <= 0 and icbm_exist <= 0:
		end_wave()

func end_wave():
	if cities_remain() <= 0:
		end_game()
		
	wave_on = false
	count_cities()
	yield(get_tree().create_timer(6.0), "timeout")
	
	wave_number += 1
	
	start_wave()
	
	
func update_bomber():
	if bomber_on:
		return

	if bomber_remain  > 0:
		var chance = rng.randf_range(0, 10000)
		if chance > 9800:
			print("I'm starting a bomber, chance was ", chance)
			bomber_instance = Bomber.instance()
			var height = rng.randf_range(100,300)
			add_child(bomber_instance)
			bomber_remain -= 1
			bomber_on = true


func set_bomber_hit(object):
	print("playfield: I see that the bomber was hit")
	update_score(100)
	bomber_on = false
	
func set_bomber_over(object):
	print("playfield: I see the bomber got away")
	bomber_on = false

func update_icbms():
	var chance = rng.randf_range(0, 9000)
	if wave_on and icbm_remain > 0 and chance > 8900:
		var mult = 1 + rng.randf_range(0, 5)
		
		for i in range(mult):
			if icbm_remain > 0:
				var new_icbm = ICBM.instance()
				new_icbm.set_targets(ground_targets)
				new_icbm.set_color(attack_color)
				new_icbm.set_speed(icbm_speed)
				new_icbm.connect("icbm_hit", self, "icbm_end")
				icbm_remain -= 1
				add_child(new_icbm)
			
		

func icbm_end():
	icbm_exist -= 1
	update_score(25)
	print("ICBM ended ", icbm_exist, " remain. wave_on=", wave_on)
	

func launch_missile(id, location, speed):
	if id == ALPHA_ID:
		$Alpha.fire($Cursor.position, speed)
	elif id == DELTA_ID:
		$Delta.fire($Cursor.position, speed)
	elif id == OMEGA_ID:
		$Omega.fire($Cursor.position, speed)

func initialize_screen():
	ground_color = wave_info.get_basecolor(wave_number)
	defend_color = wave_info.get_defendcolor(wave_number)
	attack_color = wave_info.get_attackcolor(wave_number)
	
	initialize_bases()
	restore_bases()
	initialize_cities()
	restore_cities()
	

func initialize_cities():
	city_count = 6

	$City1.connect("area_entered", self, "city1_hit")
	$City2.connect("area_entered", self, "city2_hit")
	$City3.connect("area_entered", self, "city3_hit")
	$City4.connect("area_entered", self, "city4_hit")
	$City5.connect("area_entered", self, "city5_hit")
	$City6.connect("area_entered", self, "city6_hit")
	
	
func restore_cities():
	var viewport = get_viewport_rect().size
	
	$City1.position = Vector2(200, 540)
	$City2.position = Vector2($City1.position.x + 100, $City1.position.y)
	$City3.position = Vector2($City2.position.x + 100, $City1.position.y)

	$City4.position = Vector2(620, $City1.position.y)
	$City5.position = Vector2($City4.position.x + 100, $City1.position.y)
	$City6.position = Vector2($City5.position.x + 100, $City1.position.y)
	
func initialize_bases():
	
	$Alpha/Area2D.connect("area_entered", self, "alpha_hit")
	$Alpha.connect("missile_launch", self, "missile_fired")

	$Delta/Area2D.connect("area_entered", self, "delta_hit")
	$Delta.connect("missile_launch", self, "missile_fired")

	$Omega/Area2D.connect("area_entered", self, "omega_hit")
	$Omega.connect("missile_launch", self, "missile_fired")
	
	update()
		
func restore_bases():
	var viewport = get_viewport_rect().size
	
	alpha_loc.y = viewport.y - 75
	delta_loc.y = viewport.y - 75
	omega_loc.y = viewport.y - 75
	
	alpha_loc.x = viewport.x / 10
	delta_loc.x = viewport.x / 2
	omega_loc.x = viewport.x - viewport.x / 10
	
	$Alpha.init(ALPHA_ID, alpha_loc)
	$Delta.init(DELTA_ID, delta_loc)
	$Omega.init(OMEGA_ID, omega_loc)

	$Delta.position = delta_loc + Vector2(0, 1)
	$Alpha.position = alpha_loc + Vector2(-10, 1)
	$Omega.position = omega_loc + Vector2(0, 1)

	$Delta.set_color(ground_color)
	$Alpha.set_color(ground_color)
	$Omega.set_color(ground_color)

	$Delta.set_foreground(defend_color)
	$Alpha.set_foreground(defend_color)
	$Omega.set_foreground(defend_color)

	$Background.color = wave_info.get_backgroundcolor(wave_number)
	$Ground.color = ground_color
	$Cursor.self_modulate = defend_color

	set_stockpiles()


	
func city1_hit(_event):
	remove_city($City1, 1)
	
func city2_hit(_event):
	remove_city($City2, 2)
	
func city3_hit(_event):
	remove_city($City3, 3)
		
func city4_hit(_event):
	remove_city($City4, 4)
			
func city5_hit(_event):
	remove_city($City5, 5)
		
func city6_hit(_event):
	remove_city($City6, 6)
		
func remove_city(city, id):
	if !wave_on:
		return
	print("City ", id, " hit")
	city_count -= 1
	city.position = Vector2(city.position.x, city.position.y + 100)
	city.visible = false
	
func missile_fired(_id):
	ammo_remain -= 1
	
func alpha_hit(_id):
	$Alpha.set_ammo(0)
	base_hit($Alpha, 1)

func delta_hit(_id):
	$Delta.set_ammo(0)
	base_hit($Delta, 2)

func omega_hit(_id):
	$Omega.set_ammo(0)
	base_hit($Omega, 3)

func base_hit(base, id):
	print("Base ", id, " hit")
	
func set_stockpiles():
	ammo_remain = BASE_AMMO * 3
	$Alpha.set_ammo(BASE_AMMO)
	$Delta.set_ammo(BASE_AMMO)
	$Omega.set_ammo(BASE_AMMO)


func count_cities():
	var city_count = cities_remain()
	
	$ScoreOverlay.show_bonus(wave_number, ammo_remain, city_count)
		
	restore_cities()

func cities_remain():
	var count = 0
	
	if $City1.visible:
		count += 1
	if $City2.visible:
		count += 1
	if $City3.visible:
		count += 1
	if $City4.visible:
		count += 1
	if $City5.visible:
		count += 1
	if $City6.visible:
		count += 1
	
	return count

func update_score(points):
		
	score = score + points * wave_info.get_multiplier(wave_number)
	
	$ScoreOverlay.update_score(score)
	
	return score

	

