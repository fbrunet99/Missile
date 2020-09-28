extends Node2D

var Explode = preload("res://Explode.tscn")
var rng = RandomNumberGenerator.new()

var is_hit = false
var explode_instance = null
var velocity = Vector2(-1, 0)
var max_x = 1100
var max_y = 800
var min_x = -100


# Called when the node enters the scene tree for the first time.
func _ready():
	var viewport = get_viewport_rect().size
	max_x = viewport.x + 100
	max_y = viewport.y / 2
	
	$BomberArea.scale = Vector2(.7, 1)
	rng.randomize()
	var height = rand_range(100, max_y)
	var direction = rand_range(-1, 1)
	velocity = Vector2(direction * 3, 0)
	if direction > 0:
		position = Vector2(0, height)
		$BomberArea/CollisionShape2D/BomberSprite.flip_h = true
	else:
		position = Vector2(max_x - 50, height)
		
	print("Starting a bomber at position:", position, "  direction:", direction)
	$BomberArea.connect("area_entered", self, "bomber_hit")


func _process(delta):
	if is_hit:
		return

	position += velocity
	
	if position.x > max_x or position.x < min_x:
		print("bomber went too far off screen, ending")
		get_parent().set_bomber_over(self) # raise signal instead
		
		end_bomber()
	


func bomber_hit(object):
	if is_hit:
		return
		
	print("Bomber: I hit something")
	is_hit = true
	
	var explode_instance = Explode.instance()
	explode_instance.position = $BomberArea/CollisionShape2D/BomberSprite.position
	add_child(explode_instance)
	$BomberArea/CollisionShape2D/BomberSprite.visible = false
	explode_instance.connect("explode_end", self, "_on_bomber_explode")
	get_parent().set_bomber_hit(object) # raise signal instead


func _on_bomber_explode():
	print("The bomber is done exploding now")
	end_bomber()
	
func end_bomber():
	get_parent().remove_child(self)
	
