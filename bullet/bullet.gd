extends Area2D

#speed and velocity vector 
export (int) var speed
var veloity = Vector2()


func _process(delta):
	position += veloity * delta


func start(pos, dir):
	"""Sets the position, rotation and velocity of the bullet"""
	position = pos
	rotation = dir
	veloity = Vector2(speed, 0).rotated(dir)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Bullet_body_entered(body):
	if body.is_in_group("rocks"):
		body.explode()
		queue_free()
