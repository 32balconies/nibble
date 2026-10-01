extends CharacterBody2D

# EXISTING BUGS:

# TODO: HANDLE BOBBER COLLISION
# TODO: DEFINE FISHDATA RESOURCE AND IMPLEMENT
# TODO: DESIGN FISHING MINIGAME A LA NOT STARDEW

const FOOTPRINT_SCENE = preload("res://Scenes/footprint.tscn")
const BOBBER_SCENE = preload("res://Scenes/bobber.tscn")

@onready var animated_sprite = $AnimatedSprite2D
@onready var raycast = $RayCast2D
@onready var world = %World
@onready var progress_bar = $ProgressBar

@export var raycast_length : int = 3
@export var bobber_offset : int = -50
@export var cast_duration : int = 2

enum State {IDLE, WALK, CHARGING, CAST, REEL}
enum Direction {UP, DOWN, LEFT, RIGHT}
var current_state := State.IDLE
var current_dir := Direction.DOWN
var cast_active := false
var bobber_instance
var cast_charge: float = 0.0
var charging = false
var reeling = false

@export var move_speed = 100

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	state_handler(input_dir)
	update_animation()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cast"):
		match current_state:
			State.CAST:
				if world.has_node("bobber") and bobber_instance.current_state == 1:
					current_state = State.REEL
					print("REEL BUTTON HIT AND BOBBER REACHED DESTINATION, REEL START")
			State.REEL:
				current_state = State.IDLE
				print("CONFIRM BUTTON HIT, RETURN TO IDLE")
			State.CHARGING:
				print("UNHANDLED: PRESSED CAST WHILE CHARGING")
			_:
				current_state = State.CHARGING
				print("CHARGE BUTTON HIT, CHARGING START")
	if event.is_action_released("cast"):
		match current_state:
			State.CHARGING:
				current_state = State.CAST
				print("CHARGE BUTTON RELEASED, CAST START")
			_:
				pass
				#print("UNHANDLED: CHARGE BUTTON RELEASED")
	if event.is_action_pressed("dialogic_default_action"):
		if Dialogic.current_timeline != null:
			return
		if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
			Dialogic.start("test")
			get_viewport().set_input_as_handled()


func state_handler(dir : Vector2):
	match current_state:
		State.CHARGING:
			progress_bar.start_charge()
			return
		State.CAST:
			if cast_charge == 0:
				cast_charge = progress_bar.get_charge()
				handle_bobber(cast_charge)
			return
		State.REEL:
			if cast_charge != 0:
				handle_bobber()
			return
		_:
			pass
	if dir.length() == 0:
		current_state = State.IDLE
		return
	var n_dir = dir.normalized()
	var dot_up = n_dir.dot(Vector2.UP)
	var dot_down = n_dir.dot(Vector2.DOWN)
	var dot_left = n_dir.dot(Vector2.LEFT)
	var dot_right = n_dir.dot(Vector2.RIGHT)
	var max_dot = max(dot_up, dot_down, dot_left, dot_right)
	if max_dot == dot_up:    
		current_dir = Direction.UP
		raycast.target_position = Vector2(0, -raycast_length)
	if max_dot == dot_down:  
		current_dir = Direction.DOWN
		raycast.target_position = Vector2(0, raycast_length)
	if max_dot == dot_left:  
		current_dir = Direction.LEFT
		raycast.target_position = Vector2(-raycast_length, 0)
	if max_dot == dot_right: 
		current_dir = Direction.RIGHT
		raycast.target_position = Vector2(raycast_length, 0)
	if raycast.is_colliding():
		current_state = State.IDLE
	else:
		current_state = State.WALK
		velocity = dir * move_speed
		move_and_slide()
	
func update_animation():
	match current_state:
		State.WALK:
			match current_dir:
				Direction.UP:
					animated_sprite.play("DownWalk")
					animated_sprite.flip_h = false
				Direction.DOWN:
					animated_sprite.play("DownWalk")
					animated_sprite.flip_h = false
				Direction.LEFT:
					animated_sprite.play("SideWalk")
					animated_sprite.flip_h = true	
				Direction.RIGHT:
					animated_sprite.play("SideWalk")
					animated_sprite.flip_h = false
		State.IDLE, State.CAST, State.REEL, State.CHARGING:
			match current_dir:
				Direction.UP:
					animated_sprite.play("DownIdle")
					animated_sprite.flip_h = false
				Direction.DOWN:
					animated_sprite.play("DownIdle")
					animated_sprite.flip_h = false
				Direction.LEFT:
					animated_sprite.play("SideIdle")
					animated_sprite.flip_h = true	
				Direction.RIGHT:
					animated_sprite.play("SideIdle")
					animated_sprite.flip_h = false

func handle_bobber(charge: float = 0.0):
	match current_state:
		State.CAST:
			if not world.has_node("bobber"):
				bobber_instance = BOBBER_SCENE.instantiate()
				bobber_instance.position = position
				bobber_instance.name = "bobber"
				bobber_instance.update_cast(current_dir, charge)
				world.add_child(bobber_instance)
		State.REEL:
			print("CALLING REEL ON %s" % bobber_instance)
			if bobber_instance:
				bobber_instance.call_deferred("queue_free")
			cast_charge = 0

func handle_footstep():
	var footstep_instance = FOOTPRINT_SCENE.instantiate()
	footstep_instance.position = position
	world.add_child(footstep_instance)
	
func _on_animated_sprite_2d_frame_changed() -> void:
	if current_state == State.WALK:
		match animated_sprite.frame:
			2:
				handle_footstep()
			6:
				handle_footstep()
