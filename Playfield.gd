extends Node2D

var Missile = preload("res://Missile.tscn")

var ammo_sprite = preload("res://assets/patriot.png")

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
var defendColor = Color(100, 0, 0)
var okDraw = true

const Marker = preload("Marker.gd")


# Called when the node enters the scene tree for the first time.
func _ready():
	$Delta.position = delta_loc + Vector2(0, 1)
	$Alpha.position = alpha_loc + Vector2(-10, 1)
	$Omega.position = omega_loc + Vector2(10, 1)
	
	$Delta.self_modulate = ground_color
	$Alpha.self_modulate = ground_color
	$Omega.self_modulate = ground_color
	show_stockpiles()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_alpha"):
		launch_missile(alpha_id, alpha_loc, 10)
	if Input.is_action_just_pressed("ui_delta"):
		launch_missile(delta_id, delta_loc, 15)
	if Input.is_action_just_pressed("ui_omega"):
		launch_missile(omega_id, omega_loc, 10)
	
	update()


func _draw():
	var ground = Rect2(ground_left, ground_right)
	draw_rect(ground, ground_color)
	#if okDraw:
	#	draw_line(base_loc, end_loc, defendColor)
		#okDraw = false
	
	pass
	
func launch_missile(id, location, speed):
	var ammo_left = 0
	if id == alpha_id:
		alpha_ammo -= 1
		ammo_left = alpha_ammo
	elif id == delta_id:
		delta_ammo -= 1
		ammo_left = delta_ammo
	elif id == omega_id:
		omega_ammo -= 1
		ammo_left = omega_ammo
		
	if ammo_left > 0:
		var new_missile = Missile.instance()
		new_missile.position = $Cursor.position
		new_missile.start_loc = location
		new_missile.missile_speed = speed
		add_child(new_missile)
		show_stockpiles()
	
func show_stockpiles():
	return
	show_stockpile(alpha_id)
	show_stockpile(delta_id)
	show_stockpile(omega_id)

func show_stockpile(baseid):
	var base_ammo = alpha_ammo
	var base_loc = alpha_loc
	
	if baseid == 2:
		base_ammo = delta_ammo
		base_loc = delta_loc
	elif baseid == 3:
		base_ammo = omega_ammo
		base_loc = omega_loc
 
	print("ammo -- alpha:", alpha_ammo, " delta:", delta_ammo, " omega:", omega_ammo, " current:", base_ammo)
	var y = 10
	var x = 0
	for i in range(base_ammo):
		print("looping i:", i, " total:", base_ammo)
		var ammo = Sprite.new()
		ammo.set_texture(ammo_sprite)
		if i == 1 or i == 3 or i == 6:
			x = 0 - (y-2)
			y += 10
		ammo.set_position(base_loc + Vector2(x, y))
		x += 16
		ammo.set_scale(Vector2(0.2, 0.15))
		add_child(ammo)
	

	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
#		var marker = Marker.new()
#		add_child(marker)
#		marker.position = event.position
		#$Marker.position = event.position
		#cursor = event.position
		okDraw = true
	elif event is InputEventMouseMotion:
		$Cursor.position = event.position


