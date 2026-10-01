extends RigidBody2D

enum State {AIR, LAND}

@export var cast_distance: float = 5.0
@export var cast_height: float = 10.0
@export var bobber_offset: float = 50.0

var p0: Vector2 # Start position
var p1: Vector2 # Control point (peak of the arc)
var p2: Vector2 # Target position
var time: float = 0.0
var duration: float = 1.0
var current_state := State.AIR
var cast_dir: Vector2
var elapsed_time: float = 0.0
var player: CharacterBody2D
var progress_bar: ProgressBar
	
func _ready() -> void:
	player = get_parent().get_parent().find_child("Player")
	progress_bar = player.find_child("ProgressBar")
	p0 = position + Vector2(0,-bobber_offset)
	p2 = position + (cast_dir * cast_distance)
	p1 = (p0 + p2) / 2.0
	p1.y -= cast_height
	time = 0.0
	current_state = State.AIR
	
func  _physics_process(delta: float) -> void:
	time += delta / duration
	if time >= 1.0:
		time = 1.0
		current_state = State.LAND
		progress_bar.reset_charge()
	global_position = quadratic_bezier(p0, p1, p2, time)
	
func quadratic_bezier(point_0: Vector2, point_1: Vector2, point_2: Vector2, t: float) -> Vector2:
	var q0 = point_0.lerp(point_1, t)
	var q1 = point_1.lerp(point_2, t)
	return q0.lerp(q1, t)
	
func update_cast(dir, charge):
	match dir:
		0:
			cast_dir = Vector2(0, -1) * charge / 100
		1:
			cast_dir = Vector2(0, 1) * charge / 100
		2:
			cast_dir = Vector2(-1, 0) * charge / 100
		3:
			cast_dir = Vector2(1, 0) * charge / 100
	cast_height *= charge / 100
	print(cast_dir)
