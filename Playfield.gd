extends Node2D

var Missile = preload("res://Missile.tscn")

var end_loc = Vector2(500, 100)
var delta_loc = Vector2(500, 540)
var alpha_loc = Vector2(100, 540)
var omega_loc = Vector2(900, 540)
var defendColor = Color(100, 0, 0)
var okDraw = true

const Marker = preload("Marker.gd")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Delta.position = delta_loc + Vector2(0, 10)
	$Alpha.position = alpha_loc + Vector2(-10, 10)
	$Omega.position = omega_loc + Vector2(10, 10)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_alpha"):
		launch_missile(alpha_loc)
	if Input.is_action_just_pressed("ui_delta"):
		launch_missile(delta_loc)
	if Input.is_action_just_pressed("ui_omega"):
		launch_missile(omega_loc)
	
	update()


func _draw():
	#if okDraw:
	#	draw_line(base_loc, end_loc, defendColor)
		#okDraw = false
	
	pass
	
func launch_missile(location):
	var new_missile = Missile.instance()
	new_missile.position = $Cursor.position
	new_missile.start_loc = location
	add_child(new_missile)
	
	
	
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


