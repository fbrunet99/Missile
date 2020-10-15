# Playfield Scene
extends Node2D

const Missile = preload("res://Missile.tscn")
const Bomber = preload("res://Bomber.tscn")
const ICBM = preload("res://ICBM.tscn")
const Smart = preload("res://smart_bomb.tscn")


const ICBM_POINTS = 25
const BOMBER_POINTS = 100
const BASE_AMMO = 10
const DELTA_ID = 2
const ALPHA_ID = 1
const OMEGA_ID = 3
const GROUND_LEFT = Vector2(0, 560)
const GROUND_RIGHT = Vector2(1200, 560)
const JOYSTICK_DEADZONE = 0.2
const JOYSTICK_SENSITIVITY = 5

const MIN_CURSOR_HEIGHT = GROUND_LEFT.y - 80
const MAX_CURSOR_HEIGHT = 0
const MIN_CURSOR_WIDTH = 0
var max_cursor_width

var rng = RandomNumberGenerator.new()

var ground_color = Color(150, 150, 0)
var alpha_loc = Vector2(100, 550)
var delta_loc = Vector2(500, 550)
var omega_loc = Vector2(900, 550)
var defend_color
var attack_color

var bomber_instance = null
var bomber_loc = Vector2(0,0)
var bomber_on = false
var bomber_remain

var city_count = 6
var city_hit = [ false, false, false, false, false, false]
var ground_targets

var siren: AudioStreamPlayback = null

var wave_info = preload("res://WaveInfo.gd").new()
var wave_on = false
var wave_number = 0
var icbm_remain
var icbm_exist
var mirv_remain
var smart_remain
var smart_exist
var ammo_remain
var icbm_speed
var score = 0
var game_over = true


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	ground_targets = [ 
		Vector2(alpha_loc.x, alpha_loc.y - 30), 
		Vector2($City1.position.x - 30, $City1.position.y), 
		Vector2($City2.position.x - 10, $City2.position.y), 
		Vector2($City3.position.x + 10, $City3.position.y), 
		Vector2(delta_loc.x, alpha_loc.y - 30),
		Vector2($City4.position.x + 40, $City4.position.y), 
		Vector2($City5.position.x + 30, $City5.position.y), 
		Vector2($City6.position.x + 40, $City6.position.y),
		Vector2(omega_loc.x, alpha_loc.y - 30),
	]
	
	var _err
	_err = $ScoreOverlay.connect("bonus_points_city", self, "bonus_points_city")
	_err = $ScoreOverlay.connect("bonus_points_ammo", self, "bonus_points_ammo")
	_err = $ScoreOverlay.connect("award_bonus_city", self, "award_bonus_city")
	_err = $ScoreOverlay.connect("game_over", self, "end_game")
	_err = $ScoreOverlay.connect("start_game", self, "start_game")
	initialize_screen()
	
	max_cursor_width = get_viewport_rect().size.x # Sets horizontal boundary for joypad cursor


func _process(delta):
	if Input.is_action_just_pressed("ui_reset"):
		var _ret = get_tree().change_scene("res://Playfield.tscn")

	if Input.is_action_just_pressed("ui_start") and game_over:
		start_game()
		
	update_joystick(delta)
	
	if !wave_on:
		return

	if Input.is_action_just_pressed("ui_alpha"):
		launch_missile(ALPHA_ID, $Cursor.position, 10)
	if Input.is_action_just_pressed("ui_delta"):
		launch_missile(DELTA_ID, $Cursor.position, 15)
	if Input.is_action_just_pressed("ui_omega"):
		launch_missile(OMEGA_ID, $Cursor.position, 10)
	
	update_smart()
	update_bomber()
	update_wave()

	if Input.is_action_just_pressed("ui_down"):
		wave_number += 1
		start_wave()
	

func _input(event):
	if !game_over and event is InputEventMouseMotion:
		var cur_position = event.position
		var min_height = GROUND_LEFT.y - 80
		if cur_position.y > min_height:
			cur_position.y = min_height
		$Cursor.position = cur_position
		if get_tree().paused:
			get_tree().paused = false


func start_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	rng.randomize()
	score = 0
	wave_number = 0
	game_over = false
	reset_score()
	restore_bases()
	restore_cities(true)

	start_wave();

func end_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	game_over = true

func start_wave():
	if game_over:
		return

	$WaveTimer.start()
	$ScoreOverlay.show_wave_info(wave_number, wave_info.get_multiplier(wave_number))
	$StartWave.play()
	ground_color = wave_info.get_basecolor(wave_number)
	defend_color = wave_info.get_defendcolor(wave_number)
	attack_color = wave_info.get_attackcolor(wave_number)
	icbm_speed = wave_info.get_attackspeed(wave_number)
	restore_cities(false)
	restore_bases()
	yield(get_tree().create_timer(5.0), "timeout")
	wave_on = true
	bomber_remain = wave_info.get_bombercount(wave_number)
	icbm_remain  = wave_info.get_icbmcount(wave_number)
	icbm_exist = icbm_remain
	smart_remain = wave_info.get_smartcount(wave_number)
	smart_exist = smart_remain
	mirv_remain = wave_info.get_mirvcount(wave_number)
	
	print("starting wave ", wave_number)
	

func update_wave():
	if ammo_remain <= 0:
		if $Bomber:
			$Bomber.set_wave_end()
			bomber_remain = 0
		
	if icbm_remain <= 0 and icbm_exist <= 0 \
			and smart_remain <= 0 and smart_exist <= 0 \
			and bomber_remain <= 0 and !bomber_on:
		end_wave()

func end_wave():
	$WaveTimer.stop()
	if cities_remain() <= 0:
		print("Playfield: I think the game should be over but maybe there are bonus cities")
		
	wave_on = false
	count_cities()
	yield(get_tree().create_timer(6.0), "timeout")
	
	wave_number += 1
	
	start_wave()
	
	
func update_bomber():
	if bomber_on:
		return

	if bomber_remain  > 0:
		var chance = rng.randf_range(0, 100)
		if chance > 98:
			bomber_instance = Bomber.instance()
			bomber_instance.set_targets(ground_targets)
			bomber_instance.connect("bomber_dropping", self, "spawn_bomber_child")
			add_child(bomber_instance)
			bomber_remain -= 1
			bomber_on = true


func set_bomber_hit(_object):
	update_score(100)
	bomber_on = false
	
func set_bomber_over(_object):
	bomber_on = false

func update_smart():
	var chance = rng.randf_range(0, 900)
	if wave_on and smart_remain > 0 and chance > 890:
		var new_smart = Smart.instance()
		new_smart.connect("smart_hit", self, "smart_hit")
		new_smart.set_targets(ground_targets)
		new_smart.set_speed(1)
		smart_remain -= 1
		add_child(new_smart)
		
	
func update_icbms():
	var chance = rng.randf_range(0, 10)
	if wave_on and icbm_remain > 0 and chance > 2:
		var mult = 1 + rng.randf_range(0, 6)
		
		for _i in range(mult):
			if icbm_remain > 0:
				var new_icbm = ICBM.instance()
				if((icbm_remain > 1) and (randi() % (icbm_remain) < mirv_remain)):
					new_icbm.set_mirv(true)
					mirv_remain -= 1
					var splits = (randi() % 3) + 1
					if splits > icbm_remain:
						splits = icbm_remain
					new_icbm.set_mirv_splits(splits)
					icbm_remain -= (splits)
					new_icbm.connect("mirv_hit", self, "mirv_end")
					new_icbm.connect("mirv_splitting", self, "spawn_mirv_child")
				new_icbm.set_targets(ground_targets)
				new_icbm.set_color(attack_color)
				new_icbm.set_speed(icbm_speed)
				new_icbm.connect("icbm_hit", self, "icbm_end")
				icbm_remain -= 1
				add_child(new_icbm)



func icbm_end():
	icbm_exist -= 1
	update_score(25)


func smart_hit():
	update_score(100)
	smart_exist -= 1

	
func mirv_end(splits):
	icbm_exist -= splits + 1
	update_score(25)

	
func spawn_mirv_child(start_loc, end_loc, can_sub_split):
	var new_icbm = ICBM.instance()
	new_icbm.set_targets(ground_targets)
	new_icbm.set_color(attack_color)
	new_icbm.set_speed(icbm_speed)
	new_icbm.set_mirv_child(true)
	var splits = randi() % 2 + 1
	if can_sub_split and icbm_remain >= splits and mirv_remain >= 1 and (randi() % 4):
		icbm_remain -= splits
		mirv_remain -= 1
		new_icbm.set_mirv(true)
		new_icbm.set_mirv_splits(splits)
	else:
		new_icbm.set_mirv(false)
	new_icbm.set_start_loc(start_loc)
	new_icbm.set_end_loc(end_loc)
	new_icbm.connect("icbm_hit", self, "icbm_end")
	new_icbm.connect("mirv_hit", self, "mirv_end")
	new_icbm.connect("mirv_splitting", self, "spawn_mirv_child")
	add_child(new_icbm)
	
func spawn_bomber_child(start_loc, end_loc):
	var new_icbm = ICBM.instance()
	new_icbm.set_targets(ground_targets)
	new_icbm.set_color(attack_color)
	new_icbm.set_speed(icbm_speed)
	new_icbm.set_bomber_child(true)
	new_icbm.set_mirv(false)
	new_icbm.set_start_loc(start_loc)
	new_icbm.set_end_loc(end_loc)
	add_child(new_icbm)
	

func launch_missile(id, location, speed):
	if id == ALPHA_ID:
		$Alpha.fire(location, speed)
	elif id == DELTA_ID:
		$Delta.fire(location, speed)
	elif id == OMEGA_ID:
		$Omega.fire(location, speed)

func initialize_screen():
	ground_color = wave_info.get_basecolor(wave_number)
	defend_color = wave_info.get_defendcolor(wave_number)
	attack_color = wave_info.get_attackcolor(wave_number)
	
	initialize_bases()
	initialize_cities()
	restore_bases()
	restore_cities(true)
	

func initialize_cities():
	city_count = 6
	var _err

	_err = $City1.connect("area_entered", self, "city1_hit")
	_err = $City2.connect("area_entered", self, "city2_hit")
	_err = $City3.connect("area_entered", self, "city3_hit")
	_err = $City4.connect("area_entered", self, "city4_hit")
	_err = $City5.connect("area_entered", self, "city5_hit")
	_err = $City6.connect("area_entered", self, "city6_hit")
	
	
func restore_cities(var restart):
	$City1.position = Vector2(200, 540)
	$City2.position = Vector2($City1.position.x + 100, $City1.position.y)
	$City3.position = Vector2($City2.position.x + 100, $City1.position.y)

	$City4.position = Vector2(620, $City1.position.y)
	$City5.position = Vector2($City4.position.x + 100, $City1.position.y)
	$City6.position = Vector2($City5.position.x + 100, $City1.position.y)
	
	if !city_hit[0]:
		$City1.visible = true
	if !city_hit[1]:
		$City2.visible = true
	if !city_hit[2]:
		$City3.visible = true
	if !city_hit[3]:
		$City4.visible = true
	if !city_hit[4]:
		$City5.visible = true
	if !city_hit[5]:
		$City6.visible = true

	if restart:
		for i in range(1, 7):
			restore_city(i)

	
func initialize_bases():
	var _err
	
	_err = $Alpha/Area2D.connect("area_entered", self, "alpha_hit")
	_err = $Alpha.connect("missile_launch", self, "missile_fired")

	_err = $Delta/Area2D.connect("area_entered", self, "delta_hit")
	_err = $Delta.connect("missile_launch", self, "missile_fired")

	_err = $Omega/Area2D.connect("area_entered", self, "omega_hit")
	_err = $Omega.connect("missile_launch", self, "missile_fired")
	
	update()
		
func restore_bases():
	
	$Alpha.init(ALPHA_ID, alpha_loc)
	$Delta.init(DELTA_ID, delta_loc)
	$Omega.init(OMEGA_ID, omega_loc)

	$Delta.position = delta_loc
	$Alpha.position = alpha_loc
	$Omega.position = omega_loc

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
	city_hit[id-1] = true
	city.visible = false
	
func missile_fired(_id):
	ammo_remain -= 1
	
func alpha_hit(_id):
	$Alpha.set_ammo(0, true)
	base_hit($Alpha, 1)

func delta_hit(_id):
	$Delta.set_ammo(0, true)
	base_hit($Delta, 2)

func omega_hit(_id):
	$Omega.set_ammo(0, true)
	base_hit($Omega, 3)

func base_hit(_base, id):
	print("Base ", id, " hit")
	
func set_stockpiles():
	ammo_remain = BASE_AMMO * 3
	$Alpha.set_ammo(BASE_AMMO, true)
	$Delta.set_ammo(BASE_AMMO, true)
	$Omega.set_ammo(BASE_AMMO, true)


func count_cities():
	city_count = cities_remain()
	ammo_remain = get_ammo()
	$ScoreOverlay.show_bonus(wave_number, ammo_remain, city_count, score)
		
	restore_cities(false)

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

func get_ammo():
	var count = $Alpha.get_ammo() + $Delta.get_ammo() + $Omega.get_ammo()
	return count

func update_score(points):
	score = score + points * wave_info.get_multiplier(wave_number)
	$ScoreOverlay.update_score(score)
	
	return score

func reset_score():
	$ScoreOverlay.reset_score()
	
func bonus_points_city(points):
	update_score(points)
	var city = null
	
	# Subtract 1 city from display each time this is called 
	if $City1.visible:
		city = $City1
	elif $City2.visible:
		city = $City2
	elif $City3.visible:
		city = $City3
	elif $City4.visible:
		city = $City4
	elif $City5.visible:
		city = $City5
	elif $City6.visible:
		city = $City6
	
	if city:
		city.visible = false

func award_bonus_city():
	restore_cities(false)
	var candidates = []
	
	if !$City1.visible:
		candidates.append(1)
	if !$City2.visible:
		candidates.append(2)
	if !$City3.visible:
		candidates.append(3)
	if !$City4.visible:
		candidates.append(4)
	if !$City5.visible:
		candidates.append(5)
	if !$City6.visible:
		candidates.append(6)
	
	var pick = candidates[randi() % candidates.size()]
	
	restore_city(pick)
	

	
func restore_city(city_num):
	city_hit[city_num -1] = false
	
	if city_num == 1:
		$City1.visible = true
	if city_num == 2:
		$City2.visible = true
	if city_num == 3:
		$City3.visible = true
	if city_num == 4:
		$City4.visible = true
	if city_num == 5:
		$City5.visible = true
	if city_num == 6:
		$City6.visible = true
	

func bonus_points_ammo(points):
	update_score(points)

	# Subtract one ammo from the cities each time this is called	
	var alpha_ammo = $Alpha.get_ammo()
	var delta_ammo = $Delta.get_ammo()
	var omega_ammo = $Omega.get_ammo()
	if alpha_ammo > 0:
		$Alpha.set_ammo(alpha_ammo - 1, false)
	elif delta_ammo > 0:
		$Delta.set_ammo(delta_ammo - 1, false)
	elif omega_ammo > 0:
		$Omega.set_ammo(omega_ammo - 1, false)
		
	

func update_joystick(delta):
	if Input.get_connected_joypads().size() > 0:
		var xAxis = Input.get_joy_axis(0,JOY_AXIS_0)
		var cur_position = $Cursor.position
		if abs(xAxis) > JOYSTICK_DEADZONE:
			if xAxis < 0:
				cur_position.x-= 100 * delta * (JOYSTICK_SENSITIVITY * abs(xAxis))
			if xAxis > 0:
				cur_position.x+= 100 * delta * (JOYSTICK_SENSITIVITY * abs(xAxis))
		var yAxis = Input.get_joy_axis(0,JOY_AXIS_1)
		if abs(xAxis) > JOYSTICK_DEADZONE:
			if yAxis < 0:
				cur_position.y-= 100 * delta * (JOYSTICK_SENSITIVITY * abs(yAxis))
			if yAxis > 0:
				cur_position.y+= 100 * delta * (JOYSTICK_SENSITIVITY * abs(yAxis))
		if cur_position.y > MIN_CURSOR_HEIGHT:
			cur_position.y = MIN_CURSOR_HEIGHT
		elif cur_position.y < MAX_CURSOR_HEIGHT:
			cur_position.y = MAX_CURSOR_HEIGHT
		if cur_position.x < MIN_CURSOR_WIDTH:
			cur_position.x = MIN_CURSOR_WIDTH
		elif cur_position.x > max_cursor_width:
			cur_position.x = max_cursor_width
		$Cursor.position = cur_position
	
	


func _on_WaveTimer_timeout():
	print("**************** WaveTimer Timeout ****************************")
	update_icbms()
