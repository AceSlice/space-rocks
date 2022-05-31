extends Node2D

export (PackedScene) var Rock

var screen_size = Vector2()


func _ready():
	randomize()
	screen_size = get_viewport_rect().size
	$Player.screen_size = screen_size
	for _i in range(3):
		spawn_rock(3)


func spawn_rock(size, pos=null, vel=null):
	"""Create new rock instance. Set its size, position and velocity"""
	if !pos:
		$RockPath/RockSpawn.offset = randi()
		pos = $RockPath/RockSpawn.position
	if !vel:
		vel = Vector2(1, 0).rotated(rand_range(0, 2*PI)) * rand_range(100, 150)
	
	var r = Rock.instance()
	r.screen_size = screen_size
	r.start(pos, vel, size)
	$Rocks.add_child(r)
	r.connect("exploded", self, "_on_Rock_exploded")


func _on_Player_shoot(bullet, pos, dir):
	var b = bullet.instance()
	b.start(pos, dir)
	add_child(b)


func _on_Rock_exploded(radius, size, pos, vel):
	if size <= 1:
		return
	for offset in [-1, 1]:
		var dir = (pos - $Player.position).normalized().tangent() * offset
		var newpos = pos + (dir * radius) 
		var newvel = dir * vel.length() * 1.1
		spawn_rock(size - 1, newpos, newvel)
