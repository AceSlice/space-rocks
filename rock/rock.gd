extends RigidBody2D

signal exploded

var screen_size = Vector2()

#rock data
var scale_factor = 0.2
var radius
var size


func _integrate_forces(state):
	var xform = state.transform
	xform = wrap_rock(xform)
	state.transform = xform


func start(pos, vel, _size):
	"""Sets position, veloity, size. Calculates mass and radius and changes
	the size of the Sprite and CollisionShape and Explosion"""
	position = pos
	size = _size
	mass = 1.5 * size
	$Sprite.scale = Vector2(1, 1) * size * scale_factor
	radius = int(($Sprite.texture.get_size().x / 2) * (size * scale_factor))
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape
	linear_velocity = vel
	angular_velocity = rand_range(-1.5, 1.5)
	
	$Explosion.hide()
	$Explosion.scale = Vector2(0.75, 0.75) * size


func wrap_rock(xform):
	"""Changes the position of rock if it exceeds screen bounds. 
	Returns the new position"""
	if xform.origin.x < 0 - radius:
		xform.origin.x = screen_size.x + radius
	if xform.origin.x > screen_size.x + radius:
		xform.origin.x = 0 - radius
	
	if xform.origin.y < 0 - radius:
		xform.origin.y = screen_size.y + radius
	if xform.origin.y > screen_size.y + radius:
		xform.origin.y = 0 - radius
	
	return xform


func explode():
	"""Plays the explosion animation and stops the rock motion"""
	$Explosion.show()
	layers = 0
	$Sprite.hide()
	$Explosion/AnimationPlayer.play("explosion")
	emit_signal("exploded", radius, size, position, linear_velocity)
	linear_velocity = Vector2()
	angular_velocity = 0


func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
