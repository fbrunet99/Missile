extends Node2D

const Missile = preload("res://Missile.tscn")

var ammo_count setget set_ammo
var base_id
var base_color setget set_color
var fore_color setget set_foreground
var parent_position

# Called when the node enters the scene tree for the first time.
func _ready():
	fore_color = Color(100, 0, 0)
	set_foreground(fore_color)
#	$Status.text = 'TEST'

func _process(delta):
	pass
	
func fire(location, speed):
	if ammo_count > 0:
		launch_new_missile(location, speed)

func launch_new_missile(target_position, speed):
	target_position -= parent_position
	
	if ammo_count > 0:
		var new_missile = Missile.instance()
		new_missile.visible = true
		new_missile.position = target_position
		new_missile.start_loc = Vector2(0, 0)
		new_missile.missile_speed = speed
		add_child(new_missile)
	ammo_count -= 1
	update_ammo_display()

func update_ammo_display():
	$Ammo1.visible = ammo_count > 0
	$Ammo2.visible = ammo_count > 1
	$Ammo3.visible = ammo_count > 2
	$Ammo4.visible = ammo_count > 3
	$Ammo5.visible = ammo_count > 4
	$Ammo6.visible = ammo_count > 5
	$Ammo7.visible = ammo_count > 6
	$Ammo8.visible = ammo_count > 7
	$Ammo9.visible = ammo_count > 8
	$Ammo10.visible = ammo_count > 9
	
	if ammo_count <= 3 and ammo_count > 0:
		$Status.text = 'LOW'
	elif ammo_count == 0:
		$Status.text = 'OUT'
	else:
		$Status.text = ''

func init(id, location):
	base_id = id
	parent_position = location
	

func set_ammo(ammo):
	ammo_count = ammo
	update_ammo_display()
	
func set_color(new_color):
	base_color = new_color
	$Area2D/CollisionShape2D/Hill.self_modulate = base_color
	
func set_foreground(new_color):
	fore_color = new_color
	$Status.add_color_override("font_color", fore_color)
	$Status.add_color_override("font_outline", Color(0, 0, 0))
	
