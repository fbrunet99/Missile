extends Node2D

var Missile = preload("res://Missile.tscn")

var end_loc = Vector2(500, 100)
var base_loc = Vector2(500, 550)
var defendColor = Color(100, 0, 0)
var okDraw = true

const Marker = preload("Marker.gd")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Base.position = base_loc
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update()
	pass

func _draw():
	#if okDraw:
	#	draw_line(base_loc, end_loc, defendColor)
		#okDraw = false
	
	pass
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var new_missile = Missile.instance()
		new_missile.position = event.position
		new_missile.start_loc = base_loc
		add_child(new_missile)
#		var marker = Marker.new()
#		add_child(marker)
#		marker.position = event.position
		#$Marker.position = event.position
		#cursor = event.position
		okDraw = true
	elif event is InputEventMouseMotion:
		$Cursor.position = event.position


