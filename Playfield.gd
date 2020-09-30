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
var defend_color = Color(100, 0, 0)

var bomber_instance = null
var bomber_loc = Vector2(0,0)
var bomber_on = false

var city_count = 6
var ground_targets

var wave_data
var wave_number = 0
var icbm_remain
var bomber_remain


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	ground_targets = [ alpha_loc, delta_loc, omega_loc, 
		$City1.position, $City2.position, $City3.position, 
		$City4.position, $City5.position, $City6.position]
	
	build_wave_data()
	start_wave()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_alpha"):
		launch_missile(alpha_id, alpha_loc, 10)
	if Input.is_action_just_pressed("ui_delta"):
		launch_missile(delta_id, delta_loc, 15)
	if Input.is_action_just_pressed("ui_omega"):
		launch_missile(omega_id, omega_loc, 10)
	
	update_bomber()
	update_icbms()
	update_wave()

	
	if Input.is_action_just_pressed("ui_start"):
		get_tree().change_scene("res://Playfield.tscn")


func start_wave():
	bomber_remain = wave_data[wave_number].bombers
	icbm_remain = wave_data[wave_number].icbms
	ground_color = wave_data[wave_number].baseColor
	defend_color = wave_data[wave_number].defendColor
	$Background.color = wave_data[wave_number].backgroundColor
	$Ground.color = ground_color
	
	initialize_bases()
	initialize_cities()
	

func update_wave():
	if icbm_remain <= 0:
		end_wave()

func end_wave():
	pass
	
	
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
	if chance > 8900:
		var new_icbm = ICBM.instance()
		new_icbm.set_targets(ground_targets)
		add_child(new_icbm)
		

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

	
func _input(event):
	if event is InputEventMouseMotion:
		var cur_position = event.position
		var min_height = ground_left.y - 80
		if cur_position.y > min_height:
			cur_position.y = min_height
		$Cursor.position = cur_position

func build_wave_data():
	wave_data = [
		{
			"icbms": 10,
			"bombers": 0,
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 0, 100),
			"baseColor": Color(100, 100, 0)
		},
		{
			"icbms": 12,
			"bombers": 1, 
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 0, 100),
			"baseColor": Color(100, 100, 0)
		},
		{
			"icbms": 16,
			"bombers": 1, 
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 0, 100),
			"baseColor": Color(0, 0, 100)
		},
		{
			"icbms": 16,
			"bombers": 1, 
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 0, 100),
			"baseColor": Color(0, 0, 100)
		},
		{
			"icbms": 16,
			"bombers": 1, 
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 0, 100),
			"baseColor": Color(0, 0, 100)
		},
		{
			"icbms": 16,
			"bombers": 1, 
			"backgroundColor": Color(0, 0, 0),
			"defendColor": Color(0, 0, 100),
			"baseColor": Color(0, 0, 100)
		},
		{
			"icbms": 18,
			"bombers": 1, 
			"backgroundColor": Color(0, 100, 200),
			"defendColor": Color(0, 0, 100),
			"baseColor": Color(0, 100, 0)
		},
		{
			"icbms": 18,
			"bombers": 1, 
			"backgroundColor": Color(0, 100, 200),
			"defendColor": Color(0, 0, 100),
			"baseColor": Color(0, 100, 0)
		}
	]
