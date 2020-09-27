extends Node2D

var ammo_count setget set_ammo
var base_id setget set_id
var base_color setget set_color
var fore_color setget set_foreground

# Called when the node enters the scene tree for the first time.
func _ready():
	fore_color = Color(100, 0, 0)
	set_foreground(fore_color)
#	$Status.text = 'TEST'


func set_id(id):
	base_id = id

func set_ammo(ammo):
	ammo_count = ammo
	update_ammo_display()
	
func set_color(new_color):
	base_color = new_color
	$Hill.self_modulate = base_color
	
func set_foreground(new_color):
	fore_color = new_color
	$Status.add_color_override("font_color", fore_color)
	$Status.add_color_override("font_outline", Color(0, 0, 0))
	
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
