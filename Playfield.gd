# Playfield Scene
extends Node2D

const Missile = preload("res://Missile.tscn")
const Bomber = preload("res://Bomber.tscn")
const ICBM = preload("res://ICBM.tscn")

var rng = RandomNumberGenerator.new()

const ICBM_POINTS = 25
const BOMBER_POINTS = 100

var ground_left = Vector2(0, 560)
var ground_right = Vector2(1200, 560)
var ground_color = Color(150, 150, 0)
var end_loc = Vector2(500, 100)
const delta_id = 2
const alpha_id = 1
const omega_id = 3
var delta_ammo = 10
var alpha_ammo = 10
var omega_ammo = 10
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
var icbm_speed
var score = 0
var game_over = true


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	ground_targets = [ alpha_loc, delta_loc, omega_loc, 
		$City1.position, $City2.position, $City3.position, 
		$City4.position, $City5.position, $City6.position]
	
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
		launch_missile(alpha_id, alpha_loc, 10)
	if Input.is_action_just_pressed("ui_delta"):
		launch_missile(delta_id, delta_loc, 15)
	if Input.is_action_just_pressed("ui_omega"):
		launch_missile(omega_id, omega_loc, 10)
	
	update_bomber()
	update_wave()

	if Input.is_action_just_pressed("ui_down"):
		wave_number += 1
		start_wave()
	

func _input(event):
	if event is InputEventMouseMotion:
		var cur_position = event.position
		var min_height = ground_left.y - 80
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
	$ScoreOverlay.show_wave_info(wave_number, get_multiplier())
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
	if id == alpha_id:
		$Alpha.fire($Cursor.position, speed)
	elif id == delta_id:
		$Delta.fire($Cursor.position, speed)
	elif id == omega_id:
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
	
	$City1.position = Vector2(viewport.x / 5, viewport.y - 75)
	$City2.position = Vector2($City1.position.x + 100, $City1.position.y)
	$City3.position = Vector2($City2.position.x + 100, $City1.position.y)

	$City4.position = Vector2(viewport.x / 2 + 100, viewport.y - 75)
	$City5.position = Vector2($City4.position.x + 100, $City1.position.y)
	$City6.position = Vector2($City5.position.x + 100, $City1.position.y)
	
func initialize_bases():
	
	$Alpha/Area2D.connect("area_entered", self, "alpha_hit")
	$Delta/Area2D.connect("area_entered", self, "delta_hit")
	$Omega/Area2D.connect("area_entered", self, "omega_hit")
	
	update()
		
func restore_bases():
	var viewport = get_viewport_rect().size
	
	alpha_loc.y = viewport.y - 75
	delta_loc.y = viewport.y - 75
	omega_loc.y = viewport.y - 75
	
	alpha_loc.x = viewport.x / 10
	delta_loc.x = viewport.x / 2
	omega_loc.x = viewport.x - viewport.x / 10
	
	$Alpha.init(alpha_id, alpha_loc)
	$Delta.init(delta_id, delta_loc)
	$Omega.init(omega_id, omega_loc)

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
	pass
	
func set_stockpiles():
	$Alpha.set_ammo(alpha_ammo)
	$Delta.set_ammo(delta_ammo)
	$Omega.set_ammo(omega_ammo)


func count_cities():
	count_ammo()
	
	var count_loc = Vector2(400, 200)
	yield(get_tree().create_timer(1.0), "timeout")
	
	if $City1.visible:
		$City1.position = count_loc
		update_score(100)
		count_loc += Vector2(60, 0)
		yield(get_tree().create_timer(0.4), "timeout")

	if $City2.visible:
		$City2.position = count_loc
		update_score(100)
		count_loc += Vector2(60, 0)
		yield(get_tree().create_timer(0.4), "timeout")

	if $City3.visible:
		$City3.position = count_loc
		update_score(100)
		count_loc += Vector2(60, 0)
		yield(get_tree().create_timer(0.4), "timeout")

	if $City4.visible:
		$City4.position = count_loc
		update_score(100)
		count_loc += Vector2(60, 0)
		yield(get_tree().create_timer(0.4), "timeout")

	if $City5.visible:
		$City5.position = count_loc
		update_score(100)
		count_loc += Vector2(60, 0)
		yield(get_tree().create_timer(0.4), "timeout")

	if $City6.visible:
		update_score(100)
		$City6.position = count_loc

	yield(get_tree().create_timer(2.0), "timeout")
	restore_cities()

func count_ammo():
	pass

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
		
	score = score + points * get_multiplier()
	
	$ScoreOverlay.update_score(score)
	
	return score

func get_multiplier():
	var multiplier
	if wave_number < 2:
		multiplier = 1
	elif wave_number < 4:
		multiplier = 2
	elif wave_number < 6:
		multiplier = 3
	elif wave_number < 8:
		multiplier = 4
	elif wave_number < 10:
		multiplier = 5
	else:
		multiplier = 6
		
	return multiplier
	

