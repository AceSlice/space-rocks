extends RigidBody2D

signal shoot

#acceleration and rotation bullet scene
export (PackedScene) var Bullet
export (int) var engine_power
export (int) var spin_power 

#finite state machine
enum {INIT, ALIVE, INVUNERABLE, DEAD}
var ship_state = null

#acceleration vector and rotation direction 
var thrust = Vector2()
var rotation_dir = 0
var radius

var can_shoot = true #flag to shoot

var screen_size = Vector2()


func _ready():
	change_state(ALIVE)
	screen_size = get_viewport_rect().size
	radius = int($Sprite.texture.get_size().x/2)


func _process(_delta):
	get_input()


func _integrate_forces(state):
	applied_force = thrust.rotated(rotation)
	applied_torque = spin_power * rotation_dir
	
	var xform = state.transform
	state.transform = wrap_ship(xform)


func change_state(new_state):
	"""Changes the ship's state and disables/enable its collision"""
	match new_state:
		INIT:
			$CollisionShape2D.disabled = true
		ALIVE:
			$CollisionShape2D.disabled = false
		INVUNERABLE:
			$CollisionShape2D.disabled = true
		DEAD:
			$CollisionShape2D.disabled = true
	ship_state = new_state


func get_input():
	"""Get pooled inputs. Returns if ship's state is INIT or DEAD.
	Sets the thrust length to engine_power and rotation_dir to -1 (left)
	or 1 (righ). Invokes shoot function"""
	if ship_state in [INIT, DEAD]:
		return
		
	thrust = Vector2()
	if Input.is_action_pressed("thrust"):
		thrust = Vector2(engine_power, 0)
	
	rotation_dir = 0
	if Input.is_action_pressed("rotate_right"):
		rotation_dir = 1
	if Input.is_action_pressed("rotate_left"):
		rotation_dir = -1
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()


func wrap_ship(xform):
	"""Changes ship's position (origin) when it exceeds screen bounds.
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


func shoot():
	"""Emits shoot signal passing in Bullet, position and rotation.
	Returns if ship state is INVULNERABLE"""
	if ship_state == INVUNERABLE:
		return
	emit_signal("shoot", Bullet, $Muzzle.global_position, rotation)
	can_shoot = false
	$GunTimer.start()


func _on_GunTimer_timeout():
	can_shoot = true
