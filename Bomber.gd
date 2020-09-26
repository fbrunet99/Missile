extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$BomberArea.connect("area_entered", self, "bomber_hit")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func bomber_hit(object):
	print("Bomber: I hit something")
	get_parent().set_bomber_hit(object)
