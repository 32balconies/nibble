extends Node2D

@onready var audio = $AudioStreamPlayer2D

@export var pitch_range = 0.5

func _ready() -> void:
	randomize()
	var pitch = randf_range(1 - pitch_range, 1 + pitch_range)
	audio.pitch_scale = pitch
	
func _on_timer_timeout() -> void:
	queue_free()
