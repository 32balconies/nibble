extends RigidBody2D

const FISH_SCENE = preload("res://Scenes/fish.tscn")
enum State {AIR, LAND}

@onready var sprite: Sprite2D = $Sprite2D

@export var fish_data: FishData
@export var cast_distance: float = 5.0
@export var cast_height: float = 10.0
@export var bobber_offset: float = 50.0
@export var line_width: float = 1.0
@export var line_tension: float = 0.1
@export var line_bake: float = 5.0

var p0: Vector2 # Start position
var p1: Vector2 # Control point (peak of the arc)
var p2: Vector2 # Target position
var time: float = 0.0
var duration: float = 1.0
var current_state := State.AIR
var cast_dir: Vector2
var elapsed_time: float = 0.0
var player: CharacterBody2D
var world: Node2D
var main: Control
var bobber_area: Area2D
var progress_bar: ProgressBar
var fishing_line: Line2D
var curve: Curve2D
var fish_instance

	
func _ready() -> void:
	setup_cast()

# TODO: REFORMAT TO TAKE ADVANTAGE OF STATES
func  _physics_process(delta: float) -> void:
	time += delta / duration
	if time >= 1.0:
		time = 1.0
		current_state = State.LAND
		bobber_area.position = position
		progress_bar.reset_charge()
		if not main.bobber_check:
			player.kill_bobber()
			
	global_position = quadratic_bezier(p0, p1, p2, time)
	if fish_instance:
		fish_instance.global_position = quadratic_bezier(p2, p1, p0, time)
	curve_line()

func setup_cast():
	main = get_parent().get_parent()
	world = main.find_child("World")
	player = main.find_child("Player")
	progress_bar = player.find_child("ProgressBar")
	bobber_area = world.find_child("BobberArea")
	p0 = position + Vector2(0,-bobber_offset)
	p2 = position + (cast_dir * cast_distance)
	p1 = (p0 + p2) / 2.0
	p1.y -= cast_height
	time = 0.0
	current_state = State.AIR
	curve = Curve2D.new()
	curve.bake_interval = line_bake
	fishing_line = Line2D.new()
	fishing_line.width = line_width
	self.add_child(fishing_line)
	curve.add_point(Vector2.ZERO)
	curve.add_point(Vector2.ZERO)
	
func quadratic_bezier(point_0: Vector2, point_1: Vector2, point_2: Vector2, t: float) -> Vector2:
	var q0 = point_0.lerp(point_1, t)
	var q1 = point_1.lerp(point_2, t)
	return q0.lerp(q1, t)

func curve_line():
	var start_pos: Vector2 = fishing_line.to_local(p0)
	var end_pos: Vector2 = fishing_line.to_local(global_position)
	var distance: float = start_pos.distance_to(end_pos)
	var handle_offset := Vector2(0, distance * line_tension)
	curve.set_point_position(0, start_pos)
	curve.set_point_out(0, handle_offset)
	curve.set_point_position(1, end_pos)
	fishing_line.points = curve.get_baked_points()

func reel():
	time = 0
	fish_instance = FISH_SCENE.instantiate()
	add_child(fish_instance)
	fish_instance.set_fish_data(fish_data)
	sprite.visible = false
	fishing_line.visible = false
	# TODO: SEND FISH DATA OUT

	
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
