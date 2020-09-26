extends Node2D

var Explode = preload("res://Explode.tscn")

var is_hit = false
var explode_instance = null


# Called when the node enters the scene tree for the first time.
func _ready():
	$BomberArea.connect("area_entered", self, "bomber_hit")

func start():
	is_hit = false
	if explode_instance:
		remove_child(explode_instance)
		explode_instance = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func bomber_hit(object):
	if is_hit:
		return
		
	print("Bomber: I hit something")
	is_hit = true
	
	var explode_instance = Explode.instance()
	explode_instance.position = $BomberArea/CollisionShape2D/BomberSprite.position
	add_child(explode_instance)
	get_parent().set_bomber_hit(object)
