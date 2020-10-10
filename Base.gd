# Base Scene
extends Node2D

const Missile = preload("res://Missile.tscn")
const BASE_TOP = Vector2(0, -30)
var ammo_count
var base_id
var base_color setget set_color
var fore_color setget set_foreground
var parent_position


signal missile_launch

func _ready():
	fore_color = Color(100, 0, 0)
	set_foreground(fore_color)

func _process(delta):
	pass
	
func fire(location, speed):
	if ammo_count > 0:
		launch_new_missile(location, speed)
	else:
		$AmmoOut.play()


func launch_new_missile(target_position, speed):
	target_position -= parent_position
	
	emit_signal("missile_launch", base_id)
	var new_missile = Missile.instance()
	new_missile.visible = true
	new_missile.position = target_position
	new_missile.start_loc = BASE_TOP
	new_missile.missile_speed = speed
	new_missile.set_color(fore_color)
	add_child(new_missile)
	ammo_count -= 1
	update_ammo_display(true)

func update_ammo_display(show_status):
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
	
	if show_status:
		if ammo_count <= 3 and ammo_count > 0:
			$Status.text = 'LOW'
		elif ammo_count == 0:
			$Status.text = 'OUT'
		else:
			$Status.text = ''
	else:
		$Status.text = ''

func init(id, location):
	base_id = id
	parent_position = location
	

func set_ammo(ammo, show_status):
	print("Base: set_ammo ", ammo)
	ammo_count = ammo
	update_ammo_display(show_status)
	

func get_ammo():
	return ammo_count

func set_color(new_color):
	base_color = new_color
	$Area2D/CollisionShape2D/Hill.self_modulate = base_color
	
func set_foreground(new_color):
	fore_color = new_color
	$Status.add_color_override("font_color", fore_color)
	$Status.add_color_override("font_outline", Color(0, 0, 0))
