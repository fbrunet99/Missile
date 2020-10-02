# Playfield Scene
extends Node2D

const Missile = preload("res://Missile.tscn")
const Bomber = preload("res://Bomber.tscn")
const ICBM = preload("res://ICBM.tscn")

var rng = RandomNumberGenerator.new()

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

var wave_data
var wave_on = false
var icbm_dir = {}
var wave_number = 0
var icbm_remain
var icbm_exist
var bomber_remain
var icbm_speed


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	ground_targets = [ alpha_loc, delta_loc, omega_loc, 
		$City1.position, $City2.position, $City3.position, 
		$City4.position, $City5.position, $City6.position]
	
	build_wave_data()
	initialize_screen()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_reset"):
		get_tree().change_scene("res://Playfield.tscn")

	if Input.is_action_just_pressed("ui_start"):
		start_wave()

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
		if wave_number >= wave_data.size():
			wave_number = 0
		start_wave()
	

func _input(event):
	if event is InputEventMouseMotion:
		var cur_position = event.position
		var min_height = ground_left.y - 80
		if cur_position.y > min_height:
			cur_position.y = min_height
		$Cursor.position = cur_position
		

func start_wave():
	wave_on = true
	bomber_remain = wave_data[wave_number].bombers
	
	initialize_screen()
	
	print("starting wave ", wave_number)
	

func update_wave():
	if icbm_remain <= 0 and icbm_exist <= 0:
		end_wave()

func end_wave():
	wave_on = false
	count_cities()

	wave_number += 1
	if wave_number >= wave_data.size():
		wave_number = 0
	
	
func initialize_screen():
	icbm_remain  = wave_data[wave_number].icbms
	icbm_exist = icbm_remain
	ground_color = wave_data[wave_number].baseColor
	defend_color = wave_data[wave_number].defendColor
	attack_color = wave_data[wave_number].attackColor
	icbm_speed = wave_data[wave_number].attackSpeed
	$Background.color = wave_data[wave_number].backgroundColor
	$Ground.color = ground_color
	$Cursor.self_modulate = defend_color
	initialize_bases()
	initialize_cities()
	
	
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
	bomber_on = false
	
func set_bomber_over(object):
	print("playfield: I see the bomber got away")
	bomber_on = false

func update_icbms():
	var chance = rng.randf_range(0, 9000)
	if wave_on and icbm_remain > 0 and chance > 8900:
		var new_icbm = ICBM.instance()
		new_icbm.set_targets(ground_targets)
		new_icbm.set_color(attack_color)
		new_icbm.set_speed(icbm_speed)
		new_icbm.connect("icbm_hit", self, "icbm_end")
		icbm_remain -= 1
		add_child(new_icbm)
		

func icbm_end():
	icbm_exist -= 1
	print("An ICBM blew up. ", icbm_exist, " more expected")
	

func launch_missile(id, location, speed):
	if id == alpha_id:
		$Alpha.fire($Cursor.position, speed)
	elif id == delta_id:
		$Delta.fire($Cursor.position, speed)
	elif id == omega_id:
		$Omega.fire($Cursor.position, speed)


func initialize_cities():
	city_count = 6
	var viewport = get_viewport_rect().size

	$City1.position = Vector2(viewport.x / 5, viewport.y - 75)
	$City2.position = Vector2($City1.position.x + 100, $City1.position.y)
	$City3.position = Vector2($City2.position.x + 100, $City1.position.y)

	$City4.position = Vector2(viewport.x / 2 + 100, viewport.y - 75)
	$City5.position = Vector2($City4.position.x + 100, $City1.position.y)
	$City6.position = Vector2($City5.position.x + 100, $City1.position.y)
	
	
	$City1.connect("area_entered", self, "city1_hit")
	$City2.connect("area_entered", self, "city2_hit")
	$City3.connect("area_entered", self, "city3_hit")
	$City4.connect("area_entered", self, "city4_hit")
	$City5.connect("area_entered", self, "city5_hit")
	$City6.connect("area_entered", self, "city6_hit")
	
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
	
func initialize_bases():
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
	
	$Alpha/Area2D.connect("area_entered", self, "alpha_hit")
	$Delta/Area2D.connect("area_entered", self, "delta_hit")
	$Omega/Area2D.connect("area_entered", self, "omega_hit")

	update()
	
	set_stockpiles()
	
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
	var count_loc = Vector2(400, 200)
	yield(get_tree().create_timer(1.0), "timeout")
	
	if $City1.visible:
		yield(get_tree().create_timer(0.4), "timeout")
		$City1.position = count_loc
		count_loc += Vector2(60, 0)

	if $City2.visible:
		yield(get_tree().create_timer(0.4), "timeout")
		$City2.position = count_loc
		count_loc += Vector2(60, 0)

	if $City3.visible:
		yield(get_tree().create_timer(0.4), "timeout")
		$City3.position = count_loc
		count_loc += Vector2(60, 0)

	if $City4.visible:
		yield(get_tree().create_timer(0.4), "timeout")
		$City4.position = count_loc
		count_loc += Vector2(60, 0)

	if $City5.visible:
		yield(get_tree().create_timer(0.4), "timeout")
		$City5.position = count_loc
		count_loc += Vector2(60, 0)

	if $City6.visible:
		yield(get_tree().create_timer(0.4), "timeout")
		$City6.position = count_loc


func build_wave_data():
	wave_data = [
		{
			"icbms": 5,
			"bombers": 0,
			"attackSpeed": 1,
			"backgroundColor": Color(0, 0, 0), # black
			"defendColor": Color(0, 0, 100),   # blue
			"attackColor": Color(100, 0, 0),   # red
			"baseColor": Color(100, 100, 0)    # yellow
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 0, 100),
			"attackColor": Color(100, 0, 0),
			"baseColor": Color(100, 100, 0)
		},
		{
			"icbms": 11,
			"bombers": 0,
			"attackSpeed": 1,
			"backgroundColor": Color(0, 0, 0), # black
			"defendColor": Color(0, 0, 100),   # red
			"attackColor": Color(0, 100, 0),   # green
			"baseColor": Color(100, 100, 0)    # yellow
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 0, 100),
			"attackColor": Color(0, 100, 0),
			"baseColor": Color(100, 100, 0)
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(0, 0, 0),  # black
			"defendColor": Color(0, 100, 0),    # green
			"attackColor": Color(100, 0, 0),    # red
			"baseColor": Color(0, 0, 100)       # blue
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 100, 0),
			"attackColor": Color(100, 0, 0),
			"baseColor": Color(0, 0, 100)
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 0, 100),    # blue
			"attackColor": Color(100, 100, 0),  # yellow
			"baseColor": Color(100, 0, 0)       #red
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 0, 100),
			"attackColor": Color(100, 100, 0),
			"baseColor": Color(100, 0, 0)
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(0, 0, 80),  # blue
			"defendColor": Color(0, 0, 0),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(0, 100, 0)
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(0, 0, 80),
			"defendColor": Color(0, 0, 0),
			"attackColor": Color(100, 0, 0),
			"baseColor": Color(0, 100, 0)
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(0, 80, 80), # cyan
			"defendColor": Color(0, 0, 100),
			"attackColor": Color(100, 0, 0),
			"baseColor": Color(100, 100, 0)
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(0, 80, 80),
			"defendColor": Color(0, 0, 0),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(100, 100, 0)
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(80, 0, 80), # purple
			"defendColor": Color(80, 80, 0),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(0, 100, 0)
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(80, 0, 80),
			"defendColor": Color(80, 80, 0),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(0, 100, 0)
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(80, 80, 0), # yellow
			"defendColor": Color(100, 0, 0),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(0, 100, 0)
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(80, 80, 0),
			"defendColor": Color(100, 0, 0),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(0, 100, 0)
		},		
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(100, 100, 100), # white
			"defendColor": Color(0, 40, 0),
			"attackColor": Color(0, 0, 80),
			"baseColor": Color(100, 0, 0)
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(100, 100, 100),
			"defendColor": Color(0, 40, 0),
			"attackColor": Color(80, 0, 80),
			"baseColor": Color(100, 0, 0)
		},		
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(80, 0, 0), # red
			"defendColor": Color(80, 0, 80),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(100, 100, 0)
		},
		{
			"icbms": 11,
			"bombers": 1, 
			"attackSpeed": 1,
			"backgroundColor": Color(80, 0, 0),
			"defendColor": Color(80, 0, 80),
			"attackColor": Color(0, 0, 0),
			"baseColor": Color(100, 100, 0)
		}
	]
